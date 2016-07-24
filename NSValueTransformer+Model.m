//
//  NSValueTransformer+Model.m
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "NSValueTransformer+Model.h"

@implementation NSValueTransformer (Model)
+ (void)load {
    [NSValueTransformer setValueTransformer:[self numberORStringToStringValueTransformer] forName:NumberORStringToStringValueTransformer];
    [NSValueTransformer setValueTransformer:[self URLArrayTransformer] forName:URLArrayValueTransformer];
    [NSValueTransformer setValueTransformer:[self FlagValueTransformer] forName:FlagBoolValueTransformer];
}

+ (NSValueTransformer *)numberORStringToStringValueTransformer {
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

+ (NSValueTransformer *) URLArrayTransformer {
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

+ (NSValueTransformer *)FlagValueTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([value integerValue] == 0) {
                return @NO;
            }
            else {
                return @YES;
            }
        }
        else if ([value isKindOfClass:[NSString class]]) {
            if ([value isEqualToString:@"0"]) {
                return @NO;
            }
            else {
                return @YES;
            }
        }
        else {
            return @NO;
        }
    }];

}

@end
