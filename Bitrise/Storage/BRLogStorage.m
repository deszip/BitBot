//
//  BRLogStorage.m
//  Bitrise
//
//  Created by Deszip on 20/03/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogStorage.h"

#import <EasyMapping/EasyMapping.h>

#import "BRBuildLog+Mapping.h"
#import "BRBuildLog+Mapping.h"
#import "BRLogLine+CoreDataClass.h"
#import "BRLogStep+CoreDataClass.h"
#import "BRLogsParser.h"

@interface BRLogStorage ()

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BRLogsParser *logParser;

@end

@implementation BRLogStorage

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
        [_context setAutomaticallyMergesChangesFromParent:YES];
        
        _logParser = [BRLogsParser new];
    }
    
    return self;
}

#pragma mark - Logs -

// @TODO: Extract to log storage

- (BOOL)saveLogMetadata:(NSDictionary *)rawLogMetadata forBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    if (build.log) {
        [EKManagedObjectMapper fillObject:build.log fromExternalRepresentation:rawLogMetadata withMapping:[BRBuildLog objectMapping] inManagedObjectContext:self.context];
    } else {
        BRBuildLog *buildLog = [EKManagedObjectMapper objectFromExternalRepresentation:rawLogMetadata withMapping:[BRBuildLog objectMapping] inManagedObjectContext:self.context];
        build.log = buildLog;
    }
    
    return [self saveContext:self.context error:error];
}

- (BOOL)appendLogs:(NSString *)text chunkPosition:(NSUInteger)chunkPosition toBuild:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    // Get last line
    NSFetchRequest *linesRequest = [BRLogLine fetchRequest];
    linesRequest.predicate = [NSPredicate predicateWithFormat:@"log.build.slug = %@", build.slug];
    linesRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"chunkPosition" ascending:NO],
                                     [NSSortDescriptor sortDescriptorWithKey:@"linePosition" ascending:NO]];
    linesRequest.fetchLimit = 1;
    NSError *fetchError;
    NSArray<BRLogLine *> *lines = [self.context executeFetchRequest:linesRequest error:&fetchError];
    BRLogLine *lastLine = lines.firstObject;
    BOOL lineBroken = [self.logParser lineBroken:lastLine.text];
    
    // Get last step
    NSFetchRequest *stepsRequest = [BRLogStep fetchRequest];
    stepsRequest.predicate = [NSPredicate predicateWithFormat:@"log.build.slug = %@", build.slug];
    stepsRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO]];
    stepsRequest.fetchLimit = 1;
    NSArray<BRLogStep *> *steps = [self.context executeFetchRequest:stepsRequest error:&fetchError];
    BRLogStep *lastStep = steps.firstObject;
    __block NSUInteger lastStepIndex = lastStep ? lastStep.index + 1 : 0;
    
    // Split chunk into lines
    NSMutableArray <NSString *> *rawLines = [[self.logParser split:text] mutableCopy];
    
    // Append first line to previous line if it was broken
    if (lineBroken && rawLines.count > 0) {
        lastLine.text = [lastLine.text stringByAppendingString:rawLines.firstObject];
        [rawLines removeObjectAtIndex:0];
    }
    
    // Build rest of lines from chunk
    __block BRLogStep *currentStep = lastStep;
    [rawLines enumerateObjectsUsingBlock:^(NSString *rawLine , NSUInteger idx, BOOL *stop) {
        BRLogLine *line = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BRLogLine class]) inManagedObjectContext:self.context];
        line.linePosition = idx;
        line.chunkPosition = chunkPosition;
        line.text = rawLine;
        [build.log addLinesObject:line];
        
        // Build a step
        NSString *stepName = [self.logParser stepNameForLine:line.text];
        if (stepName) {
            currentStep = [self stepWithName:stepName index:++lastStepIndex];
            [line.log addStepsObject:currentStep];
            // @TODO: Extract...
            NSArray <BRLogLine *> *sortedLines = [[build.log.lines allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"chunkPosition" ascending:YES],
                                                                                                             [NSSortDescriptor sortDescriptorWithKey:@"linePosition" ascending:YES]]];
            // Check if we have 'arrow' line
            if ([[sortedLines[sortedLines.count - 4].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"▼"]) {
                sortedLines[sortedLines.count - 4].step = currentStep;
                sortedLines[sortedLines.count - 3].step = currentStep;
                sortedLines[sortedLines.count - 2].step = currentStep;
            } else {
                sortedLines[sortedLines.count - 2].step = currentStep;
            }
        } else if (!currentStep) {
            currentStep = [self stepWithName:@"Init" index:++lastStepIndex];
            [line.log addStepsObject:currentStep];
        }
        
        line.step = currentStep;
    }];
    
    return [self saveContext:self.context error:error];
}

- (BOOL)markBuildLog:(BRBuildLog *)buildLog loaded:(BOOL)isLoaded error:(NSError * __autoreleasing *)error {
    [buildLog setLoaded:isLoaded];
    
    return [self saveContext:self.context error:error];
}

- (BOOL)cleanLogs:(BRBuild *)build error:(NSError * __autoreleasing *)error {
    // Mark build as not loaded
    build.log.loaded = NO;
    
    // Clean log steps
    NSFetchRequest *stepsRequest = [BRLogStep fetchRequest];
    [stepsRequest setPredicate:[NSPredicate predicateWithFormat:@"log.build.slug = %@", build.slug]];
    NSArray <BRLogStep *> *steps = [self.context executeFetchRequest:stepsRequest error:error];
    if (!steps) {
        return NO;
    }
    [steps enumerateObjectsUsingBlock:^(BRLogStep *step, NSUInteger idx, BOOL *stop) {
        [self.context deleteObject:step];
    }];
    
    return [self saveContext:self.context error:error];
}

#pragma mark - Builders -

- (BRLogStep *)stepWithName:(NSString *)name index:(NSUInteger)index {
    NSString *stepClassName = NSStringFromClass([BRLogStep class]);
    BRLogStep *step = [NSEntityDescription insertNewObjectForEntityForName:stepClassName inManagedObjectContext:self.context];
    step.name = name;
    step.index = index;
    
    return step;
}

#pragma mark - Save -

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error {
    if ([context hasChanges]) {
        [context processPendingChanges];
        return [context save:error];
    }
    
    return YES;
}

@end
