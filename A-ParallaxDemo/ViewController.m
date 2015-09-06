//
//  ViewController.m
//  A-ParallaxDemo
//
//  Created by Animax Deng on 8/20/15.
//  Copyright (c) 2015 Animax Deng. All rights reserved.
//

#import "ViewController.h"

#import "A_ParallaxManager.h"
#import "UIViewController+A_Parallax.h"
#import "UIView+A_Parallax.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *demoBox1;

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
}

@end
