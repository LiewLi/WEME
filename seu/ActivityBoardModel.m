//
//  ActivityBioardModel.m
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "ActivityBoardModel.h"
#import "NSValueTransformer+Model.h"

@implementation ActivityBoardModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"imageURL":@"imageurl",
             @"activityID":@"activityid"
             };
}

+ (NSValueTransformer *)imageURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *) activityIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
@end
