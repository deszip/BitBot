//
//  CHAutorun.h
//  Chisti
//
//  Created by Deszip on 03/06/2018.
//  Copyright © 2018 Deszip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRAutorun : NSObject

- (BOOL)launchOnLoginEnabled;
- (void)setLaunchOnLogin:(BOOL)launchOnLogin;

- (void)toggleAutolaunch;

@end
