//
//  A_ParallaxManager.h
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define A_Parallax_displacementRange 0.3f

@interface A_ParallaxManager : NSObject

// the maximum offset of shadow, default: 5.0f
@property (nonatomic) CGFloat shadowDynamicOffset;
// the fixed offset of shadow, default: (1, 3)
@property (nonatomic) CGPoint shadowFixedOffset;
// the shadow radius, default: 5.0f
@property (nonatomic) CGFloat shadowRadius;
// the shadow opacity, default: 0.8f
@property (nonatomic) CGFloat shadowOpacity;
// the shadow color, default: blackColor
@property (nonatomic) UIColor *shadowColor;

+ (A_ParallaxManager *)shareInstance;

- (void)storeBackgroundView:(UIView*)view;

// depth is about how depth the view should be, range shallower [0...1] deeper
- (void)storeView:(UIView*)view depth:(CGFloat)depth andShadow:(BOOL)enable;
- (void)storeView:(UIView*)view depth:(CGFloat)depth;
- (void)storeView:(UIView*)view shadow:(BOOL)enable;

- (BOOL)removeView:(UIView*)view;

@end
