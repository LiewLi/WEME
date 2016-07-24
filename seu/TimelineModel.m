//
//  TimelineModel.m
//  WE
//
//  Created by liewli on 12/17/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import "TimelineModel.h"
#import "WEME-Swift.h"

@implementation TimelineModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"body":@"body",
             @"title":@"title",
             @"time":@"time",
             @"image":@"image",
             @"topic":@"topic",
             @"postid":@"postid"
             };
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
