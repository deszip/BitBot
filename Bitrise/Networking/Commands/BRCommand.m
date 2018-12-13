//
//  BRCommand.m
//  Bitrise
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRCommand.h"

@interface BRCommand ()

@end

@implementation BRCommand

- (void)execute:(BRCommandResult)callback {
    callback(NO, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
}

@end
