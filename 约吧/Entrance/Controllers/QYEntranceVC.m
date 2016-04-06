//
//  QYEntranceVC.m
//  约吧
//
//  Created by 云菲 on 4/5/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYEntranceVC.h"

@interface QYEntranceVC ()
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *animationView;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat angle;

@end

@implementation QYEntranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *color = [UIColor colorWithRed:203/255.f green:55/255.f blue:43/255.f alpha:1];
    _registBtn.backgroundColor = color;
    _registBtn.layer.borderWidth = 1;
    _registBtn.layer.borderColor = color.CGColor;
    
    _loginBtn.tintColor = color;
    _loginBtn.layer.borderWidth = 1;
    _loginBtn.layer.borderColor = color.CGColor;
    
    [self startAnimation];
}

-(void)viewWillAppear:(BOOL)animated{

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}

-(void)startAnimation{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [_animationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
