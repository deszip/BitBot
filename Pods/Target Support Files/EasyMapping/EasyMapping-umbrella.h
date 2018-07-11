#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "EasyMapping.h"
#import "EKCoreDataImporter.h"
#import "EKManagedObjectMapper.h"
#import "EKManagedObjectMapping.h"
#import "EKManagedObjectModel.h"
#import "EKMapper.h"
#import "EKMappingBlocks.h"
#import "EKMappingProtocol.h"
#import "EKObjectMapping.h"
#import "EKObjectModel.h"
#import "EKPropertyHelper.h"
#import "EKPropertyMapping.h"
#import "EKRelationshipMapping.h"
#import "EKSerializer.h"
#import "NSArray+FlattenArray.h"
#import "NSDateFormatter+EasyMappingAdditions.h"

FOUNDATION_EXPORT double EasyMappingVersionNumber;
FOUNDATION_EXPORT const unsigned char EasyMappingVersionString[];

