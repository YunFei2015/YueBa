//
//  QYScrollPhotoView.h
//  约吧
//
//  Created by 青云-wjl on 16/6/13.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYScrollPhotoView : UIView
@property (nonatomic, strong) UIImageView *currentDisplayImageView;
+(instancetype)scrollPhotoViewWithImages:(NSArray *)images;
@end
