//
//  UIView+A_Parallax.m
//  A-ParallaxDemo
//
//  Created by Animax Deng on 8/26/15.
//  Copyright © 2015 Animax Deng. All rights reserved.
//

#import "UIView+A_Parallax.h"
#import "A_ParallaxManager.h"

@implementation UIView (A_Parallax)

- (void)A_SetParallax {
    [[A_ParallaxManager shareInstance] storeView:self shadow:YES];
}
- (void)A_SetParallaxDepth: (CGFloat)depth {
    [[A_ParallaxManager shareInstance] storeView:self depth:depth];
}
- (void)A_SetParallaxShadow: (BOOL)enable {
    [[A_ParallaxManager shareInstance] storeView:self shadow:enable];
}
- (void)A_SetParallaxDepth: (CGFloat)depth andShadow: (BOOL)enable {
    [[A_ParallaxManager shareInstance] storeView:self depth:depth andShadow:enable];
}

- (void)A_DeleteParallax {
    [[A_ParallaxManager shareInstance] removeView:self];
}

@end
