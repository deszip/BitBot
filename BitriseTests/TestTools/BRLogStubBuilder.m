//
//  BRLogStubBuilder.m
//  BitriseTests
//
//  Created by Deszip on 24/02/2019.
//  Copyright © 2019 Bitrise. All rights reserved.
//

#import "BRLogStubBuilder.h"

@implementation BRLogStubBuilder

- (NSDictionary *)runningLogMetadata {
    return [self content:@"LogResponse_10chunks_running"];
}

- (NSDictionary *)finishedLogMetadata {
    return [self content:@"LogResponse_10chunks_finished"];
}

- (NSDictionary *)content:(NSString *)stubName {
    NSURL *stubURL = [[NSBundle bundleForClass:[self class]] URLForResource:stubName withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:stubURL];
    NSError *error;
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

@end
