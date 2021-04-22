//
//  ASOperation.h
//  AppSpector
//
//  Created by Deszip on 24/12/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Sentry/Sentry.h>
#import "ASQueue.h"

@interface ASOperation : NSOperation

@property (strong, nonatomic, readonly) id <SentrySpan> sentryTransaction;

@property (strong, nonatomic) ASQueue *queue;

- (void)finish;

@end
