//
//  QYProfileController.h
//  约吧
//
//  Created by Shreker on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYEditProfileController : UITableViewController

@end

/** 跳转代码
 
 - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 UIStoryboard *sbProfile = [UIStoryboard storyboardWithName:@"QYProfile" bundle:nil];
 UIViewController *vcInitial = [sbProfile instantiateInitialViewController];
 [self.navigationController pushViewController:vcInitial animated:YES];
 }
 */
