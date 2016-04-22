//
//  QYPhotoBrowser.h
//  约吧
//
//  Created by 云菲 on 4/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^QYPhotoBrowserExit)(void);
typedef void(^QYPhotoBrowserPopMenu)(UIImage *image);

@interface QYPhotoBrowser : UIView
@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) QYPhotoBrowserExit exitPhotoBrowser;
@property (strong, nonatomic) QYPhotoBrowserPopMenu popMenuOnPhotoBrowser;
@end
