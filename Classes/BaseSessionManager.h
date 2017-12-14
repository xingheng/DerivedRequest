//
//  BaseSessionManager.h
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM (NSInteger, HTTPMethod) {
    HTTPMethodGet,
    HTTPMethodPost,
    HTTPMethodPut,
    HTTPMethodDelete
};

NSString * HTTPMethodString(HTTPMethod method);

@class BaseSessionManager, BaseResponse;

typedef void (^NetworkTaskProgress)(NSProgress *progress);
typedef void (^NetworkTaskCompletion)(BaseResponse *response);


#pragma mark - BaseRequest

@interface BaseRequest : NSObject <NSCopying>

@property (nonatomic, strong) NSString *requestURL;

@property (nonatomic, assign) HTTPMethod method;

@property (nonatomic, strong) id parameters;

@property (nonatomic, copy) NetworkTaskProgress progress;

@property (nonatomic, copy) NetworkTaskCompletion completion;

@property (nonatomic, assign) BOOL isBatchTask;

+ (instancetype)requestWithBlock:(void (^)(BaseRequest *))block;

@end

#pragma mark - BaseSessionManagerDelegate

@protocol BaseSessionManagerDelegate <NSObject>

- (void)sessionManager:(BaseSessionManager *)sessionManager sendingRequest:(__kindof BaseRequest *)request;

- (BaseResponse *)sessionManager:(BaseSessionManager *)sessionManager request:(__kindof BaseRequest *)request completeWithResponse:(id)responseObject error:(NSError *)error;

- (void)sessionManager:(BaseSessionManager *)sessionManager finishRequest:(__kindof BaseRequest *)request;

@end

#pragma mark - BaseSessionManager

@interface BaseSessionManager : AFHTTPSessionManager

@property (nonatomic, strong /* I mean it */) id<BaseSessionManagerDelegate> delegate;

- (void)sendRequest:(BaseRequest *)request;

- (void)finishRequest:(BaseRequest *)request;

@end
