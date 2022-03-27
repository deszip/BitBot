//
//  BRCoreController.m
//  Bitrise
//
//  Created by Deszip on 27.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BRCoreController.h"

#import "BRMacro.h"
#import "BitBotCoreProtocol.h"

static NSString * const kBitBotCoreServiceName = @"com.bitbot.bitbotcore";

@interface BRCoreController ()

@property (strong, nonatomic) NSXPCConnection *connection;

@end

@implementation BRCoreController

- (void)establishConnection {
    _connection = [[NSXPCConnection alloc] initWithServiceName:kBitBotCoreServiceName];
    _connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(BitBotCoreProtocol)];
    [_connection resume];
}

- (void)testConnection:(NSString *)request response:(void (^)(NSString *))responseHandler {
    [[_connection remoteObjectProxy] upperCaseString:request withReply:^(NSString *response) {
        BR_SAFE_CALL(responseHandler, response);
    }];
}

@end
