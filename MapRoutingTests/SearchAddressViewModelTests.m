//
//  SearchAddressViewModelTests.m
//  MapRouting
//
//  Created by admin on 8/23/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppConfig.h"
#import "SearchAddressViewModel.h"
#import "FakeGMSPrediction.h"

SpecBegin(SearchAddressViewModel)

__block SearchAddressViewModel *viewModel = nil;
__block SearchAddressServices *_searchServices;
__block DTPlace *defaultPlace;
__block DTPlace *currentPlace;

beforeAll(^{
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
    _searchServices = [[SearchAddressServices alloc] init];
});

describe(@"init", ^{
    beforeAll(^{
        defaultPlace = [[DTPlace alloc] init];
        viewModel = [[SearchAddressViewModel alloc] initWithServices:_searchServices withModel:defaultPlace];
    });
    
    it(@"should assert that location service is not nil", ^{
        expect(viewModel.defaultPlace).to.beTruthy();
        expect(viewModel.services).to.beTruthy();
        expect(viewModel.executeSearchCommand).to.beTruthy();
    });
});

describe(@"Search result", ^{
    
    beforeAll(^ {
        viewModel = [[SearchAddressViewModel alloc] initWithServices:_searchServices withModel:nil];
    });
    
    it (@"Should assert that search results is not nil", ^{
        viewModel.searchText = @"Tran phu";
        NSError *error = nil;
        BOOL success = [[viewModel.executeSearchCommand execute:nil] asynchronouslyWaitUntilCompleted:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(viewModel.searchResults).to.beTruthy();
    });
});

describe(@"Select a prediction", ^{
    __block FakeGMSPrediction *prediction;
    
    beforeAll(^ {
        prediction = [[FakeGMSPrediction alloc] init];
        prediction.placeID = @"EhtUcuG6p24gUGjDuiwgSGFub2ksIFZpZXRuYW0";
        viewModel = [[SearchAddressViewModel alloc] initWithServices:_searchServices withModel:nil];
    });
    
    it (@"Should assert that selectedPlace is not nil", ^{
        NSError *error = nil;
        BOOL success = [[[viewModel getSelectionAddressCommand] execute:prediction] asynchronouslyWaitUntilCompleted:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(viewModel.selectedPlace).to.beTruthy();
    });
});

describe(@"Select current place", ^{
    
    beforeAll(^ {
        currentPlace = [[DTPlace alloc] init];
        viewModel = [[SearchAddressViewModel alloc] initWithServices:_searchServices withModel:nil];
        viewModel.currentPlace = currentPlace;
    });
    
    it (@"Should assert that selectedPlace is equal currentPlace", ^{
        NSError *error = nil;
        BOOL success = [[[viewModel getChoosingCurrentLocationCommand] execute:nil] asynchronouslyWaitUntilCompleted:&error];
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(viewModel.selectedPlace).to.equal(currentPlace);
    });
});

SpecEnd
