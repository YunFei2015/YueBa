//
//  QYMapAddrCell.m
//  约吧
//
//  Created by 云菲 on 3/28/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYMapAddrCell.h"
#import <BaiduMapAPI_Search/BMKPoiSearchType.h>

@interface QYMapAddrCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end

@implementation QYMapAddrCell

-(void)awakeFromNib{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setSelected:(BOOL)selected{
    if (selected) {
        _selectedView.image = [UIImage imageNamed:@"Friendscoupons_Attention_Hook"];
    }else{
        _selectedView.image = [[UIImage alloc] init];
    }
    
    [super setSelected:selected];
}

-(void)setInfo:(BMKPoiInfo *)info{
    if (!info) {
        _nameLabel.text = @"";
        _addrLabel.text = @"";
    }
    _info = info;
    
    _nameLabel.text = info.name;
    _addrLabel.text = info.address;
}

@end
