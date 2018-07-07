//
//  BRBitriseAPI.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAccountResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^APIAccountInfoCallback)(BRAccountResponse * _Nullable, NSError * _Nullable);

@interface BRBitriseAPI : NSObject

- (void)getAccount:(NSString *)token completion:(APIAccountInfoCallback)completion;

@end

NS_ASSUME_NONNULL_END
