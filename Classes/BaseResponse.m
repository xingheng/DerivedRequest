//
//  BaseResponse.m
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import "BaseResponse.h"

@interface BaseResponse ()

@property (nonatomic, strong) NSDictionary *originDictionary;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) NSUInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;

@end

@implementation BaseResponse

- (NSString *)description
{
    return [NSString stringWithFormat:@"Response: code: %ld, message: %@, data: %@", (long)self.code, self.message, self.data];
}

#pragma mark - Property

- (NSString *)message
{
    if (!_message) {
        _message = self.error.localizedDescription;
    }

    return _message;
}

@end

BaseResponse * CreateResponse(NSDictionary *originDictionary, NSUInteger code, NSString *message, id data, NSError *error)
{
    BaseResponse *response = [BaseResponse new];

    response.originDictionary = originDictionary;
    response.code = code;
    response.message = message;
    response.data = data;
    response.error = error;

    return response;
}
