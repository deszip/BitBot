//
//  BRMacro.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#ifndef BRMacro_h
#define BRMacro_h

#pragma mark - Tools -

#define BR_SAFE_CALL(block, ...) block ? block(__VA_ARGS__) : nil

#pragma mark - Features -

#define FEATURE_LIVE_LOG 0

#endif /* BRMacro_h */
