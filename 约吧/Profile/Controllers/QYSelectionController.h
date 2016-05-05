//
//  QYSelectionController.h
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYSelectModel.h"

typedef NS_ENUM(NSUInteger, QYSelectionType) {
    /** 职业 */
    QYSelectionTypeOccupation,
    
    /** 来自 */
    QYSelectionTypeHometown,
    
    /** 我的个性标签 */
    QYSelectionTypePersonality,
    
    /** 我喜欢的运动 */
    QYSelectionTypeSports,
    
    /** 我喜欢的音乐 */
    QYSelectionTypeMusic,
    
    /** 我喜欢的食物 */
    QYSelectionTypeFood,
    
    /** 我喜欢的电影 */
    QYSelectionTypeMovies,
    
    /** 我喜欢的书和动漫 */
    QYSelectionTypeLiterature,
    
    /** 我的旅行足迹 */
    QYSelectionTypePlaces
};

@class QYSelectionController, QYSelectModel;

@protocol QYSelectionControllerDelegate <NSObject>

- (void)selectionController:(QYSelectionController *)selectionController didSelectSelectModel:(QYSelectModel *)selectModel indexPath:(NSIndexPath *)indexPath;

@end

@interface QYSelectionController : UITableViewController

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) QYSelectionType type;
@property (nonatomic, weak) id<QYSelectionControllerDelegate> delegate;

@end
