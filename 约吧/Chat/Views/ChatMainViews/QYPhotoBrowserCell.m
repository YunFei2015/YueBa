//
//  QYPhotoBrowserCell.m
//  约吧
//
//  Created by 云菲 on 4/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYPhotoBrowserCell.h"

@interface QYPhotoBrowserCell ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation QYPhotoBrowserCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setImage:(UIImage *)image{
    _image = image;
    
    _photoView.image = image;
}

@end
