//
//  TopicModel.m
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "TopicModel.h"
#import "NSValueTransformer+Model.h"

@implementation TopicModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"topicID": @"id",
             @"theme": @"theme",
             @"imageURL":@"imageurl",
             @"hotIndex":@"number",
             @"footNote":@"note"
             };
}
+ (NSValueTransformer *) imageURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}
+ (NSValueTransformer *)hotIndexJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
+ (NSValueTransformer *)topicIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
@end
