//
//  QYSettingsTableVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYSettingsTableVC.h"
#import "QYAccount.h"
#import "AppDelegate.h"
#import "QYNetworkManager.h"

@interface QYSettingsTableVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UISwitch *manSw;
@property (weak, nonatomic) IBOutlet UISwitch *womanSw;

@end

@implementation QYSettingsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    _logoutBtn.layer.cornerRadius = 5;
    _logoutBtn.layer.borderColor = [UIColor redColor].CGColor;
    _logoutBtn.layer.borderWidth = .5f;
}

- (IBAction)logout:(UIButton *)sender {
    [[QYAccount currentAccount] logout];
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app setRootViewControllerToEntrance];
}

- (IBAction)selectSexAction:(UISwitch *)sender {
    if (sender == _manSw) {
        [_womanSw setOn:!sender.isOn animated:YES];
    }else{
        [_manSw setOn:!sender.isOn animated:YES];
    }
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
