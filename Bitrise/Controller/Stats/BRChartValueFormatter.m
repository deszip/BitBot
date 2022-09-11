//
//  BRChartValueFormatter.m
//  BitBot
//
//  Created by Deszip on 11.09.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRChartValueFormatter.h"

@implementation BRChartValueFormatter

- (NSString *)stringForValue:(double)value
                       entry:(ChartDataEntry *)entry
                dataSetIndex:(NSInteger)dataSetIndex
             viewPortHandler:(ChartViewPortHandler *)viewPortHandler
{
    return [NSString stringWithFormat:@"%f (%li)", value, (long)dataSetIndex];
}

@end
