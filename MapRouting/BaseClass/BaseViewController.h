//
//  BaseViewController.h
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

+ (NSString*) nibName;

- (id) initUsingNib;

- (void)showAlertWithTitle:(NSString*)title withMessage:(NSString*)message;

@end
