//
//  A_ParallaxManager.m
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_ParallaxManager.h"
#import <CoreMotion/CoreMotion.h>

#define A_Parallax_updateInterval 0.1f
#define A_Parallax_animationSetpsNumber 6
#define A_Parallax_BackgroundFixedHorizentalOffsetRate 0.15

#pragma mark - Parallax View Model
@interface A_ParallaxViewModel : NSObject

@property (nonatomic) CGFloat depth;
@property (weak, nonatomic) UIView *view;
@property (nonatomic) CGPoint originalCenterPoint;

@property (nonatomic) CGPoint stepDistance;
@property (nonatomic) int remainSteps;

@property (nonatomic) BOOL isBackgroundView;
@property (nonatomic) BOOL enableShadow;

@end

@implementation A_ParallaxViewModel

- (instancetype)initWithView:(UIView *)view andShadow:(BOOL)enable {
    self = [super init];
    if (self) {
        self.view = view;
        self.originalCenterPoint = view.center;
        self.isBackgroundView = NO;
        self.enableShadow = enable;
        if (self.depth == .0f) {
            self.depth = .5f;
        }
    }
    return self;
}
- (instancetype)initWithView:(UIView *)view andDepth:(CGFloat)depth {
    self = [super init];
    if (self) {
        self.view = view;
        self.originalCenterPoint = view.center;
        self.isBackgroundView = NO;
        
        if (depth < 0.0f) {
            self.depth = 0.0f;
        } else if (depth > 1.0f) {
            self.depth = 1.0f;
        } else {
            self.depth = depth;
        }
        
    }
    return self;
}

- (void)moveToNextStep:(CMDeviceMotion *)motion {
    A_ParallaxManager *manager = [A_ParallaxManager shareInstance];
    
    CGPoint currentViewCenter = _view.center;
    
    // animation steps
    if (_remainSteps > 0){
        _remainSteps--;
    } else {
        // calculate new animation distination
        CGPoint destinationPoint = [self calculateDestinationPoint:motion];
        _stepDistance = CGPointMake((destinationPoint.x-currentViewCenter.x) / A_Parallax_animationSetpsNumber,
                                    (destinationPoint.y-currentViewCenter.y) / A_Parallax_animationSetpsNumber);
        
        _remainSteps = A_Parallax_animationSetpsNumber;
    }
    
    // move to next step position
    CGPoint newPoint = CGPointMake(currentViewCenter.x + _stepDistance.x, currentViewCenter.y + _stepDistance.y);
    
    
    [self.view setCenter:newPoint];
    
    // draw the shadow
    if (self.enableShadow) {
        self.view.layer.shadowColor = manager.shadowColor.CGColor;
        self.view.layer.masksToBounds = NO;
        CGSize shadowOffset = CGSizeMake(motion.gravity.x * manager.shadowDynamicOffset + (manager.shadowFixedOffset.x),
                                         motion.gravity.y * manager.shadowDynamicOffset * -1 + (manager.shadowFixedOffset.y));
        self.view.layer.shadowOffset = shadowOffset;
        self.view.layer.shadowRadius = manager.shadowRadius;
        self.view.layer.shadowOpacity = manager.shadowOpacity;
    } else {
        self.view.layer.shadowOpacity = 0.0f;
    }
}

- (CGPoint)calculateDestinationPoint:(CMDeviceMotion *)data {
    CGSize viewSize = self.view.frame.size;
    
    if (self.isBackgroundView) {
        return CGPointMake(_originalCenterPoint.x + (_originalCenterPoint.x * data.gravity.x * A_Parallax_displacementRange) * -1,
                           _originalCenterPoint.y + (_originalCenterPoint.y * data.gravity.y * A_Parallax_displacementRange) + (_originalCenterPoint.y * A_Parallax_BackgroundFixedHorizentalOffsetRate));
    } else {
        return CGPointMake(_originalCenterPoint.x + ((viewSize.width * data.gravity.x * A_Parallax_displacementRange) * self.depth),
                           _originalCenterPoint.y + ((viewSize.height * data.gravity.y * A_Parallax_displacementRange) * self.depth));
    }
}

@end


#pragma mark - Parallax Manager
@implementation A_ParallaxManager {
    CMMotionManager *_motionManager;
    NSMutableArray *_subviewModels;
    NSMutableArray *_emptyViewModels;
    
    CADisplayLink *_displayLink;
}

+ (A_ParallaxManager *)shareInstance {
    static dispatch_once_t pred = 0;
    __strong static A_ParallaxManager *_manager = nil;
    dispatch_once(&pred, ^{
        _manager = [[A_ParallaxManager alloc] initManager];
    });
    
    return _manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [NSException raise:NSInternalInconsistencyException format:@"Please use shareInstance to get the instance"];
    }
    return self;
}
- (instancetype)initManager {
    self = [super init];
    if (self) {
        _subviewModels = [[NSMutableArray alloc] init];
        _emptyViewModels = [[NSMutableArray alloc] init];
        _motionManager = [[CMMotionManager alloc] init];
        
        // set the default params
        _shadowDynamicOffset = 5.0f;
        _shadowFixedOffset = CGPointMake(1.0f, 3.0f);
        _shadowRadius = 5.0f;
        _shadowOpacity = 0.8f;
        _shadowColor = [UIColor blackColor];
        
        if (_motionManager.deviceMotionAvailable) {
            _motionManager.deviceMotionUpdateInterval = A_Parallax_updateInterval;
            [_motionManager startDeviceMotionUpdates];
            
            _displayLink  = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkHandler)];
            _displayLink.frameInterval = 1;
            
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }
    return self;
}
- (void)displayLinkHandler {
    CMDeviceMotion *motion = _motionManager.deviceMotion;
    if (motion) {
        @synchronized(self) {
            for (A_ParallaxViewModel *model in _subviewModels) {
                if (model.view) {
                    [model moveToNextStep:motion];
                }
            }
        }
    }
}

- (void)storeBackgroundView:(UIView*)view {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:1.0f];
            [_subviewModels addObject:model];
        }
        
        model.depth = 1.0f;
        model.isBackgroundView = YES;
    }
}
- (void)storeView:(UIView*)view depth:(CGFloat)depth andShadow:(BOOL)enable {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:depth];
            model.enableShadow = enable;
            [_subviewModels addObject:model];
        } else {
            model.depth = depth;
            model.enableShadow = enable;
        }
        model.isBackgroundView = NO;
    }
}
- (void)storeView:(UIView*)view depth:(CGFloat)depth {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:depth];
            [_subviewModels addObject:model];
        } else {
            model.depth = depth;
        }
        model.isBackgroundView = NO;
    }
}
- (void)storeView:(UIView*)view shadow:(BOOL)enable {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andShadow:enable];
            [_subviewModels addObject:model];
        } else {
            model.enableShadow = enable;
        }
        model.isBackgroundView = NO;
    }
}

- (A_ParallaxViewModel *)getParallaxModel:(UIView *)view {
    A_ParallaxViewModel *model = nil;
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (!item.view) {
            [_emptyViewModels addObject:item];
        } else if (item.view == view) {
            model = item;
        }
    }
    
    for (A_ParallaxViewModel *item in _emptyViewModels) {
        [_subviewModels removeObject:item];
    }
    
    return model;
}

- (BOOL)removeView:(UIView*)view {
    @synchronized(self) {
        for (A_ParallaxViewModel *item in _subviewModels) {
            if (item.view == view) {
                [view setCenter:item.originalCenterPoint];
                [_subviewModels removeObject:item];
                return YES;
            }
        }
        return NO;
    }
}

#pragma mark - Helping methods
- (CGFloat)degreesToRadians:(CGFloat) degrees {
    return degrees * M_PI / 180;
};
- (CGFloat)radiansToDegrees:(CGFloat) radians {
    return radians * 180 / M_PI;
};

@end





