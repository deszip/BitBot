//
//  BRCellBuilder.m
//  Bitrise
//
//  Created by Deszip on 11/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRCellBuilder.h"

@interface BRCellBuilder ()

@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *durationFormatter;

@end

@implementation BRCellBuilder

- (instancetype)init {
    if (self= [super init]) {
        _timeFormatter = [NSDateFormatter new];
        [_timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [_timeFormatter setDateFormat:@"HH:mm"];
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
    
    // Status
    switch (build.status.integerValue) {
        case 0:
            [cell.statusImage setImage:nil];
            [cell.statusLabel setStringValue:@"Unknown"];
            break;
        case 1:
            [cell.statusImage setImage:[NSImage imageNamed:@"success-status"]];
            [cell.statusLabel setStringValue:@"Success"];
            break;
        case 2:
            [cell.statusImage setImage:[NSImage imageNamed:@"failed-status"]];
            [cell.statusLabel setStringValue:@"Failed"];
            break;
    }
    
    [cell.branchLabel setStringValue:build.branch];
    [cell.workflowLabel setStringValue:build.workflow];
    [cell.triggerTimeLabel setStringValue:[NSString stringWithFormat:@"Triggered: %@", [self.timeFormatter stringFromDate:build.triggerTime]]];
    
    NSTimeInterval duration = [build.finishedTime timeIntervalSinceDate:build.envPrepareFinishedTime];
    NSDate *durationDate = [NSDate dateWithTimeIntervalSince1970:duration];
    [cell.buildTimeLabel setStringValue:[NSString stringWithFormat:@"%@", [self.durationFormatter stringFromDate:durationDate]]];
    
    [cell.buildNumberLabel setStringValue:[NSString stringWithFormat:@"#%li", build.buildNumber.integerValue]];
    
    return cell;
}

@end
