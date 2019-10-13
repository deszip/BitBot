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

#import "NSData+MPBase64.h"
#import "Mixpanel.h"

FOUNDATION_EXPORT double Mixpanel_OSX_CommunityVersionNumber;
FOUNDATION_EXPORT const unsigned char Mixpanel_OSX_CommunityVersionString[];

