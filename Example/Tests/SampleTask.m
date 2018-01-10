//
//  SampleTask.m
//  DerivedRequest_Tests
//
//  Created by WeiHan on 14/12/2017.
//  Copyright © 2017 WeiHan. All rights reserved.
//

#import "SampleTask.h"

const NSUInteger HttpBinErrorCodeNone = 1;
#define Success(_response_) ((_response_).code == HttpBinErrorCodeNone)

NSString *const kSampleRequestHeaderKey = @"Key1";
NSString *const kSampleRequestHeaderValue = @"Value1";
NSString *const kSampleResponseContentType = @"application/json";

BaseResponse * GenerateResponseForHttpBinData(id responseObject, NSError *error);

#define kHttpBinDomain @"https://httpbin.org"

#pragma mark - SampleSessionManager

@interface SampleSessionManager : BaseSessionManager

@end

@implementation SampleSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    url = [NSURL URLWithString:kHttpBinDomain];

    if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];

        [self.requestSerializer setValue:kSampleRequestHeaderValue forHTTPHeaderField:kSampleRequestHeaderKey];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:kSampleResponseContentType];
    }

    return self;
}

@end

#pragma mark - SampleTask

@implementation SampleTask

+ (instancetype)task
{
    SampleTask *task = [super task];

    task.sessionManagerClass = [SampleSessionManager class];
    task.responseHandler = GenerateResponseForHttpBinData;

    return task;
}

#pragma mark - BaseSessionManagerDelegate (Override)

- (void)sessionManager:(BaseSessionManager *)sessionManager sendingRequest:(__kindof BaseRequest *)request
{
    NSLog(@"Sending request %@", request);
}

- (BaseResponse *)sessionManager:(BaseSessionManager *)sessionManager request:(__kindof BaseRequest *)request completeWithResponse:(id)responseObject task:(NSURLSessionDataTask *)task error:(NSError *)error
{
    BaseResponse *response = [super sessionManager:sessionManager request:request completeWithResponse:responseObject task:task error:error];

    if (error) {
        NSLog(@"Failed in task: %@, error: %@", request.requestURL, error.localizedDescription);
    } else if (!Success(response)) {
        NSLog(@"Request task is handled with error: %@, code: %ld. URL: %@", response.message, (long)response.code, request.requestURL);
    }

    return response;
}

- (void)sessionManager:(BaseSessionManager *)sessionManager finishRequest:(__kindof BaseRequest *)request
{
    NSLog(@"Finished request %@", request);
}

@end

#pragma mark - Functions

BaseResponse * GenerateResponseForHttpBinData(id responseObject, NSError *error)
{
    if (error || ![responseObject isKindOfClass:[NSDictionary class]]) {
        return CreateResponse(responseObject, error ? 400 : 0, error.localizedDescription, nil, error);
    }

    return CreateResponse(responseObject, error ? -1 : HttpBinErrorCodeNone, nil, responseObject, error);
}
