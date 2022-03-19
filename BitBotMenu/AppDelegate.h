//
//  AppDelegate.h
//  BitBotMenu
//
//  Created by Deszip on 13.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BRDependencyContainer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic, readonly) BRDependencyContainer *dependencyContainer;

@end

