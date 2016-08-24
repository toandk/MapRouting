//
//  BaseUIView.h
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseUIView : UIView

+ (NSString*) nibName;

+ (instancetype) createViewFromNib;

@end
