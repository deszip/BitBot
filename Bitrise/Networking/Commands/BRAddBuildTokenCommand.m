//
//  BRAddBuildKeyCommand.m
//  Bitrise
//
//  Created by Deszip on 03/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAddBuildTokenCommand.h"

@interface BRAddBuildTokenCommand ()

@property (strong, nonatomic) BRStorage *storage;
@property (copy, nonatomic) NSString *appSlug;
@property (copy, nonatomic) NSString *token;

@end

@implementation BRAddBuildTokenCommand

- (instancetype)initWithStorage:(BRStorage *)storage appSlug:(NSString *)appSlug token:(NSString *)token {
    if (self = [super init]) {
        _storage = storage;
        _appSlug = appSlug;
        _token = token;
    }
    
    return self;
}

- (void)execute:(BRCommandResult)callback {
    NSError *error;
    BOOL result = [self.storage addBuildToken:self.token toApp:self.appSlug error:&error];
    BR_SAFE_CALL(callback, result, error);
}

@end
