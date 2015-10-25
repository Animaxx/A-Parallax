//
//  UIViewController+A_Parallax.h
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, A_ParallaxBackgoundDisplayEffect) {
    A_ParallaxBackgoundDisplayEffectWithNoEffection       = 0,
    A_ParallaxBackgoundDisplayEffectWithOpacity           = 1 << 1,
    A_ParallaxBackgoundDisplayEffectWithTransform         = 1 << 2,
};

@interface UIViewController (A_Parallax)

- (void)A_ParallaxBackground: (UIImage *)image;
- (void)A_ParallaxBackground: (UIImage *)image withEffect:(A_ParallaxBackgoundDisplayEffect)effects;


@end
