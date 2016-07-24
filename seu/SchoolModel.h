//
//  SchoolModel.h
//  WEME
//
//  Created by liewli on 2016-01-07.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface SchoolModel :MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *name;
@end
