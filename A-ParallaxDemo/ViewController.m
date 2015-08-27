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

@interface ViewController ()

@end

@implementation ViewController {
    UIImageView *_backgroupView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    UIImage *backgroupImage = [A_ParallaxManager adjustImage:[UIImage imageNamed:@"backgroup"] toSize:[UIScreen mainScreen].bounds.size];
//    _backgroupView = [[UIImageView alloc] initWithImage:backgroupImage];
//    
//    [self.view insertSubview:_backgroupView atIndex:0];
//    [[A_ParallaxManager shareInstance] A_AddView:_backgroupView distance:1.0f];
    
    [self A_SetBackgroupImage:[UIImage imageNamed:@"backgroup"]];
}

@end
