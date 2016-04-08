//
//  QYUserInfoView.m
//  约吧
//
//  Created by 云菲 on 4/8/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYUserInfoView.h"

@interface QYUserInfoView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameAndAgeLabel;

@end

@implementation QYUserInfoView

-(void)setImage:(UIImage *)image{
    _image = image;
    
    _iconImageView.image = image;
}

@end
