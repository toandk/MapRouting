//
//  CustomPlaceholderTextField.m
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "CustomPlaceholderTextField.h"

@implementation CustomPlaceholderTextField

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self setupPlaceHolder];
}

- (void) setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    [self setupPlaceHolder];
}

- (void)setupPlaceHolder {
    if (!self.placeholderColor) return;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
}

@end
