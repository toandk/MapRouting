//
//  SearchRecentModelFactory.m
//  MapRouting
//
//  Created by admin on 8/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SearchRecentModelFactory.h"
#import "SearchRecentModel.h"

@implementation SearchRecentModelFactory

+ (NSArray*)getListSavedRecentModel {
    RLMResults<SearchRecentModel *> *list = [SearchRecentModel allObjects];
    NSMutableArray *listRecent = [NSMutableArray array];
    for (SearchRecentModel *recent in list) [listRecent addObject:recent];
    return listRecent;
}

+ (BOOL)isSearchPredictionExisted:(GMSAutocompletePrediction*)prediction {
    if ([SearchRecentModel objectsWhere:[NSString stringWithFormat:@"placeID == '%@'", prediction.placeID]].count > 0) return YES;
    return NO;
}

+ (void)saveSearchPrediction:(GMSAutocompletePrediction*)prediction {
    if ([self isSearchPredictionExisted:prediction]) return;
    RLMRealm *realm = [RLMRealm defaultRealm];
    SearchRecentModel *recentModel = [[SearchRecentModel alloc] initWithPrediction:prediction];
    [realm beginWriteTransaction];
    [realm addObject:recentModel];
    [realm commitWriteTransaction];
}


@end
