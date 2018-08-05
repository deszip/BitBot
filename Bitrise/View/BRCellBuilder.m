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
    
    // Action
    if (build.status.integerValue == 0 && !build.onHold.boolValue) {
        [cell.actionButton setTitle:@"Stop"];
        [cell setRunningSince:build.envPrepareFinishedTime];
    } else {
        [cell.actionButton setTitle:@"Rebuild"];
        [cell setFinishedAt:build.finishedTime started:build.triggerTime];
    }
    
    // Status
    [cell.statusImage.layer setCornerRadius:0];
    [cell spinImage:NO];
    
    switch (build.status.integerValue) {
        case 0:
            if (build.onHold.boolValue) {
                [cell.statusImage setImage:[NSImage imageNamed:@"hold-status"]];
                [cell.statusLabel setStringValue:@"On hold"];
            } else {
                [cell.statusImage.layer setCornerRadius:cell.statusImage.bounds.size.width / 2];
                [cell spinImage:NO];
                [cell.statusImage setImage:[NSImage imageNamed:@"progress-status"]];
                [cell.statusLabel setStringValue:@"In progress..."];
            }
            break;
        
        case 1:
            [cell.statusImage setImage:[NSImage imageNamed:@"success-status"]];
            [cell.statusLabel setStringValue:@"Success"];
            break;
        
        case 2:
            [cell.statusImage setImage:[NSImage imageNamed:@"failed-status"]];
            [cell.statusLabel setStringValue:@"Failed"];
            break;
        
        case 3:
            [cell.statusImage setImage:[NSImage imageNamed:@"abort-status"]];
            [cell.statusLabel setStringValue:@"Aborted"];
            break;
    }
    
    // Parameters
    [cell.appTitleLabel setStringValue:build.app.title];
    [cell.branchLabel setStringValue:build.branch];
    [cell.workflowLabel setStringValue:build.workflow];
    [cell.triggerTimeLabel setStringValue:[NSString stringWithFormat:@"Triggered: %@", [self.timeFormatter stringFromDate:build.triggerTime]]];
    
    [cell.buildNumberLabel setStringValue:[NSString stringWithFormat:@"#%li", build.buildNumber.integerValue]];
    
    return cell;
}

@end
