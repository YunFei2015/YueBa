//
//  QYEntranceVC.m
//  约吧
//
//  Created by 云菲 on 4/5/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYEntranceVC.h"

@interface QYEntranceVC ()
@property (weak, nonatomic  ) IBOutlet UIButton    *registBtn;
@property (weak, nonatomic  ) IBOutlet UIButton    *loginBtn;
@property (weak, nonatomic  ) IBOutlet UIImageView *animationView;
@property (strong, nonatomic) NSTimer     *timer;
@property (nonatomic        ) CGFloat     angle;

@end

@implementation QYEntranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *color = kRGBColor(203, 55, 43, 1);
    _registBtn.backgroundColor = color;
    _registBtn.layer.borderWidth = 1;
    _registBtn.layer.borderColor = color.CGColor;
    
    _loginBtn.tintColor = color;
    _loginBtn.layer.borderWidth = 1;
    _loginBtn.layer.borderColor = color.CGColor;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self startAnimation];
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [_animationView.layer removeAllAnimations];
    [super viewDidDisappear:animated];
}

-(void)startAnimation{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [_animationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
