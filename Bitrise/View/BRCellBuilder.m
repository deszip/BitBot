//
//  BRCellBuilder.m
//  BitBot
//
//  Created by Deszip on 11/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRCellBuilder.h"

#import "BRBuildInfo.h"

@interface BRCellBuilder ()

@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *durationFormatter;

@end

@implementation BRCellBuilder

- (instancetype)init {
    if (self= [super init]) {
        _timeFormatter = [NSDateFormatter new];
        [_timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [_timeFormatter setDateFormat:@"yyyy.MM.dd @ HH:mm"];
        _durationFormatter = [NSDateFormatter new];
        [_durationFormatter setDateFormat:@"m'm' s's'"];
    }
    
    return self;
}

- (BRAppCellView *)appCell:(BRApp *)app forOutline:(NSOutlineView *)outline {
    BRAppCellView *cell = [outline makeViewWithIdentifier:@"BRAppCellView" owner:self];
    [cell.appNameLabel setStringValue:app.title];
    
    return cell;
}

- (BRBuildCellView *)buildCell:(BRBuild *)build forOutline:(NSOutlineView *)outline {
    BRBuildCellView *cell = [outline makeViewWithIdentifier:@"BRBuildCellView" owner:self];
    BRBuildStateInfo *buildStateInfo = [[[BRBuildInfo alloc] initWithBuild:build] stateInfo];
    
    [cell.statusImage setImage:[NSImage imageNamed:buildStateInfo.statusImageName]];
    if (buildStateInfo.state == BRBuildStateInProgress) {
        [cell spinImage:YES];
        [cell setRunningSince:build.envPrepareFinishedTime];
    } else {
        [cell spinImage:NO];
        [cell setFinishedAt:build.finishedTime started:build.triggerTime];
    }
    
    [cell.backgroundStatusImage setImage:[NSImage imageNamed:buildStateInfo.statusImageName]];
    [cell.statusLabel setStringValue:buildStateInfo.statusTitle];
    
    [cell.statusImageContainer setWantsLayer:YES];
    [cell.statusImageContainer.layer setBackgroundColor:[NSColor colorWithPatternImage:cell.statusImage.image].CGColor];
    
    // Parameters
    [cell.appTitleLabel setStringValue:build.app.title];
    [cell.branchLabel setStringValue:build.branch];
    [cell.workflowLabel setStringValue:build.workflow];
    [cell.triggerTimeLabel setStringValue:[NSString stringWithFormat:@"Triggered: %@", [self.timeFormatter stringFromDate:build.triggerTime]]];
    
    [cell.buildNumberLabel setStringValue:[NSString stringWithFormat:@"#%li", build.buildNumber.integerValue]];
    
    return cell;
}

@end
