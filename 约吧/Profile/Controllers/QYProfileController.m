//
//  QYProfileController.m
//  约吧
//
//  Created by Shreker on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYProfileController.h"

@interface QYProfileController ()
{
    IBOutletCollection(UILabel) NSArray *lblCarrer;
    
}

@end

@implementation QYProfileController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
}

@end
