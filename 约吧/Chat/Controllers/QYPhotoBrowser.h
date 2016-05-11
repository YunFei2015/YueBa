//
//  QYPhotoBrowser.h
//  约吧
//
//  Created by 云菲 on 4/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYPhotoBrowserCell.h"

typedef void(^QYPhotoBrowserPopMenu)(UIImage *image);

@interface QYPhotoBrowser : UIViewController
@property (strong, nonatomic) NSArray *urls;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic) CGRect finalFrame;
@property (strong, nonatomic) QYPhotoBrowserCell *selectedCell;

@end
