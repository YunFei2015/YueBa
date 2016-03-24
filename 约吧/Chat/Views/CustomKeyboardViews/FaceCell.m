//
//  FaceCollectionViewCell.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/11.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "FaceCell.h"
#import "FaceModel.h"

@interface FaceCell ()
@property (weak, nonatomic) IBOutlet UIImageView *faceImgView;

@end

@implementation FaceCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setFace:(FaceModel *)face{
    _face = face;
    
    if (face.category == 0) {
        _faceImgView.image = nil;
        return;
    }
    _faceImgView.image = [UIImage imageNamed:_face.imgName];
}

@end
