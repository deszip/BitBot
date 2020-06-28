//
//  BRLogPresenter.m
//  Bitrise
//
//  Created by Deszip on 23.02.2020.
//  Copyright © 2020 Bitrise. All rights reserved.
//

#import "BRLogPresenter.h"

#import "BRMacro.h"
#import "BRStyleSheet.h"

@interface BRLogPresenter ()

@property (strong, nonatomic) AMR_ANSIEscapeHelper *helper;

@end

@implementation BRLogPresenter

- (instancetype)initWithANSIHelper:(AMR_ANSIEscapeHelper *)helper {
    if (self = [super init]) {
        _helper = helper;
        _helper.font = [BRStyleSheet logFont];
        _helper.defaultStringColor = [NSColor whiteColor];
        
        _helper.ansiColors = [@{ @(AMR_SGRCodeFgRed)    : NSColorFromRGB(0xFF2158),
                                 @(AMR_SGRCodeFgGreen)  : NSColorFromRGB(0x2ECC71),
                                 @(AMR_SGRCodeFgBlue)   : NSColorFromRGB(0x3498DB),
                                 @(AMR_SGRCodeFgYellow) : NSColorFromRGB(0xE5E500),
                                 @(AMR_SGRCodeFgCyan)   : NSColorFromRGB(0x00A6B2)
        } mutableCopy];
    }
    
    return self;
}

- (NSAttributedString *)decoratedLine:(NSString *)line {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setLineSpacing:5.0];

    NSMutableAttributedString *attrLine = [[self.helper attributedStringWithANSIEscapedString:line] mutableCopy];
    [attrLine addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrLine.length)];
    
    return attrLine;
}

@end
