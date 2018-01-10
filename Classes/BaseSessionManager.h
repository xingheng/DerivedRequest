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
typedef void (^DataTaskCompletion)(BaseResponse *response, NSURLSessionDataTask *task);

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

- (BaseResponse *)sessionManager:(BaseSessionManager *)sessionManager request:(__kindof BaseRequest *)request completeWithResponse:(id)responseObject task:(NSURLSessionDataTask *)task error:(NSError *)error;

- (void)sessionManager:(BaseSessionManager *)sessionManager finishRequest:(__kindof BaseRequest *)request;

@end

#pragma mark - BaseSessionManager

@interface BaseSessionManager : AFHTTPSessionManager

/**
   Send the request with corresponding delegate.

   @note Both the request and delegate will be retained till the request get response.

   @param request     The request to be sent
   @param delegate    The delegate used for the request status
 */
- (void)sendRequest:(BaseRequest *)request delegate:(id<BaseSessionManagerDelegate>)delegate;

@end
