//
//  BitBotCore.m
//  BitBotCore
//
//  Created by Deszip on 26.03.2022.
//  Copyright © 2022 Bitrise. All rights reserved.
//

#import "BitBotCore.h"

@implementation BitBotCore

- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
    
    NSLog(@"Got request: %@, response: %@", aString, response);
}

@end
