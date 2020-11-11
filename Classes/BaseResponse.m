//
//  BaseResponse.m
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import "BaseResponse.h"

@interface BaseResponse ()

@property (nonatomic, strong) id rawData;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) NSUInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;

@end

@implementation BaseResponse

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error
{
    return [self responseWithData:rawData error:error code:0 message:nil data:nil];
}

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error
                            code:(NSUInteger)code
                         message:(NSString *)message
                            data:(id)data
{
    BaseResponse *response = [BaseResponse new];

    response.rawData = rawData;
    response.error = error;
    response.code = code;
    response.message = message;
    response.data = data;

    return response;
}

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
