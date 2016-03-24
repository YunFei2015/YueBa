//
//  FaceView.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FaceModel;

@interface FacesView : UIView
@property(nonatomic, copy) void (^selectFace)(FaceModel *face);
@property (strong, nonatomic) NSArray *faces;
@end
