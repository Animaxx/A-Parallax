//
//  A_ParallaxManager.m
//  A-Parallax
//
//  Created by Animax Deng on 8/19/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "A_ParallaxManager.h"
#import <CoreMotion/CoreMotion.h>

@implementation A_ParallaxManager {
    CMMotionManager *_motionManager;
    NSMutableArray *_subviews;
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
        _subviews = [[NSMutableArray alloc] init];
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 0.2f;
        if (_motionManager.gyroAvailable) {
            [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                if (_subviews.count > 0) {
                    double rotation = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y) - M_PI;
                    ((UIView *)_subviews[0]).transform = CGAffineTransformMakeRotation(rotation);
                }
            }];
        } else {
            NSLog(@"========= Error: =========\r\nDevice doen't support motion service. \r\n==========================");
        }
    }
    return self;
}
- (void)A_AddView:(UIView*)view {
    [_subviews addObject:view];
}


#pragma helping methods
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
