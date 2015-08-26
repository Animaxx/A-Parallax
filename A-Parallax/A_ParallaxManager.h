//
//  A_ParallaxManager.h
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A_Parallax_displacementRange 0.5f
#define A_Parallax_yAxleOffset 0.15f
#define A_Parallax_updateInterval 0.1f

@interface A_ParallaxManager : NSObject

+ (A_ParallaxManager *)shareInstance;
- (void)A_AddView:(UIView*)view distance:(CGFloat)distance;

#pragma mark -
+ (UIImage *)adjustImage:(UIImage *)image toSize:(CGSize)size;


@end
