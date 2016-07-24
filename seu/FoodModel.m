//
//  FoodModel.m
//  WEME
//
//  Created by liewli on 2016-01-15.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "FoodModel.h"

@implementation FoodModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ID":@"id",
             @"title":@"title",
             @"location":@"location",
             @"author":@"author",
             @"authorid":@"authorid",
             @"price":@"price",
             @"comment":@"comment",
             @"longitude":@"longitude",
             @"latitude":@"latitude",
             @"likeNumber":@"likenumber",
             @"imageURL":@"imageurl",
             @"likeflag":@"likeflag"
             };
}


+ (NSValueTransformer *) likeflagJSONTransformer {
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


+ (NSValueTransformer *) imageURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)authoridJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", value];
        }
        else {
            return @"";
        }
        
    }];
}

+ (NSValueTransformer *)IDJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", value];
        }
        else {
            return @"";
        }
        
    }];
}

+ (NSValueTransformer *)likeNumberJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return @([value integerValue]);
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        }
        else {
            return @0;
        }
        
    }];
}

+ (NSValueTransformer *)longitudeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return @([value doubleValue]);
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        }
        else {
            return @0;
        }
        
    }];
}

+ (NSValueTransformer *)latitudeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return @([value doubleValue]);
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        }
        else {
            return @0;
        }
        
    }];
}





@end
