//
//  MapRoutingViewModelTests.m
//  MapRouting
//
//  Created by admin on 8/23/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "MapRoutingViewModel.h"
#import "AppConfig.h"
#import <GoogleMaps/GoogleMaps.h>

SpecBegin(MapRoutingViewModel)

__block MapRoutingViewModel *viewModel = nil;

beforeAll(^{
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
});

describe(@"initialize", ^{
    beforeAll(^{
        viewModel = [[MapRoutingViewModel alloc] init];
    });
    
    it(@"should assert that location service is not nil", ^{
        expect(viewModel.transportMode).to.equal(@(DTTransportingModeDriving));
        expect(viewModel.currentPlaceCommand).to.beTruthy();
        expect(viewModel.reverseDirectionCommand).to.beTruthy();
        expect(viewModel.loadMapRoutingCommand).to.beTruthy();
    });
});

describe(@"reverse direction", ^{
    __block DTPlace *stopPlace = nil;
    __block DTPlace *startPlace = nil;
    
    beforeAll(^ {
        viewModel = [[MapRoutingViewModel alloc] init];
        startPlace = [[DTPlace alloc] init];
        stopPlace = [[DTPlace alloc] init];
        viewModel.startPlace = startPlace;
        viewModel.stopPlace = stopPlace;
    });
    
    it (@"Should assert that reverse start and stop place is ok", ^{
        NSError *error = nil;
        RACSignal *resultSignal = [viewModel.reverseDirectionCommand execute:nil];
        BOOL success = [resultSignal asynchronouslyWaitUntilCompleted:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(viewModel.startPlace).to.equal(stopPlace);
        expect(viewModel.stopPlace).to.equal(startPlace);
    });
});

describe(@"Load map routing", ^{
    __block DTPlace *stopPlace = nil;
    __block DTPlace *startPlace = nil;
    
    beforeAll(^ {
        viewModel = [[MapRoutingViewModel alloc] init];
        viewModel.encodedRoutingPoints = NO_ROUTE_KEY;
        startPlace = [[DTPlace alloc] init];
        startPlace.coordinate = CLLocationCoordinate2DMake(21.001315, 105.817504);
        stopPlace = [[DTPlace alloc] init];
        stopPlace.coordinate = CLLocationCoordinate2DMake(20.972324, 105.884813);
    });
    
    it (@"Should assert that encodedRoutingPoints is found", ^{
        viewModel.startPlace = startPlace;
        viewModel.stopPlace = stopPlace;
        
        NSError *error = nil;
        BOOL success = [viewModel.loadingMapRoutingSignal asynchronouslyWaitUntilCompleted:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(viewModel.mapBounds).to.beTruthy();
        expect(viewModel.encodedRoutingPoints).notTo.equal(NO_ROUTE_KEY);
    });
    
    it (@"Should assert that encodedRoutingPoints is NO_ROUTE_KEY", ^{
        viewModel.transportMode = DTTransportingModeTransit;
        stopPlace.coordinate = CLLocationCoordinate2DMake(34.112603, -118.283608);
        viewModel.startPlace = startPlace;
        viewModel.stopPlace = stopPlace;
        
        NSError *error = nil;
        BOOL success = [viewModel.loadingMapRoutingSignal asynchronouslyWaitUntilCompleted:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(viewModel.encodedRoutingPoints).to.equal(NO_ROUTE_KEY);
    });
});

SpecEnd
