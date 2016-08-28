//
//  SearchAddressViewModel.h
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "BaseViewModel.h"
#import "SearchAddressServices.h"
#import <GooglePlaces/GooglePlaces.h>
#import "DTPlace.h"

@interface SearchAddressViewModel : BaseViewModel

@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) RACCommand *executeSearchCommand;
@property (strong, nonatomic) RACSignal *validSearchSignal;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSArray *searchHistories;
@property (strong, nonatomic) DTPlace *selectedPlace;
@property (strong, nonatomic) DTPlace *defaultPlace;
@property (strong, nonatomic) DTPlace *currentPlace;
@property (nonatomic, strong) SearchAddressServices *services;

- (instancetype) initWithServices:(SearchAddressServices*)services withModel:(DTPlace*)place;

- (RACCommand*)getSelectionAddressCommand;

- (RACCommand*)getSelectionHistorySearchCommand;

- (RACCommand*)getChoosingCurrentLocationCommand;

- (RACSignal *)executeSearchSignal;

@end
