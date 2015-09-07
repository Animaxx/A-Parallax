//
//  UIView+A_Parallax.h
//  A-ParallaxDemo
//
//  Created by Animax Deng on 8/26/15.
//  Copyright © 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (A_Parallax)

- (void)A_SetParallax;
- (void)A_SetParallaxDepth: (CGFloat)depth;
- (void)A_SetParallaxShadow: (BOOL)enable;
- (void)A_SetParallaxDepth: (CGFloat)depth andShadow: (BOOL)enable;

- (void)A_DeleteParallax;

@end
