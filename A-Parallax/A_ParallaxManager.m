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

#pragma mark - Parallax View Model
@interface A_ParallaxViewModel : NSObject

@property (nonatomic) CGFloat depth;
@property (weak, nonatomic) UIView *view;
@property (nonatomic) CGPoint originalCenterPoint;

@property (nonatomic) CGPoint stepDistance;
@property (nonatomic) int remainSteps;

@property (nonatomic) BOOL isBackgroupView;
@property (weak, nonatomic) A_ParallaxManager *parallaxManager;

@end

@implementation A_ParallaxViewModel


- (instancetype)initWithView:(UIView *)view andDepth:(CGFloat)depth manager:(A_ParallaxManager *)manager {
    self = [super init];
    if (self) {
        self.view = view;
        self.originalCenterPoint = view.center;
        
        if (depth < 0.0f) {
            self.depth = 0.0f;
        } else if (depth > 1.0f) {
            self.depth = 1.0f;
        } else {
            self.depth = depth;
        }
        
        self.parallaxManager = manager;
    }
    return self;
}

- (void)locateToNextPoint {
    if (self.view) {
        
    }
}
- (CGPoint)nextPoint:(CMDeviceMotion *)data {
    if (_remainSteps > 0){
        _remainSteps--;
    } else {
        CGPoint _destinationPoint = [self calculateDestinationPoint:data];
        _stepDistance = CGPointMake((_destinationPoint.x-_view.center.x) / A_Parallax_animationSetpsNumber,
                                        (_destinationPoint.y-_view.center.y) / A_Parallax_animationSetpsNumber);
        
        _remainSteps = A_Parallax_animationSetpsNumber;
    }
    
    return CGPointMake(_view.center.x - _stepDistance.x, _view.center.y - _stepDistance.y);
}
- (CGPoint)calculateDestinationPoint:(CMDeviceMotion *)data {
    if (self.isBackgroupView) {
        return CGPointMake(_originalCenterPoint.x + ((_originalCenterPoint.x * data.gravity.x * A_Parallax_displacementRange)),
                           _originalCenterPoint.y + ((_originalCenterPoint.y * data.gravity.y * A_Parallax_displacementRange)) + (_originalCenterPoint.y * A_Parallax_yAxleOffset));
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
    
    // TODO: DELETE
    CGPoint _originalPoint;
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
            
//            [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
//                
//                if (_subviewModels.count <= 0) return;
//                
//                
//                NSLog(@"x:%f y:%f z:%f", data.gravity.x, data.gravity.y, data.gravity.z);
            // TODO: Backgroup needs add "A_Parallax_yAxleOffset"
//                CGPoint newPoint = CGPointMake(_originalPoint.x + (_originalPoint.x * data.gravity.x * A_Parallax_displacementRange) ,
//                                               _originalPoint.y + _originalPoint.y * A_Parallax_yAxleOffset + (_originalPoint.y * data.gravity.y * A_Parallax_displacementRange)  );
//                
//                NSLog(@"new x:%f new y:%f", newPoint.x, newPoint.y);
//                
//                //TODO: update to use display link
//                [UIView animateWithDuration:A_Parallax_updateInterval animations:^{
//                    [((A_ParallaxViewModel*)_subviewModels[0]).view setCenter:newPoint];
//                } completion:^(BOOL finished) {
//                    
//                }];
//            }];
        }
        
    }
    return self;
}
- (void)displayLinkHandler {
    NSLog(@"x:%f y:%f z:%f", _motionManager.deviceMotion.gravity.x, _motionManager.deviceMotion.gravity.y, _motionManager.deviceMotion.gravity.z);
    
    CMDeviceMotion *motion = _motionManager.deviceMotion;
    for (A_ParallaxViewModel *model in _subviewModels) {
        
    }
}

- (void)A_StoreBackgroupView:(UIView*)view {
    // TODO:
}
- (void)A_StoreView:(UIView*)view depth:(CGFloat)depth {
    _originalPoint = view.center;
    
    A_ParallaxViewModel *model = nil;
    for (A_ParallaxViewModel *item in _subviewModels) {
        if (item.view == view) {
            model = item;
        }
    }
    
    if (!model) {
        model = [[A_ParallaxViewModel alloc] initWithView:view andDepth:depth manager:self];
        [_subviewModels addObject:model];
    } else {
        model.depth = depth;
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





