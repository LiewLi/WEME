//
//  UserImageModel.m
//  WE
//
//  Created by liewli on 12/18/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import "UserImageModel.h"
#import "WEME-Swift.h"

@implementation UserImageModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"image":@"image",
            @"thumbnail":@"thumbnail",
            @"postid":@"postid",
            @"time":@"time",
            @"title":@"title",
            @"body":@"body",
            @"topic":@"topic"
             };
}

+ (NSValueTransformer *) thumbnailJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [[NSURL alloc]initWithString:value];
    }];
}

+ (NSValueTransformer *) timeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithUSLocaleAndFormat:@"EE, d LLLL yyyy HH:mm:ss zzzz"];
        return [dateFormatter dateFromString:value];
    }];
}

+ (NSValueTransformer *) imageJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return [[NSURL alloc]initWithString:value];
    }];
}
+ (NSValueTransformer *) postidJSONTransformer {
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
