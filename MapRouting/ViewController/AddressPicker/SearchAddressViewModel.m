//
//  SearchAddressViewModel.m
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SearchAddressViewModel.h"


@interface SearchAddressViewModel ()

@end

@implementation SearchAddressViewModel

- (instancetype) initWithServices:(SearchAddressServices*)services withModel:(DTPlace*)place {
    if (self) {
        _services = services;
        _defaultPlace = place;
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    _validSearchSignal =
    [[RACObserve(self, searchText)
      map:^id(NSString *text) {
          return @(text.length >= 2);
      }]
     delay:0.5];
    
    [_validSearchSignal subscribeNext:^(id value) {
        if ([value boolValue]) {
            [[self executeSearchSignal]
             subscribeNext:^(id x) {
                 
             }];
        }
    }];
    
    self.executeSearchCommand = [[RACCommand alloc] initWithEnabled:_validSearchSignal
                                                 signalBlock:^RACSignal *(id input) {
                                                     return [self executeSearchSignal];
                                                 }];
    
}

- (RACSignal *)executeSearchSignal {
    return [[self.services
             getSearchSignalWithKeyword:self.searchText]
            doNext:^(id results) {
                self.searchResults = results;
            }];
}

- (RACCommand*)getSelectionAddressCommand {
    @weakify(self)
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [[self.services getPlaceInfoSignalWithPlace:[input placeID]]
                doNext:^(id x) {
                    self.selectedPlace = [[DTPlace alloc] initWithGMSPlace:x];
                }];
        
    }];
}

- (RACCommand*)getChoosingCurrentLocationCommand {
    @weakify(self)
    return [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.selectedPlace = self.currentPlace;
        
        return [RACSignal empty];
    }];
}

@end
