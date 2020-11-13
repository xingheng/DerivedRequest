//
//  BaseResponse.h
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseRequest;

@interface BaseResponse : NSObject

@property (nonatomic, strong, readonly, nonnull) id rawData;
@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, assign, readonly) NSUInteger code;
@property (nonatomic, copy, readonly, nullable) NSString *message;
@property (nonatomic, strong, readonly, nullable) id data;

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error;

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error
                            code:(NSUInteger)code
                         message:(NSString *)message
                            data:(id)data;

@end

typedef BaseResponse * (*NetworkResponseDataHandler)(BaseRequest *request, id responseObject, NSError *error);
typedef BOOL (*NetworkResponseInterceptor)(BaseRequest *request, BaseResponse *response);
