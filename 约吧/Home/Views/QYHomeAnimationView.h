//
//  DanimationView.h
//  约吧
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DanimationPro <NSObject>

-(void)ChangeValueType:(BOOL)type;
-(void)FinishendValueType;
-(void)markUser:(QYUserInfo *)user asLike:(BOOL)isLike;

@end

@interface QYHomeAnimationView : UIView
@property(nonatomic,assign)id<DanimationPro>delegate;
@property (strong, nonatomic) NSMutableArray *users;

//喜欢不喜欢
-(void)selectLikeOnce:(BOOL)like;
@end
