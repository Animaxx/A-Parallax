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
#define A_Parallax_yAxleOffset 0.15f
#define A_Parallax_updateInterval 0.1f
#define A_Parallax_animationSetpsNumber 6

#define A_Parallax_shadowOffset (20.0f * -1)
#define A_Parallax_shadowOffset_yAxleExtra 10.0f

#pragma mark - Parallax View Model
@interface A_ParallaxViewModel : NSObject

@property (nonatomic) CGFloat depth;
@property (weak, nonatomic) UIView *view;
@property (nonatomic) CGPoint originalCenterPoint;

@property (nonatomic) CGPoint stepDistance;
@property (nonatomic) int remainSteps;

@property (nonatomic) BOOL isBackgroupView;
@property (nonatomic) BOOL enableShadow;

@end

@implementation A_ParallaxViewModel

- (instancetype)initWithView:(UIView *)view andShadow:(BOOL)enable {
    self = [super init];
    if (self) {
        self.view = view;
        self.originalCenterPoint = view.center;
        self.isBackgroupView = NO;
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
        self.isBackgroupView = YES;
        
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

- (void)locateToNextPoint:(CMDeviceMotion *)data {
    if (self.view && data) {
        CGPoint newPoint = [self nextPoint:data];
        [self.view setCenter:newPoint];
        
        if (self.enableShadow) {
            self.view.layer.shadowColor = [UIColor blackColor].CGColor;
            self.view.layer.masksToBounds = NO;
            self.view.layer.shadowOffset = CGSizeMake(data.gravity.x * A_Parallax_shadowOffset * self.depth, data.gravity.y * A_Parallax_shadowOffset * self.depth + (A_Parallax_shadowOffset_yAxleExtra * self.depth));
            self.view.layer.shadowRadius = 6.0f;
            self.view.layer.shadowOpacity = 0.6f;
        }
    }
}
- (CGPoint)nextPoint:(CMDeviceMotion *)data {
    CGPoint _currentViewCenter = _view.center;
    
    if (_remainSteps > 0){
        _remainSteps--;
    } else {
        CGPoint _destinationPoint = [self calculateDestinationPoint:data];
        _stepDistance = CGPointMake((_destinationPoint.x-_currentViewCenter.x) / A_Parallax_animationSetpsNumber,
                                        (_destinationPoint.y-_currentViewCenter.y) / A_Parallax_animationSetpsNumber);
        
        NSLog(@"step distance x:%f y:%f", _stepDistance.x, _stepDistance.y);
        
        _remainSteps = A_Parallax_animationSetpsNumber;
    }
    
    CGPoint newCenter = CGPointMake(_currentViewCenter.x + _stepDistance.x, _currentViewCenter.y + _stepDistance.y);
    return newCenter;
}
- (CGPoint)calculateDestinationPoint:(CMDeviceMotion *)data {
    if (self.isBackgroupView) {
        return CGPointMake(_originalCenterPoint.x + (_originalCenterPoint.x * data.gravity.x * A_Parallax_displacementRange) * -1,
                           _originalCenterPoint.y + (_originalCenterPoint.y * data.gravity.y * A_Parallax_displacementRange) + (_originalCenterPoint.y * A_Parallax_yAxleOffset));
    } else {
        return CGPointMake(_originalCenterPoint.x + ((_originalCenterPoint.x * data.gravity.x * A_Parallax_displacementRange) * self.depth),
                           _originalCenterPoint.y + ((_originalCenterPoint.y * data.gravity.y * A_Parallax_displacementRange) * self.depth));
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
                [model locateToNextPoint:motion];
            }
        }
    }
}

- (void)A_StoreBackgroupView:(UIView*)view {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:1.0f];
            [_subviewModels addObject:model];
        }
        
        model.depth = 1.0f;
        model.isBackgroupView = YES;
    }
}
- (void)A_StoreView:(UIView*)view depth:(CGFloat)depth andShadow:(BOOL)enable {
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
    }
}
- (void)A_StoreView:(UIView*)view depth:(CGFloat)depth {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:depth];
            [_subviewModels addObject:model];
        } else {
            model.depth = depth;
        }
    }
}
- (void)A_StoreView:(UIView*)view shadow:(BOOL)enable {
    @synchronized(self) {
        A_ParallaxViewModel *model = [self getParallaxModel:view];
        
        if (!model) {
            model = [[A_ParallaxViewModel alloc] initWithView:view andShadow:enable];
            [_subviewModels addObject:model];
        } else {
            model.enableShadow = enable;
        }
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

- (BOOL)A_RemoveView:(UIView*)view {
    @synchronized(self) {
        for (A_ParallaxViewModel *item in _subviewModels) {
            if (item.view == view) {
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





