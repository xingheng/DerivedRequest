//
//  BaseSessionManager.m
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import "BaseSessionManager.h"
#import "BaseResponse.h"

#pragma mark - BaseRequest

@interface BaseRequest ()

@property (nonatomic, strong) id<BaseSessionManagerDelegate> delegate;

@end

@implementation BaseRequest

+ (instancetype)requestWithBlock:(void (^)(BaseRequest *))block
{
    BaseRequest *request = [BaseRequest new];

    if (block) {
        block(request);
    }

    return request;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: URL: %@, method: %@, parameters: %@", NSStringFromClass([self class]),
            self.requestURL, HTTPMethodString(self.method), self.parameters];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    BaseRequest *request = [[self class] allocWithZone:zone];

    if (request) {
        request.requestURL = [self.requestURL copyWithZone:zone];
        request.method = self.method;
        request.parameters = [self.parameters copyWithZone:zone];
        request.headerConfiguration = [self.headerConfiguration copy];
        request.progress = [self.progress copy];
        request.completion = [self.completion copy];
        request.isBatchTask = self.isBatchTask;
    }

    return request;
}

@end


#pragma mark - BaseSessionManager

@interface BaseSessionManager ()

@property (nonatomic, strong) NSMutableArray<BaseRequest *> *requests;

@end

@implementation BaseSessionManager

#pragma mark - Public

- (void)sendRequest:(BaseRequest *)request delegate:(id<BaseSessionManagerDelegate>)delegate
{
    if (request.isBatchTask) {
        return;
    }

    request.delegate = delegate;
    [self.requests addObject:request];

    if (request.headerConfiguration) {
        request.headerConfiguration(self.requestSerializer);
    }

    if ([delegate respondsToSelector:@selector(sessionManager:sendingRequest:)]) {
        [delegate sessionManager:self sendingRequest:request];
    }

    NSString *requestURL = request.requestURL;
    HTTPMethod method = request.method;
    id parameters = request.parameters;
    NetworkTaskProgress taskProgress = request.progress;

    __weak typeof(self) weakSelf = self;

    id successBlock = ^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _responseCallback:task request:request response:responseObject error:nil];
    };

    id failureBlock = ^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _responseCallback:task request:request response:nil error:error];
    };

    if (taskProgress && (method == HTTPMethodPut || method == HTTPMethodDelete)) {
        NSLog(@"taskProgress is invalid for PUT and DELETE request!");
    }

    switch (method) {
        case HTTPMethodGet:
            [self      GET:requestURL
                parameters:parameters
                  progress:taskProgress
                   success:successBlock
                   failure:failureBlock];
            break;

        case HTTPMethodPost:
            [self POST:requestURL
            parameters:parameters
              progress:taskProgress
               success:successBlock
               failure:failureBlock];
            break;

        case HTTPMethodPut:
            [self      PUT:requestURL
                parameters:parameters
                   success:successBlock
                   failure:failureBlock];
            break;

        case HTTPMethodDelete:
            [self DELETE:requestURL
              parameters:parameters
                 success:successBlock
                 failure:failureBlock];
            break;
    }
}

#pragma mark - Property

- (NSMutableArray<BaseRequest *> *)requests
{
    if (!_requests) {
        _requests = [NSMutableArray new];
    }

    return _requests;
}

#pragma mark - Private

- (void)_responseCallback:(NSURLSessionDataTask *)task request:(BaseRequest *)request response:(id)responseObject error:(NSError *)error
{
    BaseResponse *response = nil;

    id<BaseSessionManagerDelegate> delegate = request.delegate;

    if (delegate) {
        response = [delegate sessionManager:self request:request completeWithResponse:responseObject task:task error:error];
    } else {
        response = responseObject ? : error;
        NSLog(@"No delegate to handle this response! %@. %@. %@", request, response, error);
    }

    if ([delegate respondsToSelector:@selector(sessionManager:resolveRequest:response:)]) {
        id context = [delegate sessionManager:self resolveRequest:request response:response];

        if (context) {
            [response markAsResolved:context];
        }
    }

    if (request.completion) {
        request.completion(response);
    }

    // Make sure the BaseSessionManager itself could be release after finishing all the tasks.
    // https://github.com/AFNetworking/AFNetworking/issues/2149
    [self invalidateSessionCancelingTasks:NO];

    if ([delegate respondsToSelector:@selector(sessionManager:finishRequest:response:)]) {
        [delegate sessionManager:self finishRequest:request response:response];
    }

    // Once the request completion is done, release the strong delegate reference explictly.
    request.delegate = nil;
    [self.requests removeObject:request];
}

@end


#pragma mark - Functions

NSString * HTTPMethodString(HTTPMethod method)
{
    switch (method) {
        case HTTPMethodGet:
            return @"GET";

        case HTTPMethodPost:
            return @"POST";

        case HTTPMethodPut:
            return @"PUT";

        case HTTPMethodDelete:
            return @"DELETE";

        default:
            return nil;
    }
}
