//
//  PersonalImageModel.h
//  WEME
//
//  Created by liewli on 3/24/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface PersonalImageModel: MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *imgID;
@property (nonatomic, strong)NSString *userid;
@property (nonatomic, strong)NSURL *imgURL;
@property (nonatomic, strong)NSURL *thumbnailURL;
@property (nonatomic, strong) NSString *timestamp;
@end
