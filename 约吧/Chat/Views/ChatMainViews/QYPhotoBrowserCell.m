//
//  QYPhotoBrowserCell.m
//  约吧
//
//  Created by 云菲 on 4/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYPhotoBrowserCell.h"
#import <UIImageView+WebCache.h>

@interface QYPhotoBrowserCell ()
@end

@implementation QYPhotoBrowserCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setUrl:(NSString *)url{
    _url = url;
    
    [_photoView sd_setImageWithURL:[NSURL fileURLWithPath:url]];
}

@end
