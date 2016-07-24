
//  ActivityModel.h
//  牵手东大
//
//  Created by liewli on 12/9/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

//#import <Foundation/Foundation.h>


@interface ActivityModel: MTLModel <MTLJSONSerializing>

@property (nonatomic, copy)NSString * activityID;
@property (nonatomic, copy)NSString * time;
@property (nonatomic, copy)NSString *location;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *capacity;
@property (nonatomic, assign)BOOL state;
@property (nonatomic, copy)NSString * signnumber;
@property (nonatomic, copy)NSString *remark;
@property (nonatomic, copy)NSString *author;
@property (nonatomic, copy)NSString *detail;
@property (nonatomic, copy)NSString *advertise;
@property (nonatomic, assign)BOOL needsImage;
@property (nonatomic, assign)BOOL likeFlag;
@property (nonatomic, copy)NSString *authorID;
@property (nonatomic, copy)NSString *school;
@property (nonatomic, strong)NSURL *poster;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy)NSString *activityState;
@property (nonatomic, copy)NSString *passState;
@property (nonatomic, copy) NSString *sponsor;
@property (nonatomic, assign)BOOL top;
@end
