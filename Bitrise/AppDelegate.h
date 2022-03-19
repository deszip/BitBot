//
//  AppDelegate.h
//  BitBot
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BRDependencyContainerOwner;
@protocol BRDependencyContainerProvider <NSObject>

- (void)loadDependencyContainer:(id<BRDependencyContainerOwner>)owner;

@end

@interface AppDelegate : NSObject <NSApplicationDelegate, BRDependencyContainerProvider>

@end

