//
//  QYAutoHeightFrameModel.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYAutoHeightFrameModel.h"

@implementation QYAutoHeightFrameModel

- (void)setAutoHeightModel:(QYAutoHeightModel *)autoHeightModel {
    _autoHeightModel = autoHeightModel;
    
    NSArray *arrTags = autoHeightModel.arrTags;
    if (arrTags.count > 0) {
        
    } else {
        _cellHeight = 44;
    }
}

@end
