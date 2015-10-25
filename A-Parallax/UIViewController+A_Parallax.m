//
//  UIViewController+A_Parallax.m
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "UIViewController+A_Parallax.h"
#import "A_ParallaxManager.h"
#import <objc/runtime.h>

@implementation UIViewController (A_Parallax)

static char _parallaxBackgroupViewKey;

- (void)A_ParallaxBackground: (UIImage *)image {
    [self A_ParallaxBackground:image withEffect:A_ParallaxBackgoundDisplayEffectWithNoEffection];
}
- (void)A_ParallaxBackground: (UIImage *)image withEffect:(A_ParallaxBackgoundDisplayEffect)effects {
    UIImageView *backgroupView = objc_getAssociatedObject(self, &_parallaxBackgroupViewKey);
    if (backgroupView) {
        [backgroupView removeFromSuperview];
        [[A_ParallaxManager shareInstance] removeView:backgroupView];
    }
    
    backgroupView = [[UIImageView alloc] initWithImage:image];
    CGRect viewFrame = backgroupView.frame;
    viewFrame.origin.x -= self.view.bounds.size.width * (A_Parallax_displacementRange * 0.5);
    viewFrame.origin.y -= self.view.bounds.size.height * (A_Parallax_displacementRange * 0.5);
    viewFrame.size.height = self.view.bounds.size.height * (1 + (A_Parallax_displacementRange));
    viewFrame.size.width = self.view.bounds.size.width * (1 + (A_Parallax_displacementRange));
    backgroupView.frame = viewFrame;
    [backgroupView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.view insertSubview:backgroupView atIndex:0];
    
    // displaying animation
    if (effects == A_ParallaxBackgoundDisplayEffectWithNoEffection) {
        [[A_ParallaxManager shareInstance] storeBackgroundView:backgroupView];
    } else {
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        [animationGroup setRemovedOnCompletion: YES];
        animationGroup.duration = 0.3f;
        
        NSMutableArray *animationEffects = [[NSMutableArray alloc] init];
        
        if (effects & A_ParallaxBackgoundDisplayEffectWithOpacity) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = @(0.0f);
            opacityAnimation.toValue = @(1.0f);
            [animationEffects addObject:opacityAnimation];
        }
        
        if (effects & A_ParallaxBackgoundDisplayEffectWithTransform) {
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:.5 :1.5 :1 :1];
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1)];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)];
            [animationEffects addObject:transformAnimation];
        }
        
        animationGroup.animations = animationEffects;
        
        [CATransaction begin]; {
            [CATransaction setCompletionBlock:^{
                [[A_ParallaxManager shareInstance] storeBackgroundView:backgroupView];
            }];
            [backgroupView.layer addAnimation:animationGroup forKey:nil];
        } [CATransaction commit];
    }
    objc_setAssociatedObject(self, &_parallaxBackgroupViewKey, backgroupView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)A_DeleteParallaxBackgound {
    UIView *backgroupView = objc_getAssociatedObject(self, &_parallaxBackgroupViewKey);
    if (backgroupView) {
        [[A_ParallaxManager shareInstance] removeView:backgroupView];
    }
}

@end
