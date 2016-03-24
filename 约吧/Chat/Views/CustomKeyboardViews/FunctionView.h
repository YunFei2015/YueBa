//
//  FunctionView.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QYFunctionViewDelegate <NSObject>

@optional
-(void)toSelectImages;
-(void)toTakeAPhoto;
-(void)toShareLocation;

@end

@interface FunctionView : UIView
@property (nonatomic) id <QYFunctionViewDelegate> delegate;

@end
