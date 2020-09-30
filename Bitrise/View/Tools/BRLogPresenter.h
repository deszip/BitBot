//
//  BRLogPresenter.h
//  Bitrise
//
//  Created by Deszip on 23.02.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AMR_ANSIEscapeHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRLogPresenter : NSObject

- (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithANSIHelper:(AMR_ANSIEscapeHelper *)helper NS_DESIGNATED_INITIALIZER;

#if TARGET_OS_OSX
- (NSAttributedString *)decoratedLine:(NSString *)line;
#endif

@end

NS_ASSUME_NONNULL_END
