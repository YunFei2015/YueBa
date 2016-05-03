//
//  QYNewFriendVC.m
//  约吧
//
//  Created by 云菲 on 16/5/3.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYNewFriendVC.h"

@interface QYNewFriendVC ()
@property (weak, nonatomic) IBOutlet UIImageView *meIcon;
@property (weak, nonatomic) IBOutlet UIImageView *friendIcon;
@property (weak, nonatomic) IBOutlet UILabel *tip;
@property (weak, nonatomic) IBOutlet UIButton *keepSearchingBtn;

@end

@implementation QYNewFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _meIcon.layer.cornerRadius = _meIcon.frame.size.width / 2.f;
    _friendIcon.layer.cornerRadius = _meIcon.layer.cornerRadius;
    
    [_meIcon.superview insertSubview:_friendIcon aboveSubview:_meIcon];
    
    _keepSearchingBtn.layer.borderColor = [UIColor whiteColor].CGColor;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
