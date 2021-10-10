//
//  BRDependencyInjector.h
//  BitBot
//
//  Created by Deszip on 10.10.2021.
//  Copyright © 2021 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRDependencyInjector : NSObject

+ (void)propagateContainer:(id)container toSegue:(NSStoryboardSegue *)segue;
+ (void)propagateContainer:(id)container toController:(NSViewController *)controller;

@end

NS_ASSUME_NONNULL_END
