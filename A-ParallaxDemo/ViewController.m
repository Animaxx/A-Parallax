//
//  ViewController.m
//  A-ParallaxDemo
//
//  Created by Animax Deng on 8/20/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "ViewController.h"
#import "A_Parallax.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *demoBox1;
@property (weak, nonatomic) IBOutlet UIView *demoBox2;
@property (weak, nonatomic) IBOutlet UILabel *noShadowLabel;

@property (weak, nonatomic) IBOutlet UIView *operationArea;
@property (weak, nonatomic) IBOutlet UIButton *changeShadowColorButton;
@property (weak, nonatomic) IBOutlet UISlider *shadowRadiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *shadowRadiusLabel;

@property (weak, nonatomic) IBOutlet UILabel *shadowFixedOffsetXLabel;
@property (weak, nonatomic) IBOutlet UILabel *shadowFixedOffsetYLabel;
@property (weak, nonatomic) IBOutlet UILabel *shadowDynamicLabel;

@end

@implementation ViewController {
    UIImageView *_backgroupView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self A_ParallaxBackgroup:[UIImage imageNamed:@"backgroup"]];
    [_demoBox1 A_SetParallaxShadow:YES];
    [_demoBox2 A_SetParallaxShadow:YES];
    [_noShadowLabel A_SetParallaxShadow:YES];
    
    _operationArea.layer.cornerRadius = 16.0f;
    _operationArea.layer.borderColor = [UIColor whiteColor].CGColor;
    _operationArea.layer.borderWidth = 1.0f;
    
    _changeShadowColorButton.layer.cornerRadius = 4.0f;
    _changeShadowColorButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _changeShadowColorButton.layer.borderWidth = 2.0f;
    
    _demoBox2.layer.cornerRadius = _demoBox2.frame.size.width/2.0f;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)changedEnableShadow:(UISwitch *)sender {
    [_demoBox1 A_SetParallaxShadow:sender.on];
    [_demoBox2 A_SetParallaxShadow:sender.on];
    [_noShadowLabel A_SetParallaxShadow:sender.on];
}

- (IBAction)updateShadowColor:(id)sender {
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
    
    [[A_ParallaxManager shareInstance] setShadowColor:color];
}
- (IBAction)updateShadowRadius:(id)sender {
    _shadowRadiusLabel.text = [NSString stringWithFormat:@"%.2f", _shadowRadiusSlider.value];
    [[A_ParallaxManager shareInstance] setShadowRadius:_shadowRadiusSlider.value];
}

- (IBAction)updateShadowFixedOffsetX:(UISlider *)sender {
    _shadowFixedOffsetXLabel.text = [NSString stringWithFormat:@"x:%.2f", sender.value];
    CGPoint shadowFixedOffset = [A_ParallaxManager shareInstance].shadowFixedOffset;
    shadowFixedOffset.x = sender.value;
    [[A_ParallaxManager shareInstance] setShadowFixedOffset:shadowFixedOffset];
}
- (IBAction)updateShadowFixedOffsetY:(UISlider *)sender {
    _shadowFixedOffsetYLabel.text = [NSString stringWithFormat:@"y:%.2f", sender.value];
    CGPoint shadowFixedOffset = [A_ParallaxManager shareInstance].shadowFixedOffset;
    shadowFixedOffset.y = sender.value;
    [[A_ParallaxManager shareInstance] setShadowFixedOffset:shadowFixedOffset];
}
- (IBAction)updateDynamicOffset:(UISlider *)sender {
    [[A_ParallaxManager shareInstance] setShadowDynamicOffset:sender.value];
    _shadowDynamicLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

@end
