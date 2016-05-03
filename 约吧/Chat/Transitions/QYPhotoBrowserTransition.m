//
//  QYPhotoBrowserTransition.m
//  约吧
//
//  Created by 云菲 on 16/4/25.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYPhotoBrowserTransition.h"
#import "QYChatVC.h"
#import "QYPhotoBrowser.h"


@implementation QYPhotoBrowserTransition

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if ([[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UINavigationController *nav = (UINavigationController *)revealVC.rightViewController;
        QYChatVC *fromVC = (QYChatVC *)nav.viewControllers[1];
        QYPhotoBrowser *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *container = [transitionContext containerView];
        
        UIView *snapShotView = [fromVC.selectedCell.photoImageView snapshotViewAfterScreenUpdates:NO];
        snapShotView.frame = [container convertRect:fromVC.selectedCell.photoImageView.frame fromView:fromVC.selectedCell];
        toVC.finalFrame = snapShotView.frame;
        toVC.view.alpha = 0;
        
        [container addSubview:toVC.view];
        [container addSubview:snapShotView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            snapShotView.frame = toVC.view.frame;
        } completion:^(BOOL finished) {
            toVC.view.alpha = 1;
            [snapShotView removeFromSuperview];
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }else{
        QYPhotoBrowser *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *container = [transitionContext containerView];
        
        UIView *snapShotView = [fromVC.selectedCell.photoView snapshotViewAfterScreenUpdates:NO];
        [container addSubview:toVC.view];
        [container addSubview:snapShotView];
      
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            snapShotView.frame = fromVC.finalFrame;
        } completion:^(BOOL finished) {
            [snapShotView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

@end
