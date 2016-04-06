//
//  QYPaopaoView.m
//  约吧
//
//  Created by 云菲 on 4/3/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYPaopaoView.h"

@interface QYPaopaoView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;

@end

@implementation QYPaopaoView

-(void)setTitle:(NSString *)title{
    _title = title;
    
    _titleLabel.text = title;
    CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil].size;
    _titleLabelWidthConstraint.constant = size.width;
}

@end
