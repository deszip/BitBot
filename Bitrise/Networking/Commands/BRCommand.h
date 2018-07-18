//
//  BRCommand.h
//  Bitrise
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRCommandResult)(BOOL result, NSError * _Nullable error);

@protocol BRCommand <NSObject>

- (void)execute:(_Nullable BRCommandResult)callback;

@end

NS_ASSUME_NONNULL_END
