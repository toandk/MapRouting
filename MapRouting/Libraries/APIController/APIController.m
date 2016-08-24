//
//  APIController.m
//  BaseProject
//
//  Created by Appota on 7/22/16.
//  Copyright © 2016 Appota. All rights reserved.
//

#import "APIController.h"
#import "AFHTTPRequestOperationManager.h"
#import "APIConstants.h"
#import "AFNetworkActivityLogger.h"

@implementation APIController


+ (instancetype)sharedController {
    static APIController * apiController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiController = [[APIController alloc] init];

#ifdef DEBUG
        [[AFNetworkActivityLogger sharedLogger] startLogging];
        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
        
    });
    
    return apiController;
}

- (id)init {
    if (self = [super init]) {

        _httpManager = [AFHTTPSessionManager manager];
        
        AFJSONResponseSerializer *responseManagerSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        _httpManager.responseSerializer = responseManagerSerializer;
        _httpManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[ @"GET", @"HEAD" ]];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",nil];
    }
    return self;
}


#pragma mark - api client methods

- (void)apiPOSTRequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler {
    [self POSTRequestWithUrl:url params:params completionHandler:completionHandler];
}

- (void)apiGETRequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler {
    [self GETRequestWithUrl:url params:params completionHandler:completionHandler];
}

- (void)POSTRequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler {
    [_httpManager POST:url parameters:params success:^(NSURLSessionDataTask * dataTask, id response) {
        if (completionHandler) {
            completionHandler(nil, response);
        }
    } failure:^(NSURLSessionDataTask * daaaztaTask, NSError * error) {
        if (completionHandler) {
            completionHandler(error, nil);
        }
    }];
}

- (void)GETRequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler {
    
    [_httpManager GET:url parameters:params success:^(NSURLSessionDataTask * dataTask, id response) {
        if (completionHandler) {
            completionHandler(nil, response);
        }
    } failure:^(NSURLSessionDataTask * dataTask, NSError * error) {
        if (completionHandler) {
            completionHandler(error, nil);
        }
    }];
}

- (void)DELETERequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler {
    [_httpManager DELETE:url parameters:params success:^(NSURLSessionDataTask * dataTask, id response) {
        if (completionHandler) {
            completionHandler(nil, response);
        }
    } failure:^(NSURLSessionDataTask * dataTask, NSError * error) {
        if (completionHandler) {
            completionHandler(error, nil);
        }
    }];
}

@end
