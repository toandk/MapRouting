//
//  APIController+Map.h
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "APIController.h"
#import "DTPlace.h"

@interface APIController (Map)

- (void)getMapDirectionFrom:(DTPlace*)startPoint
                         to:(DTPlace*)stopPoint
                   withMode:(NSString*)mode
          completionHandler:(GCAPIResponseBlock)completionHandler;

- (void)searchFirstPlaceWithLocation:(CLLocationCoordinate2D)location
                   completionHandler:(GCAPIResponseBlock)completionHandler;

@end
