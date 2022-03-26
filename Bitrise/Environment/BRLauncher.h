//
//  BRLauncher.h
//  Bitrise
//
//  Created by Deszip on 26.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRLauncher : NSObject

- (BOOL)menuAppIsRunning;
- (void)launchMenuApp;
- (void)killMenuApp;

- (BOOL)mainAppIsRunning;
- (void)launchMainApp;
- (void)killMainApp;

- (void)quit;

@end

NS_ASSUME_NONNULL_END
