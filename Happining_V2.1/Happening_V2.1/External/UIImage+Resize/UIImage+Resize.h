//
//  UIImage+Resize.h
//  MyLife
//
//  Created by TU on 7/27/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageResize)

- (UIImage*)scaleImageToScale:(CGFloat)scale;
- (UIImage*)scaleImageToSize:(CGSize)size;

@end
