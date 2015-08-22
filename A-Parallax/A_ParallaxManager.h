//
//  A_ParallaxManager.h
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A_ParallaxManager : NSObject

+ (A_ParallaxManager *)shareInstance;
- (void)A_AddView:(UIView*)view;


+ (UIImage *)adjustImage:(UIImage *)image toSize:(CGSize)size;

@end
