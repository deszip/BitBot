//
//  BRCommand.h
//  Bitrise
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRCommandResult)(BOOL result, NSError * _Nullable error);

@interface BRCommand : NSObject

@property (strong, nonatomic, readonly) BRBitriseAPI *api;
@property (strong, nonatomic, readonly) BRStorage *storage;

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;
- (void)execute:(_Nullable BRCommandResult)callback;

@end

NS_ASSUME_NONNULL_END
