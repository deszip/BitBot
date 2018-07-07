//
//  BRAccount+Mapping.h
//  Bitrise
//
//  Created by Deszip on 07/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EasyMapping/EasyMapping.h>
#import "BRAccount+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRAccount (Mapping) <EKManagedMappingProtocol>

@end

NS_ASSUME_NONNULL_END
