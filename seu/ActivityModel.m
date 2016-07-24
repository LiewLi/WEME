//
//  ActivityModel.m
//  牵手东大
//
//  Created by liewli on 12/9/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import "ActivityModel.h"
#import "NSValueTransformer+Model.h"

@implementation ActivityModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"activityID":@"id",
             @"title":@"title",
             @"time":@"time",
             @"location":@"location",
             @"capacity":@"number",
             @"state":@"state",
             @"signnumber":@"signnumber",
             @"remark":@"remark",
             @"author":@"author",
             @"detail":@"detail",
             @"advertise":@"advertise",
             @"needsImage":@"whetherimage",
             @"likeFlag":@"likeflag",
             @"authorID":@"authorid",
             @"school":@"school",
             @"poster":@"imageurl",
             @"status":@"status",
             @"activityState":@"timestate",
             @"passState":@"passState",
             @"sponsor":@"sponsor",
             @"top":@"top"
             };
}

+ (NSValueTransformer *) topJSONTransformer {
    return  [NSValueTransformer valueTransformerForName:FlagBoolValueTransformer];
}

+ (NSValueTransformer *) posterJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [[NSURL alloc]initWithString:value];
    }];
}

+ (NSValueTransformer *) needsImageJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([value isEqualToNumber:@(1)]) {
                return @YES;
            }
            else {
                return @NO;
            }
        }
        else if ([value isKindOfClass:[NSString class]]){
            if ([value isEqualToString:@"1"]) {
                return @YES;
            }
            else {
                return @NO;
            }
        }
        else {
            return @NO;
        }
        
    }];
}
+ (NSValueTransformer *) likeFlagJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([value isEqualToNumber:@(1)]) {
                return @YES;
            }
            else {
                return @NO;
            }
        }
        else if ([value isKindOfClass:[NSString class]]){
            if ([value isEqualToString:@"1"]) {
                return @YES;
            }
            else {
                return @NO;
            }
        }
        else {
            return @NO;
        }
    }];
}

+ (NSValueTransformer *) stateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isEqualToString:@"yes"]) {
            return @YES;
        }
        else return @NO;
    }];
}

+ (NSValueTransformer *) authorIDJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", value];
        }
        else if ([value isKindOfClass:[NSString class]]){
            return value;
        }
        else {
            return @"";
        }
        
    }];
}

+ (NSValueTransformer *) capacityJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", value];
        }
        else if ([value isKindOfClass:[NSString class]]){
            return value;
        }
        else {
            return @"";
        }
        
    }];
}

+ (NSValueTransformer *) activityIDJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", value];
        }
        else if ([value isKindOfClass:[NSString class]]){
            return value;
        }
        else {
            return @"";
        }
        
    }];
}

+ (NSValueTransformer *) signnumberJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", value];
        }
        else if ([value isKindOfClass:[NSString class]]){
            return value;
        }
        else {
            return @"";
        }
        
    }];
}


@end
