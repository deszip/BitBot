//
//  BRDependencyContainer.h
//  Bitrise
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRAppsDataSource.h"
#import "BRAccountsDataSource.h"

@interface BRDependencyContainer : NSObject

- (BRAppsDataSource *)appsDataSourceFor:(NSOutlineView *)outlineView;
- (BRAccountsDataSource *)accountsDataSourceFor:(NSOutlineView *)outlineView;

@end
