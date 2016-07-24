//
//  FoodModel.h
//  WEME
//
//  Created by liewli on 2016-01-15.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FoodModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy)NSString *ID;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *authorid;
@property (nonatomic, copy)NSString *author;
@property (nonatomic, copy)NSString *location;
@property (nonatomic, assign)double longitude;
@property (nonatomic, assign)double latitude;
@property (nonatomic, copy)NSString *price;
@property (nonatomic, copy)NSString *comment;
@property (nonatomic, assign)NSInteger likeNumber;
@property (nonatomic, copy)NSURL *imageURL;
@property (nonatomic, assign)BOOL likeflag;
@end
