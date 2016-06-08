//
//  QYMultipleSelectionCell.m
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYMultipleSelectionCell.h"
#import "Masonry.h"

/** Color Related */
#define QLColorWithRGB(redValue, greenValue, blueValue) ([UIColor colorWithRed:((redValue)/255.0) green:((greenValue)/255.0) blue:((blueValue)/255.0) alpha:1])
#define QLColorRandom QLColorWithRGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define QLColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kTagSpace 5

@interface QYMultipleSelectionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIView *personalityView;
@property (weak, nonatomic) IBOutlet UILabel *personalityLabel;

@end

@implementation QYMultipleSelectionCell

+(instancetype)multipleSelectionCellForTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath{
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:@"MultipleCell"];
    QYMultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultipleCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    //cell.contentView.tintColor = [UIColor redColor];
    return cell;
}

-(void)setCellModel:(QYProfileCellModel *)cellModel{
    [super setCellModel:cellModel];
    
    if (cellModel.content.length == 0) { // 没有标签
        _personalityLabel.hidden = NO;
        _personalityView.hidden = YES;
        
        _personalityLabel.text = cellModel.title;
    } else { // 有标签
        _personalityLabel.hidden = YES;
        _personalityView.hidden = NO;
        
        [_personalityView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        /** 添加标签 */
        // 添加标签的容器的最大宽度(也就是_viewTags的最大宽度)
        CGFloat actualMaxWidth = [UIScreen mainScreen].bounds.size.width - (15 + 20 + 5 + 25);
        
        NSArray *arrTags = [cellModel.content componentsSeparatedByString:@","];
        NSUInteger count = arrTags.count;
        
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
            lblTag.layer.backgroundColor = QLColorRandom.CGColor;
            [_personalityView addSubview:lblTag];
            
            
            NSString *strText = arrTags[index];
            lblTag.text = strText;
            
            CGFloat textWidth = [strText sizeWithAttributes:@{NSFontAttributeName: font}].width;
            CGFloat lblActualWidth = textWidth + 8;
            
            [lblTag mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(lblActualWidth));
                make.height.equalTo(@(28));
                
                if (lblTagLast == nil) { // 第一个 UILabel
                    make.left.equalTo(_personalityView);
                    make.top.mas_equalTo(2 * kTagSpace);
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
                    make.bottom.mas_equalTo(- 2 * kTagSpace);
                }
            }];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
