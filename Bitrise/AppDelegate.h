//
//  AppDelegate.h
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRDependencyContainer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic, readonly) BRDependencyContainer *dependencyContainer;

@end

