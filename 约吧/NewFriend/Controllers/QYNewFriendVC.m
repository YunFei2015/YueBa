//
//  QYNewFriendVC.m
//  约吧
//
//  Created by 云菲 on 16/5/3.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYNewFriendVC.h"
#import "QYAccount.h"
#import "QYUserInfo.h"
#import <UIImageView+WebCache.h>

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
    _keepSearchingBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [_meIcon.superview insertSubview:_friendIcon aboveSubview:_meIcon];
    
    QYUserInfo *me = [QYAccount currentAccount].myInfo;
    if (me.userPhotos && me.userPhotos.count > 0) {
        NSString *url = me.userPhotos.firstObject;
        [_meIcon sd_setImageWithURL:[NSURL URLWithString:url]];
    }else{
        _meIcon.image = [UIImage imageNamed:@"小心"];
    }
    
    if (_friend.userPhotos && _friend.userPhotos.count > 0) {
        NSString *url = me.userPhotos.firstObject;
        [_friendIcon sd_setImageWithURL:[NSURL URLWithString:url]];
    }else{
        _friendIcon.image = [UIImage imageNamed:@"小丸子"];
    }
    
    _tip.text = [NSString stringWithFormat:@"你和%@相互喜欢了对方", _friend.name];
}

#pragma mark - Events
- (IBAction)commitMessageAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_talkToNewFriend) {
            _talkToNewFriend(_friend);
        }
    }];
}

- (IBAction)keepSearchingAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
