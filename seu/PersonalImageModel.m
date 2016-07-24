//
//  PersonalImageModel.m
//  WEME
//
//  Created by liewli on 3/24/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "PersonalImageModel.h"
#import "NSValueTransformer+Model.h"

@implementation PersonalImageModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"imgID":@"id",
             @"userid":@"userid",
             @"timestamp":@"timestamp",
             @"imgURL":@"image",
             @"thumbnailURL":@"thumbnail",
             @"username":@"username"
             };
}

+ (NSValueTransformer *)imgURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *) thumbnailURLJSONTransformer {
    return  [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)imgIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}

+ (NSValueTransformer *)useridJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
@end
