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

@property (nonatomic, strong, readonly) NSDictionary *originDictionary;
@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, assign, readonly) NSUInteger code;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, strong, readonly) id data;

@end

typedef BaseResponse * (*NetworkResponseDataHandler)(BaseRequest *request, id responseObject, NSError *error);

BaseResponse * CreateResponse(NSDictionary *originDictionary, NSUInteger code, NSString *message, id data, NSError *error);
