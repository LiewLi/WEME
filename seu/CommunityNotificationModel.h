//
//  CommunityNotificationModel.h
//  WEME
//
//  Created by liewli on 4/10/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "PersonModel.h"

@interface CommunityNotificationModel :MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) PersonModel *author;
@end
