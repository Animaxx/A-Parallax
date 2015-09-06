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
        if (self.depth == 0.0f) {
            self.depth = 1.0f;
        }
    }
    return self;
}
- (instancetype)initWithView:(UIView *)view andDepth:(CGFloat)depth {
    self = [super init];
    if (self) {
        self.view = view;
        self.originalCenterPoint = view.center;
        self.isBackgroupView = NO;
        
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
        
        self.view.layer.shadowColor = [UIColor blackColor].CGColor;
        self.view.layer.masksToBounds = NO;
        self.view.layer.shadowOffset = CGSizeMake(data.gravity.x * A_Parallax_shadowOffset, data.gravity.y * A_Parallax_shadowOffset + A_Parallax_shadowOffset_yAxleExtra);
        self.view.layer.shadowRadius = 10.0f;
        self.view.layer.shadowOpacity = 0.6f;
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
                           _originalCenterPoint.y + (_originalCenterPoint.y * data.gravity.y * A_Parallax_displacementRange) * -1 + (_originalCenterPoint.y * A_Parallax_yAxleOffset));
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
        for (A_ParallaxViewModel *model in _subviewModels) {
            [model locateToNextPoint:motion];
        }
    }
}

- (void)A_StoreBackgroupView:(UIView*)view {
    A_ParallaxViewModel *model = nil;
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.view == view) {
            model = item;
        }
    }
    
    if (!model) {
        model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:1.0f];
        [_subviewModels addObject:model];
    }
    
    model.depth = 1.0f;
    model.isBackgroupView = YES;
}
- (void)A_StoreView:(UIView*)view depth:(CGFloat)depth andShadow:(BOOL)enable {
    A_ParallaxViewModel *model = nil;
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.view == view) {
            model = item;
        }
    }

    if (!model) {
        model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:depth];
        model.enableShadow = enable;
        [_subviewModels addObject:model];
    } else {
        model.depth = depth;
        model.enableShadow = enable;
    }

}
- (void)A_StoreView:(UIView*)view depth:(CGFloat)depth {
    A_ParallaxViewModel *model = nil;
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.view == view) {
            model = item;
        }
    }
    
    if (!model) {
        model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:depth];
        [_subviewModels addObject:model];
    } else {
        model.depth = depth;
    }
}
- (void)A_StoreView:(UIView*)view shadow:(BOOL)enable {
    A_ParallaxViewModel *model = nil;
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.view == view) {
            model = item;
        }
    }
    
    if (!model) {
        model = [[A_ParallaxViewModel alloc] initWithView:view andShadow:enable];
        [_subviewModels addObject:model];
    } else {
        model.enableShadow = enable;
    }
}

- (BOOL)A_RemoveView:(UIView*)view {
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.view == view) {
            [_subviewModels removeObject:item];
            return YES;
        }
    }
    return NO;
}
- (void)A_RemoveBackgroup {
    NSMutableArray *backgroupViews = [[NSMutableArray alloc] init];
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.isBackgroupView) {
            [backgroupViews addObject:item];
        }
    }
    
    for (A_ParallaxViewModel *item in backgroupViews) {
        [_subviewModels removeObject:item];
    }
}

#pragma mark - Helping methods
- (CGFloat)degreesToRadians:(CGFloat) degrees {
    return degrees * M_PI / 180;
};
- (CGFloat)radiansToDegrees:(CGFloat) radians {
    return radians * 180 / M_PI;
};

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    CGRect rect = CGRectMake(0, (image.size.height - image.size.width) / 2 , image.size.width, image.size.width);

    CGRect originalRect = CGRectMake(rect.origin.x * image.scale, rect.origin.y * image.scale, rect.size.width * image.scale, rect.size.height * image.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, originalRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    CGSize _size = CGSizeMake(size.width, size.height);
    UIGraphicsBeginImageContext(_size);
    [croppedImage drawInRect:CGRectMake(0, 0, _size.width, _size.height)];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}
+ (UIImage *)adjustImage:(UIImage *)image toSize:(CGSize)size {
    UIImage *resultImage;
    if (image.size.width > image.size.height) {
        CGFloat dashboardScale = image.size.height / size.height;
        resultImage  = [self scaleImage:image toSize:CGSizeMake((size.width<image.size.width)?(image.size.width/dashboardScale):(image.size.width*dashboardScale), size.height)];
    } else {
        CGFloat dashboardScale = image.size.width / size.width;
        resultImage  = [self scaleImage:image toSize:CGSizeMake(size.width, (size.height<image.size.height)?(image.size.height/dashboardScale):(image.size.height*dashboardScale))];
    }

    CGRect rect = CGRectMake((resultImage.size.width - size.width) / 2, (resultImage.size.height - size.height) / 2 , size.width, size.height);
    
    CGRect fromRect = CGRectMake(rect.origin.x * resultImage.scale,
                                 rect.origin.y * resultImage.scale,
                                 rect.size.width * resultImage.scale,
                                 rect.size.height * resultImage.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(resultImage.CGImage, fromRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:resultImage.scale orientation:resultImage.imageOrientation];
    CGImageRelease(imageRef);
    return cropped;
}

@end





