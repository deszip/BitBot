//
//  BRProgressObserver.h
//  Bitrise
//
//  Created by Deszip on 21/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRProgressObserver : NSObject

- (void)bindProgress:(NSProgress *)progress toIndicator:(NSProgressIndicator *)indicator;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
