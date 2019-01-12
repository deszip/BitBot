//
//  BRRebuildRequest.h
//  Bitrise
//
//  Created by Deszip on 09/01/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRAPIRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRRebuildRequest : BRAPIRequest

@property (copy, nonatomic) NSString *branch;
@property (copy, nonatomic) NSString *commit;
@property (copy, nonatomic) NSString *workflow;

- (instancetype)initWithToken:(NSString *)token appSlug:(NSString *)appSlug branch:(NSString *)branch NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
