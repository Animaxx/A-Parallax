//
//  UIViewController+A_Parallax.m
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "UIViewController+A_Parallax.h"
#import "A_ParallaxManager.h"

@implementation UIViewController (A_Parallax)

- (void)setBackgroupImage: (UIImage *)image {
    UIImage *backgroupImage = [A_ParallaxManager adjustImage:image toSize:[UIScreen mainScreen].bounds.size];
    //TODO: size
    [self.view insertSubview:[[UIImageView alloc] initWithImage:backgroupImage] atIndex:0];
    
}

@end
