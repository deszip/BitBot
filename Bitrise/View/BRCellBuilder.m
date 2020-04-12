//
//  BRCellBuilder.m
//  BitBot
//
//  Created by Deszip on 11/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRCellBuilder.h"

#import "BRBuildInfo.h"
#import "BRStyleSheet.h"

@interface BRCellBuilder ()

@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *durationFormatter;

@end

@implementation BRCellBuilder

- (instancetype)init {
    if (self= [super init]) {
        _timeFormatter = [NSDateFormatter new];
        [_timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [_timeFormatter setDateFormat:@"dd.MM.yyyy @ HH:mm"];
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
    
    /// Progress animation
    if (buildStateInfo.state == BRBuildStateInProgress ||
        buildStateInfo.state == BRBuildStateWaitingForWorker) {
        [cell spinImage:YES];
        [cell setRunningSince:build.envPrepareFinishedTime];
    } else {
        [cell spinImage:NO];
        [cell setFinishedAt:build.finishedTime started:build.triggerTime];
    }
    
    /// Status image
    [cell setContainerColor:buildStateInfo.statusColor];
    
    // Parameters
    [cell.accountLabel setStringValue:build.app.account.username.uppercaseString];
    [cell.appTitleLabel setStringValue:build.app.title.uppercaseString];
    [cell.branchLabel setStringValue:build.branch];
    [cell.commitLabel setStringValue:build.commitMessage ? build.commitMessage : @"no commit message"];
    [cell.workflowLabel setStringValue:build.workflow];
    [cell.triggerTimeLabel setStringValue:[self.timeFormatter stringFromDate:build.triggerTime]];
    
    [cell.buildNumberLabel setStringValue:[NSString stringWithFormat:@"#%li", build.buildNumber.integerValue]];
    
    return cell;
}

@end
