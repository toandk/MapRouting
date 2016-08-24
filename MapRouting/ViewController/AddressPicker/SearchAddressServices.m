
//
//  SearchAddressServices.m
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SearchAddressServices.h"

#import <ReactiveCocoa/RACEXTScope.h>



@interface SearchAddressServices ()<GMSAutocompleteFetcherDelegate> {
    GMSAutocompleteFetcher* _fetcher;
    
    DTSearchBlock searchCompleteBlock;
}

@end

@implementation SearchAddressServices

- (instancetype)init {
    if (self = [super init]) {
        [self setupFetcher];
    }
    return self;
}

- (void)setupFetcher {
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:nil
                                                       filter:filter];
    _fetcher.delegate = self;
}

- (void)searchWithKeyword:(NSString*)keyword withCompleteHandler:(DTSearchBlock)block {
    [_fetcher sourceTextHasChanged:keyword];
    searchCompleteBlock = block;
}

- (void)getPlaceInfo:(GMSAutocompletePrediction*)prediction withCompleteHandler:(DTSearchBlock)block {
    [[GMSPlacesClient sharedClient] lookUpPlaceID:prediction.placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        block(result, error);
    }];
}

- (RACSignal*)getPlaceInfoSignalWithPlace:(NSString*)placeId {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[GMSPlacesClient sharedClient] lookUpPlaceID:placeId callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
            if (!error) {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{}];
    }];
}

- (RACSignal*)getSearchSignalWithKeyword:(NSString*)keyword {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self searchWithKeyword:keyword withCompleteHandler:^(id object, NSError *error) {
            if (!error) {
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
}

#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    // predictions is an array of GMSAutocompletePrediction
    searchCompleteBlock(predictions, nil);
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    searchCompleteBlock(nil, error);
}

@end
