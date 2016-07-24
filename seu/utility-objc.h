//
//  utility-objc.h
//  牵手
//
//  Created by liewli on 12/11/15.
//  Copyright © 2015 li liew. All rights reserved.
//

#ifndef utility_objc_h
#define utility_objc_h
#import <UIKit/UIKit.h>

@interface UIImage (MASK)
- (UIImage *) maskWithColor:(UIColor *)color;
@end

@interface Utility : NSObject
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end

@interface DLLabel: UILabel
- (void)drawTextInRect:(CGRect)rect;
@end

#endif /* utility_objc_h */
