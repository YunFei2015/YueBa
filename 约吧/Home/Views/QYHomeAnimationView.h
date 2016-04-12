//
//  DanimationView.h
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    like,   //right
    dislike,//left
} ENLIKETYPE ;


@protocol DanimationPro <NSObject>

-(void)ChangeValueType:(ENLIKETYPE)type;
-(void)FinishendValueType;
-(void)noMoreUser;

@end

@interface QYHomeAnimationView : UIView
@property(nonatomic,assign)id<DanimationPro>delegate;
@property (strong, nonatomic) NSMutableArray *users;

//喜欢不喜欢
-(void)selectLikeOnce:(ENLIKETYPE)dlike;
@end
