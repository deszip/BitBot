//
//  BitBotCore.h
//  BitBotCore
//
//  Created by Deszip on 26.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitBotCoreProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface BitBotCore : NSObject <BitBotCoreProtocol>
@end
