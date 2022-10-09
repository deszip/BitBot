//
//  BRBuildPredicate.h
//  BitBot
//
//  Created by Deszip on 06.10.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRBuildPredicate : NSObject

@property (assign, nonatomic) BOOL includeSuccess;
@property (assign, nonatomic) BOOL includeFailed;
@property (assign, nonatomic) BOOL includeOnHold;
@property (assign, nonatomic) BOOL includeAborted;
@property (assign, nonatomic) BOOL includeInProgress;

+ (instancetype)allEnabled;
+ (instancetype)allDisabled;

- (BOOL)hasEnabled;
- (NSPredicate *)predicate;
    
@end

NS_ASSUME_NONNULL_END
