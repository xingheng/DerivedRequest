//
//  DerivedRequestTests.m
//  DerivedRequestTests
//
//  Created by Wei Han on 12/14/2017.
//  Copyright (c) 2017 WeiHan. All rights reserved.
//

@import XCTest;
#import <DerivedRequest/GenericTask.h>
#import "SampleTask.h"

@interface Tests : XCTestCase

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    self.semaphore = dispatch_semaphore_create(0);
}

- (void)tearDown
{
    // https://github.com/AFNetworking/AFNetworking/issues/466#issuecomment-7926896
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    self.semaphore = nil;
    [super tearDown];
}

- (void)fulfillRequest
{
    dispatch_semaphore_signal(self.semaphore);
}

- (void)testRequestURL
{
    SampleTask *task = [SampleTask task];

    [task sendRequest:@"get"
               method:HTTPMethodGet
           parameters:nil
           completion:^(BaseResponse *response) {
        XCTAssertTrue([response.originDictionary[@"url"] containsString:@"get"]);
        [self fulfillRequest];
    }];
}

- (void)testRequestHeaders
{
    SampleTask *task1 = [SampleTask task];
    SampleTask *task2 = [SampleTask task];

    __block BaseResponse *response1, *response2;

    void (^ completion)(BaseResponse *response) = ^(BaseResponse *response) {
        if (!response1) {
            response1 = response;
        } else if (!response2) {
            response2 = response;
        }

        if (response1 && response2) {
            NSDictionary *headers = response1.originDictionary[@"headers"];

            XCTAssertTrue([headers.allKeys containsObject:kSampleRequestHeaderKey]);
            XCTAssertTrue([headers.allValues containsObject:kSampleRequestHeaderValue]);

            XCTAssertEqualObjects(headers, response2.originDictionary[@"headers"]);

            [self fulfillRequest];
        }
    };

    [task1 sendRequest:@"headers"
                method:HTTPMethodGet
            parameters:nil
            completion:completion];

    [task2 sendRequest:@"headers"
                method:HTTPMethodGet
            parameters:nil
            completion:completion];
}

- (void)testGenericTask
{
    NewGenericTask().setSessionManager(^BaseSessionManager *() {
        return [[BaseSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://httpbin.org/"]];
    }).sendRequest(^(BaseRequest *request) {
        request.method = HTTPMethodGet;
        request.requestURL = @"ip";
    }).progress(^(NSProgress *progress) {
        XCTAssertEqual(progress.completedUnitCount, progress.totalUnitCount);
    }).taskCompleted(^(BaseResponse *response, NSURLSessionDataTask *task) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        XCTAssertEqual(resp.statusCode, 200);
    }).completion( ^(BaseResponse *response) {
        XCTAssertTrue([response.originDictionary.allKeys containsObject:@"origin"]);
        [self fulfillRequest];
    }).send();
}

@end
