//
//  BaseUIView.m
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "BaseUIView.h"

@implementation BaseUIView

+ (NSString*) nibName {
    NSString *name = NSStringFromClass([self class]);
    return name;
}

+ (instancetype) createViewFromNib {
    return [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:nil options:nil][0];
}

@end
