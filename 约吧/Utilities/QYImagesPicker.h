//
//  QYImagesPicker.h
//  约吧
//
//  Created by 云菲 on 3/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol QYImagesPickerDelegate <NSObject>

@optional
-(void)didFinishSelectImages:(NSDictionary *)info;

@end

//typedef void(^initPickControllerCompletion)(UIImagePickerController *pickerController);
//typedef void(^selectImagesCompletion)(NSArray *);
//typedef void(^cancelSelectImagesCompletion)();

@interface QYImagesPicker : NSObject
@property (nonatomic, weak) id <QYImagesPickerDelegate> delegate;

+(instancetype)sharedInstance;
//-(void)selectImagesWithInitPickControllerCompletion:(initPickControllerCompletion)initPickControllerCompletion;
//-(void)takeAPhotoWithInitPickControllerCompletion:(initPickControllerCompletion)initPickControllerCompletion;

-(void)selectImageWithViewController:(UIViewController *)viewController;
-(void)takeAPhotoWithViewController:(UIViewController *)viewController;
@end
