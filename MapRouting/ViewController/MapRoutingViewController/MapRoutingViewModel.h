//
//  MapRoutingViewModel.h
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "BaseViewModel.h"
#import <GooglePlaces/GooglePlaces.h>
#import <CoreLocation/CoreLocation.h>
#import "SearchAddressViewModel.h"
#import "DTPlace.h"

typedef enum {
    DTTransportingModeDriving = 0,
    DTTransportingModeTransit,
    DTTransportingModeWalking,
    DTTransportingModeBicycling,
} DTTransportingMode;

#define getTransportType(type) [@[@"driving",@"transit",@"walking",@"bicycling"] objectAtIndex:type]

@interface MapRoutingViewModel : BaseViewModel

@property (nonatomic, assign) DTTransportingMode transportMode;
@property (nonatomic, strong) DTPlace *startPlace;
@property (nonatomic, strong) DTPlace *stopPlace;
@property (nonatomic, strong) DTPlace *currentPlace;
@property (nonatomic, strong) RACCommand *currentPlaceCommand;
@property (nonatomic, strong) RACCommand *loadMapRoutingCommand;
@property (nonatomic, strong) RACCommand *reverseDirectionCommand;
@property (nonatomic, strong) RACSignal *loadingMapRoutingSignal;
@property (nonatomic, strong) NSString *encodedRoutingPoints;

- (SearchAddressViewModel*)getAddressPickerViewModel:(DTPlace*)place;

- (RACSignal*)getCurrentPlaceSignal;

@end
