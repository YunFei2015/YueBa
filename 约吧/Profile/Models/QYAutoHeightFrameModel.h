//
//  QYAutoHeightFrameModel.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYAutoHeightModel.h"

@interface QYAutoHeightFrameModel : NSObject

@property (nonatomic, strong) QYAutoHeightModel *autoHeightModel;

@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end
