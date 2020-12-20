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

BaseResponse * GenerateResponseForHttpBinData(BaseRequest *request, id responseObject, NSError *error);
id ResolveResponseForHttpBinData(BaseRequest *request, BaseResponse *response);

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

    task.responseHandler = GenerateResponseForHttpBinData;
    task.responseInterceptor = ResolveResponseForHttpBinData;
    task.sessionManagerClass = [SampleSessionManager class];

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

BaseResponse * GenerateResponseForHttpBinData(BaseRequest *request, id responseObject, NSError *error)
{
    if (error || ![responseObject isKindOfClass:[NSDictionary class]]) {
        return [BaseResponse responseWithData:responseObject error:error code:error.code message:nil data:nil];
    }

    return [BaseResponse responseWithData:responseObject error:error code:error ? -1 : HttpBinErrorCodeNone message:nil data:responseObject];
}

id ResolveResponseForHttpBinData(BaseRequest *request, BaseResponse *response)
{
    if (response.code == 403) {
        return @"Pretend to handle the current authenzation error globally.";
    }

    // Return nil just let it go.
    return nil;
}
