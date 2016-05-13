//
//  QYUserInfoView.m
//  约吧
//
//  Created by 云菲 on 4/8/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYUserInfoView.h"
#import "QYUserInfo.h"
#import <UIImageView+WebCache.h>

@interface QYUserInfoView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameAndAgeLabel;

@end

@implementation QYUserInfoView

-(void)setUserInfo:(QYUserInfo *)userInfo{
    _userInfo = userInfo;
    
    if (userInfo.userPhotos && userInfo.userPhotos.count > 0) {
        NSString *url = userInfo.userPhotos.firstObject;
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }else{
        _iconImageView.image = [UIImage imageNamed:@"小丸子"];
    }
    
    _nameAndAgeLabel.text = [NSString stringWithFormat:@"%@, %ld", userInfo.name, userInfo.age];
}

@end
