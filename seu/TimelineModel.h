//
//  TimelineModel.h
//  WE
//
//  Created by liewli on 12/17/15.
//  Copyright © 2015 li liew. All rights reserved.
//
#import <Mantle/Mantle.h>

@interface TimelineModel : MTLModel<MTLJSONSerializing>
@property (nonnull, nonatomic, copy)NSString *title;
@property (nonnull, nonatomic, copy)NSString *body;
@property (nonnull, nonatomic, strong)NSDate *time;
@property (nonnull, nonatomic, copy)NSString *topic;
@property (nullable, nonatomic, strong)NSURL *image;
@property (nonnull, nonatomic, copy)NSString *postid;
@end
