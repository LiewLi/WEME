//
//  UserImageModel.h
//  WE
//
//  Created by liewli on 12/18/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface UserImageModel : MTLModel<MTLJSONSerializing>
@property (nullable, nonatomic, strong) NSURL *image;
@property (nullable,nonatomic, strong) NSURL *thumbnail;
@property (nonnull,nonatomic, copy) NSString *postid;
@property (nonnull, nonatomic, copy)NSString *title;
@property (nonnull, nonatomic, copy)NSString *body;
@property (nonnull, nonatomic, copy)NSString *topic;
@property (nonnull, nonatomic, strong) NSDate *time;
@end
