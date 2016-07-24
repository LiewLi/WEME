//
//  CommunityNotificationModel.m
//  WEME
//
//  Created by liewli on 4/10/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "CommunityNotificationModel.h"
#import "NSValueTransformer+Model.h"

@implementation CommunityNotificationModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"comment":@"comment",
             @"commentID":@"commentid",
             @"postID":@"postid",
             @"timestamp":@"timestamp",
             @"author":@"author"
             };
}

+ (NSValueTransformer *) authorJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[PersonModel class]];
}

+ (NSValueTransformer *) commentIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}

+ (NSValueTransformer *) postIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}



@end
