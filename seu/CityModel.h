//
//  CityModel.h
//  WEME
//
//  Created by liewli on 2016-01-07.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CityModel:MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *state;
@property (nonatomic, strong) NSArray *cities;
@end
