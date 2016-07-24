//
//  CommentModel.h
//  WEME
//
//  Created by liewli on 2/2/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CommentModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy)NSString *school;
@property (nonatomic, copy)NSString *authorID;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong)NSArray *thumbnailImages;
@property (nonatomic, strong)NSString *timestamp;
@property (nonatomic, copy)NSString *commentID;
@property (nonatomic, copy)NSString *gender;
@property (nonatomic, copy)NSString *likeNumber;
@property (nonatomic, copy)NSString *constelleation;
@property (nonatomic, assign)BOOL likeFlag;
@end
