//
//  CommentModel.m
//  WEME
//
//  Created by liewli on 2/2/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "CommentModel.h"
#import "NSValueTransformer+Model.h"

@implementation CommentModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"commentID":@"id",
             @"authorID":@"userid",
             @"authorName":@"name",
             @"body":@"body",
             @"school":@"school",
             @"timestamp":@"timestamp",
             @"images":@"image",
             @"thumbnailImages":@"thumbnail",
             @"gender":@"gender",
             @"likeNumber":@"likenumber",
             @"constelleation":@"constelleation",
             @"likeFlag":@"flag"
             };
}

+ (NSValueTransformer *)commentIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
+ (NSValueTransformer *)authorIDJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}
+ (NSValueTransformer *)likeNumberJSONTransformer {
    return [NSValueTransformer valueTransformerForName:NumberORStringToStringValueTransformer];
}

+ (NSValueTransformer *) imagesJSONTransformer {
    return [NSValueTransformer valueTransformerForName:URLArrayValueTransformer];
}

+ (NSValueTransformer *) thumbnailImagesJSONTransformer {
    return [NSValueTransformer valueTransformerForName:URLArrayValueTransformer];
}
+ (NSValueTransformer *) likeFlagJSONTransformer {
    return [NSValueTransformer valueTransformerForName:FlagBoolValueTransformer];
}
@end
