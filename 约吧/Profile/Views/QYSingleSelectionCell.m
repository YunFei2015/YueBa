//
//  QYSingleSelectionCell.m
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYSingleSelectionCell.h"
@interface QYSingleSelectionCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@end

@implementation QYSingleSelectionCell

+(instancetype)singleSelectionCellForTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath{
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:@"singleCell"];
    QYSingleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"singleCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

-(void)setCellModel:(QYProfileCellModel *)cellModel{
    [super setCellModel:cellModel];
    _titleLabel.text = cellModel.title;
    _contentLabel.text = cellModel.content.length ? cellModel.content : cellModel.placeholder;
    _contentLabel.textColor = cellModel.content.length ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
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
