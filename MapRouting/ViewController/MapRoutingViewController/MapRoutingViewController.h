//
//  MapRoutingViewController.h
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "BaseViewController.h"
#import "MapRoutingViewModel.h"

@interface MapRoutingViewController : BaseViewController {
    __weak IBOutlet GMSMapView *myMapView;
    __weak IBOutlet UITextField *startPointTextField, *stopPointTextField;
    __weak IBOutlet UIButton *reverveDirectionButton;
    IBOutletCollection(UIButton) NSArray *listTransportButton;
}
@property (nonatomic, strong) MapRoutingViewModel *viewModel;

@end
