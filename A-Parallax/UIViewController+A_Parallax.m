//
//  UIViewController+A_Parallax.m
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "UIViewController+A_Parallax.h"
#import "A_ParallaxManager.h"

@interface A_ParallaxManager()
+ (UIImage *)adjustImage:(UIImage *)image toSize:(CGSize)size;

@end

@implementation UIViewController (A_Parallax)

- (void)A_ParallaxBackgroup: (UIImage *)image {
    CGSize controllerSize = self.view.bounds.size;
    controllerSize.height = controllerSize.height * (1 + A_Parallax_displacementRange * 2);
    controllerSize.width = controllerSize.width * (1 + A_Parallax_displacementRange * 2);
    
    UIImage *backgroupImage = [A_ParallaxManager adjustImage:image toSize:controllerSize];
    UIImageView *backgroupView = [[UIImageView alloc] initWithImage:backgroupImage];
    
    CGRect viewFrame = backgroupView.frame;
    viewFrame.origin.x -= self.view.bounds.size.width * A_Parallax_displacementRange;
    viewFrame.origin.y -= self.view.bounds.size.height * A_Parallax_displacementRange;
    backgroupView.frame = viewFrame;
    
    [self.view insertSubview:backgroupView atIndex:0];
    [[A_ParallaxManager shareInstance] A_StoreBackgroupView:backgroupView];
}
- (void)A_DeleteParallaxBackgroup {
}

@end
