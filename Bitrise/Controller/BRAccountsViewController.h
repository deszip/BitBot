//
//  BRAccountsViewController.h
//  Bitrise
//
//  Created by Deszip on 05/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAccountsViewController : NSViewController

@property (strong, nonatomic) NSPersistentContainer *container;

@end

NS_ASSUME_NONNULL_END
