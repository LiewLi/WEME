//
//  PersonModel.m
//  牵手
//
//  Created by liewli on 12/13/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import "PersonModel.h"
#import "NSValueTransformer+Model.h"

@implementation PersonModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"degree":@"degree",
             @"enrollment":@"enrollment",
             @"hobby":@"hobby",
             @"ID":@"id",
             @"phone":@"phone",
             @"preference":@"preference",
             @"qq":@"qq",
             @"wechat":@"wechat",
             @"username":@"username",
             @"birthday":@"birthday",
             @"name":@"name",
             @"school":@"school",
             @"department":@"department",
             @"gender":@"gender",
             @"hometown":@"hometown",
             @"lookcount":@"lookcount",
             @"activityStatus":@"flag",
             @"activityImages":@"image",
             @"activityImageThumbnails":@"thumbnail",
             @"voiceURL":@"voice",
             @"birthFlag":@"birthflag",
             @"followFlag":@"followflag",
             @"constellation":@"constellation",
             @"avatarURL":@"avatar",
             @"verified":@"certification",
             };
}

+ (NSValueTransformer *)verifiedJSONTransformer {
    return [NSValueTransformer valueTransformerForName:FlagBoolValueTransformer];
}

+ (NSValueTransformer *)avatarURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)birthFlagJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSString *v = @"";
        if ([value isKindOfClass:[NSNumber class]]) {
            v = [NSString stringWithFormat:@"%@", value];
        }
        v = value;
        if ([v isEqualToString:@"-1"]) {
            v = @"比你大";
        }
        else if ([v isEqualToString:@"0"]) {
            v = @"同一天生日";
        }
        else if ([v isEqualToString:@"1"]) {
            v = @"比你小";
        }
        return v;
    }];
}

+ (NSValueTransformer *)followFlagJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}

+ (NSValueTransformer *)voiceURLJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString* value, BOOL *success, NSError *__autoreleasing *error) {
        NSURL *url = [NSURL URLWithString:value];
        if (url == nil || [value isEqualToString: @""]) {
            return [NSNull null];
        }
        else return url;
    }];
}

+ (NSValueTransformer *) activityImagesJSONTransformer {
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    return [MTLValueTransformer transformerUsingForwardBlock:^NSArray *(NSArray *values, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *transformedValues = [NSMutableArray arrayWithCapacity:values.count];
        for (NSString *value in values) {
            id transformedValue = [transformer transformedValue:value];
            if (transformedValue) {
                [transformedValues addObject:transformedValue];
            }
        }
        return transformedValues;
    }];
}

+ (NSValueTransformer *) activityImageThumbnailsJSONTransformer {
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    return [MTLValueTransformer transformerUsingForwardBlock:^NSArray *(NSArray *values, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *transformedValues = [NSMutableArray arrayWithCapacity:values.count];
        for (NSString *value in values) {
            id transformedValue = [transformer transformedValue:value];
            if (transformedValue) {
                [transformedValues addObject:transformedValue];
            }
        }
        return transformedValues;
    }];
}



+ (NSValueTransformer *) activityStatusJSONTransformer {
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


+ (NSValueTransformer *) IDJSONTransformer {
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

+ (NSValueTransformer *) lookcountJSONTransformer {
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
