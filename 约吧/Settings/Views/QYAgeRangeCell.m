//
//  QYAgeRangeCell.m
//  约吧
//
//  Created by 云菲 on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYAgeRangeCell.h"
#import "MARKRangeSlider.h"

@interface QYAgeRangeCell ()
@property (strong, nonatomic) MARKRangeSlider *slider;

@end

@implementation QYAgeRangeCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView addSubview:self.slider];
    self.minAge = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterKeyMinAge];
    self.maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterKeyMaxAge];
    float leftValue = (_minAge - 16) / (50.f - 16.f);
    float rightValue = (_maxAge  - 16) / (50.f - 16.f);
    [self.slider setLeftValue:leftValue rightValue:rightValue];
}


-(MARKRangeSlider *)slider{
    if (_slider == nil) {
        CGFloat sliderW = kScreenW - 20 - 20;
        CGFloat sliderH = self.contentView.frame.size.height;
        CGFloat sliderX = 20;
        CGFloat sliderY = 0;
        MARKRangeSlider *slider = [[MARKRangeSlider alloc] initWithFrame:CGRectMake(sliderX, sliderY, sliderW, sliderH)];
        [slider addTarget:self action:@selector(currentValue:) forControlEvents:UIControlEventValueChanged];
        
        _slider = slider;
    }
    return _slider;
}

-(void)currentValue:(MARKRangeSlider *)slider{
    self.minAge = ceilf((50 - 16) * slider.leftValue + 16);
    self.maxAge = ceilf((50 - 16) * slider.rightValue + 16);
    NSLog(@"%ld,%ld", _minAge, _maxAge);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
