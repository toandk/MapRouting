//
//  MapRoutingViewModel.m
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "MapRoutingViewModel.h"
#import <GoogleMaps/GoogleMaps.h>
#import "APIController+Map.h"
#import "LocationManager.h"
#import "AppConfig.h"
#import "APIController+Map.h"

@interface MapRoutingViewModel () {
    GMSPlacesClient *placeClient;
}

@end

@implementation MapRoutingViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _transportMode = DTTransportingModeDriving;
    placeClient = [GMSPlacesClient sharedClient];
    
    [self initCurrentPlaceCommand];
    [self initReverseDirectionCommand];
    [self initLoadingMapRoutingSignal];
    [self initMapRoutingCommand];
}

- (void)initReverseDirectionCommand {
    self.reverseDirectionCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self getReverseDirectionSignal];
    }];
}

- (void)initCurrentPlaceCommand {
    [[LocationManager sharedManager] askingPermissionScope];
    
    self.currentPlaceCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self getCurrentPlaceSignal];
    }];
}

- (void)initMapRoutingCommand {
    self.loadMapRoutingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return self.loadingMapRoutingSignal;
    }];
}

- (void)initLoadingMapRoutingSignal {
    @weakify(self);
    self.loadingMapRoutingSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *mode = getTransportType(self.transportMode);
        [[APIController sharedController] getMapDirectionFrom:self.startPlace to:self.stopPlace withMode:mode completionHandler:^(NSError *error, NSDictionary *response) {
            @strongify(self);
            if (!error) {
                if (response[@"routes"] && [response[@"routes"] count] > 0) {
                    NSString *encodedPoints = response[@"routes"][0][@"overview_polyline"][@"points"];
                    self.encodedRoutingPoints = encodedPoints;
                }
                else {
                    self.encodedRoutingPoints = NO_ROUTE_KEY;
                }
                [subscriber sendNext:self.encodedRoutingPoints];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
                self.encodedRoutingPoints = NO_ROUTE_KEY;
            }
        }];
        
        return nil;
    }];
}

#pragma mark Setters
- (void)setStartPlace:(DTPlace *)startPlace {
    _startPlace = startPlace;
    if (_startPlace && _stopPlace)
        [self.loadMapRoutingCommand execute:nil];
}

- (void)setStopPlace:(DTPlace *)stopPlace {
    _stopPlace = stopPlace;
    if (_startPlace && _stopPlace)
        [self.loadMapRoutingCommand execute:nil];
}

- (void)setTransportMode:(DTTransportingMode)transportMode {
    _transportMode = transportMode;
    if (_startPlace && _stopPlace)
        [self.loadMapRoutingCommand execute:nil];
}

- (void)changeLocation:(CLLocationCoordinate2D)location forStartPlace:(BOOL)isStartPlace {
    @weakify(self);
    [[APIController sharedController] searchFirstPlaceWithLocation:location completionHandler:^(NSError *error, id object) {
        @strongify(self);
        DTPlace *newPlace = [[DTPlace alloc] init];
        newPlace.coordinate = location;
        if (object) {
            newPlace.name = object[@"name"];
            newPlace.placeID = object[@"place_id"];
        }
        else {
            newPlace.name = [NSString stringWithFormat:@"(%f, %f)", location.latitude, location.longitude];
        }
        if (isStartPlace) {
            self.startPlace = newPlace;
        }
        else self.stopPlace = newPlace;
    }];
}

#pragma mark Getters

- (RACSignal*)getReverseDirectionSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        DTPlace *place = self.startPlace;
        self.startPlace = self.stopPlace;
        self.stopPlace = place;
        [subscriber sendNext:@(YES)];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

- (RACSignal*)getCurrentPlaceSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [placeClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
            if (likelihoodList.likelihoods.count > 0) {
                @strongify(self);
                self.currentPlace = [[DTPlace alloc] initWithGMSPlace:[likelihoodList.likelihoods[0] place]];
                [LocationManager sharedManager].currentLocation = self.currentPlace.coordinate;
                
                if (!self.startPlace)
                    self.startPlace = self.currentPlace;
                [subscriber sendNext:self.startPlace];
                [subscriber sendCompleted];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

- (SearchAddressViewModel*)getAddressPickerViewModel:(DTPlace*)place {
    SearchAddressServices *_searchServices = [[SearchAddressServices alloc] init];
    SearchAddressViewModel *viewModel = [[SearchAddressViewModel alloc] initWithServices:_searchServices withModel:place];
    viewModel.currentPlace = self.currentPlace;
    return viewModel;
}

@end
