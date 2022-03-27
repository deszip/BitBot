//
//  BRCoreController.h
//  Bitrise
//
//  Created by Deszip on 27.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRCoreController : NSObject

- (void)establishConnection;
- (void)testConnection:(NSString *)request response:(void (^)(NSString *))responseHandler;

@end

NS_ASSUME_NONNULL_END
