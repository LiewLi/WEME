//
//  TopicModel.h
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TopicModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString * topicID;
@property (nonatomic, copy) NSString *theme;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSString *hotIndex;
@property (nonatomic, copy) NSString *footNote;
@end
