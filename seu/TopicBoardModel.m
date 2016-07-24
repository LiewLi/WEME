//
//  TopicBoardModel.m
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "TopicBoardModel.h"
#import "NSValueTransformer+Model.h"

@implementation TopicBoardModel
+ (NSDictionary *) JSONKeyPathsByPropertyKey  {
    return @{
             @"imageURL":@"imageurl",
             @"postID":@"postid"
             };
}

+ (NSValueTransformer *) imageURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)postIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
@end
