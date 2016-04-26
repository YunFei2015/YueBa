//
//  QYMapLocationVC.h
//  约吧
//
//  Created by 云菲 on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLLocation;

@interface QYLocationMapVC : UIViewController


-(instancetype)initWithLocation:(CLLocation *)location title:(NSString *)title;
@end
