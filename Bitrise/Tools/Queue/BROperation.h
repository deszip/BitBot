//
//  ASOperation.h
//  AppSpector
//
//  Created by Deszip on 24/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASQueue.h"

@interface BROperation : NSOperation

@property (strong, nonatomic) ASQueue *queue;

- (void)finish;

@end
