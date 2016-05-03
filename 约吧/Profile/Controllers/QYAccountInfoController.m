//
//  QYAccountInfoController.m
//  约吧
//
//  Created by Shreker on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#define QLColorWithRGB(redValue, greenValue, blueValue) ([UIColor colorWithRed:((redValue)/255.0) green:((greenValue)/255.0) blue:((blueValue)/255.0) alpha:1])

#import "QYAccountInfoController.h"

@interface QYAccountInfoController () <UITableViewDelegate>
{
    __weak IBOutlet UIButton *_btnDeleteAccount;
}

@end

@implementation QYAccountInfoController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    // 设置按钮的圆角和边框
    [_btnDeleteAccount.layer setCornerRadius:5.0];
    [_btnDeleteAccount.layer setBorderColor: QLColorWithRGB(235, 128, 112).CGColor];
    [_btnDeleteAccount.layer setBorderWidth:.5f];
    [_btnDeleteAccount.layer setMasksToBounds:YES];
}

#pragma mark - 🔌 Delegate Methods
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
