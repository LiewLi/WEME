//
//  UniversityModel.m
//  WEME
//
//  Created by liewli on 2016-01-07.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "UniversityModel.h"
#import "SchoolModel.h"

@implementation UniversityModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"province":@"province",
             @"universities":@"university"
             };
}


+ (NSValueTransformer *) universitiesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:SchoolModel.class];
}


@end
