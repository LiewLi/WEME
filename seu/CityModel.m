//
//  CityModel.m
//  WEME
//
//  Created by liewli on 2016-01-07.
//  Copyright © 2016 li liew. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"state":@"state",
             @"cities":@"cities"
             };
}



@end
