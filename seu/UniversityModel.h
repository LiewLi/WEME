//
//  UniversityModel.h
//  WEME
//
//  Created by liewli on 2016-01-07.
//  Copyright © 2016 li liew. All rights reserved.
//
#import <Mantle/Mantle.h>

@interface UniversityModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *province;
@property (nonatomic, strong)NSArray *universities;
@end
