//
//  ViewController.m
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "QYHomeVC.h"
#import "QYHomeAnimationView.h"

@interface QYHomeVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *unlickBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@end

@implementation QYHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubView];
}

#pragma mark - Custom Methods
-(void)configSubView{
    _unlickBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _unlickBtn.layer.borderWidth = 1;
    _unlickBtn.layer.cornerRadius = 50;
    
    _likeBtn.layer.borderColor = [UIColor redColor].CGColor;
    _likeBtn.layer.borderWidth = 1;
    _likeBtn.layer.cornerRadius = 50;
    
    //侧滑结构
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    [self.leftBarButtonItem setTarget: self.revealViewController];
    [self.leftBarButtonItem setAction: @selector(revealToggle:)];
    [self.rightBarButtonItem setTarget: self.revealViewController];
    [self.rightBarButtonItem setAction: @selector(rightRevealToggle:)];
}

#pragma mark - Events
//不喜欢当前用户
- (IBAction)unlikeAction:(UIButton *)sender {
    //TODO: 用户头像向左滑出屏幕
    
}

//喜欢当前用户
- (IBAction)likeAction:(UIButton *)sender {
    //TODO: 用户头像向右滑出屏幕
    
}



@end
