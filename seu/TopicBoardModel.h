//
//  TopicBoardModel.h
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TopicBoardModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy)NSURL * imageURL;
@property (nonatomic, copy)NSString *postID;
@end
