//
//  ViewController.m
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "QYHomeVC.h"
#import "TouchView.h"
#import "DanimationView.h"

#define  centerX     [UIScreen mainScreen].bounds.size.width/2.0
#define  centerY     [UIScreen mainScreen].bounds.size.height/2.0


@interface QYHomeVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@end

@implementation QYHomeVC


-(void)panGestureRecognizer:(UIPanGestureRecognizer *)gesture{
     //滑动gest
    TouchView *view=(TouchView *)gesture.view;
    CGPoint point=[gesture translationInView:view.superview];
    //设置view的位置
    view.center=CGPointMake(point.x+view.center.x, point.y+view.center.y);
    //初始化
    CGPoint vir=[gesture velocityInView:view.superview];
    NSLog(@"=======%@",NSStringFromCGPoint(vir));
    [gesture setTranslation:CGPointZero inView:view.superview];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    //TODO: 判断用户是否已登录
//    BOOL isLogin = NO;
//    if (!isLogin) {
//        UIStoryboard *entranceStoryboard = [UIStoryboard storyboardWithName:kEntranceStoryboard bundle:nil];
//        UIViewController *entranceVC = [entranceStoryboard instantiateViewControllerWithIdentifier:kEntranceVCIdentifier];
//        UIWindow *window = [[UIApplication sharedApplication].delegate window];
//        entranceVC.view.frame = CGRectMake(0, 0, kScreenW, kScreenH);
//        [window addSubview:entranceVC.view];
//    }
        DanimationView *touch=[[DanimationView alloc] initWithFrame:CGRectMake(20, 0,[UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height/2.0)];
         touch.center=CGPointMake(centerX, centerY);
        [self.view addSubview:touch];

    // Do any additional setup after loading the view, typically from a nib.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
    
    if ( revealViewController )
    {
        [self.leftBarButtonItem setTarget: revealViewController];
        [self.leftBarButtonItem setAction: @selector(revealToggle:)];
        
        [self.rightBarButtonItem setTarget: revealViewController];
        [self.rightBarButtonItem setAction: @selector(rightRevealToggle:)];
    }
}

@end
