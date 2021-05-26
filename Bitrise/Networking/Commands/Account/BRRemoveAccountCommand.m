//
//  BRRemoveAccountCommand.m
//  BitBot
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRRemoveAccountCommand.h"

#import "BRAnalytics.h"

@interface BRRemoveAccountCommand ()

@property (strong, nonatomic, readonly) BRBitriseAPI *api;
@property (strong, nonatomic, readonly) BRStorage *storage;
@property (copy, nonatomic) NSString *slug;

@end

@implementation BRRemoveAccountCommand

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage slug:(NSString *)slug {
    if (self = [super init]) {
        _api = api;
        _storage = storage;
        _slug = slug;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    [self.storage perform:^{
        NSError *error;
        BOOL result = [self.storage removeAccount:self.slug error:&error];
        if (result) {
            [[BRAnalytics analytics] trackAccountRemove];
        } else {
            [[BRAnalytics analytics] trackAccountRemoveError:error];
        }
        BR_SAFE_CALL(callback, result, error);
    }];
}

@end
