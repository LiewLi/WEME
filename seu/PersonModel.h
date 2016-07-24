//
//  PersonModel.h
//  牵手
//
//  Created by liewli on 12/13/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface PersonModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *degree;
@property (nonatomic, copy) NSString *enrollment;
@property (nonatomic, copy) NSString *hobby;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *preference;
@property (nonatomic, copy) NSString *qq;
@property (nonatomic, copy) NSString *wechat;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *school;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *hometown;
@property (nonatomic, copy) NSString *lookcount;
@property (nonatomic, assign)BOOL activityStatus;
@property (nonatomic, strong)NSArray *activityImages;
@property (nonatomic, strong)NSArray *activityImageThumbnails;
@property (nonatomic, copy)NSURL *voiceURL;
@property (nonatomic, copy) NSString *birthFlag;
@property (nonatomic, copy)NSString *followFlag;
@property (nonatomic, copy)NSString *constellation;
@property (nonatomic, strong)NSURL *avatarURL;
@property (nonatomic, assign)BOOL verified;
@end
