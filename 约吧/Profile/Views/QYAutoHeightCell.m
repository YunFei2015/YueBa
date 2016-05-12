//
//  QYAutoHeightCell.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYAutoHeightCell.h"
#import "Masonry.h"

/** Color Related */
#define QLColorWithRGB(redValue, greenValue, blueValue) ([UIColor colorWithRed:((redValue)/255.0) green:((greenValue)/255.0) blue:((blueValue)/255.0) alpha:1])
#define QLColorRandom QLColorWithRGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define QLColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kTagSpace 5

@implementation QYAutoHeightCell
{
    __weak IBOutlet UIImageView *_imageView;
    __weak IBOutlet UILabel *_lblTitle;
    __weak IBOutlet UIView *_viewTags;
}

/** 返回循环利用的cell */
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *strId = @"QYAutoHeightCell";
    QYAutoHeightCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QYAutoHeightCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setAutoHeightModel:(QYAutoHeightModel *)autoHeightModel {
    _autoHeightModel = autoHeightModel;
    
    if (_autoHeightModel.arrTags.count == 0) { // 没有标签
        _lblTitle.hidden = NO;
        _viewTags.hidden = YES;
        
        _lblTitle.text = _autoHeightModel.strTitle;
    } else { // 有标签
        _lblTitle.hidden = YES;
        _viewTags.hidden = NO;
        
        [_viewTags.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        /** 添加标签 */
        // 添加标签的容器的最大宽度(也就是_viewTags的最大宽度)
        CGFloat actualMaxWidth = [UIScreen mainScreen].bounds.size.width - (15 + 22 + 8 + 25);
        
        NSArray *arrTags = _autoHeightModel.arrTags;
        NSUInteger count = arrTags.count;
        
        if (count > 0) {
            [_lblTitle  removeFromSuperview];
        }
        
        // 当前行目前的最大宽度
        __block CGFloat rowCurrentMaxWidth = 0;
        
        // 上一个操作的 Label
        __block UILabel *lblTagLast = nil;
        
        // 当前情况下最后一行第一个 UILabel
        __block UILabel *lblPreviousLine = nil;
        
        for (NSUInteger index = 0; index < count; index ++) {
            UILabel *lblTag = [UILabel new];
            [lblTag.layer setCornerRadius:5];
            [lblTag.layer setMasksToBounds:YES];
            UIFont *font = [UIFont systemFontOfSize:13];
            lblTag.font = font;
            lblTag.textAlignment = NSTextAlignmentCenter;
            lblTag.backgroundColor = QLColorRandom;
            [_viewTags addSubview:lblTag];
            
            
            NSString *strText = arrTags[index];
            lblTag.text = strText;
            
            CGFloat textWidth = [strText sizeWithAttributes:@{NSFontAttributeName: font}].width;
            CGFloat lblActualWidth = textWidth + 8;
            
            [lblTag mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(lblActualWidth));
                make.height.equalTo(@(20));
                
                if (lblTagLast == nil) { // 第一个 UILabel
                    make.left.top.equalTo(_viewTags);
                    lblPreviousLine = lblTag;
                    rowCurrentMaxWidth = (lblActualWidth + kTagSpace);
                } else {
                    if (rowCurrentMaxWidth + lblActualWidth > actualMaxWidth) { // 当前行放不下 ==> 换行
                        make.left.equalTo(lblPreviousLine);
                        make.top.equalTo(lblPreviousLine.mas_bottom).offset(kTagSpace);
                        lblPreviousLine = lblTag;
                        rowCurrentMaxWidth = (lblActualWidth + kTagSpace);
                    } else { // 当前行可以放下, 继续向后面堆叠
                        make.left.equalTo(lblTagLast.mas_right).offset(kTagSpace);
                        make.top.equalTo(lblTagLast);
                        rowCurrentMaxWidth += (lblActualWidth + kTagSpace);
                    }
                }
                
                lblTagLast = lblTag;
                if (index == count - 1) {
                    make.bottom.equalTo(_viewTags);
                }
            }];
        }
    }
}

@end
