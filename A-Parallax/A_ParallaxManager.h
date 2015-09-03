//
//  A_ParallaxManager.h
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A_Parallax_displacementRange 0.5f

@interface A_ParallaxManager : NSObject

+ (A_ParallaxManager *)shareInstance;

- (void)A_StoreBackgroupView:(UIView*)view;
// depth is about how depth the view should be, range  [0...1]
- (void)A_StoreView:(UIView*)view depth:(CGFloat)depth;


@end
