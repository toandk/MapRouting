//
//  SearchRecentModel.m
//  MapRouting
//
//  Created by admin on 8/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SearchRecentModel.h"

@implementation SearchRecentModel

- (id)initWithPrediction:(GMSAutocompletePrediction*)prediction {
    if (self = [super init]) {
        self.placeID = prediction.placeID;
        self.name = [prediction.attributedPrimaryText string];
        self.address = [prediction.attributedSecondaryText string];
    }
    return self;
}

@end
