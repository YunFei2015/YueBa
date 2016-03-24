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

-(void)didFinishSelectImages:(NSDictionary *)info;
-(void)didCancelSelectImages;

@end

typedef void(^initPickControllerCompletion)(UIImagePickerController *pickerController);
//typedef void(^selectImagesCompletion)(NSArray *);
//typedef void(^cancelSelectImagesCompletion)();

@interface QYImagesPicker : NSObject
@property (nonatomic) id <QYImagesPickerDelegate> delegate;
@property (strong, nonatomic) UIImagePickerController *pickerController;
//@property (weak, nonatomic) selectImagesCompletion selectImagesCompletion;
//@property (weak, nonatomic) cancelSelectImagesCompletion cancelSelectImagesCompletion;

+(instancetype)sharedInstance;
-(void)selectImagesWithInitPickControllerCompletion:(initPickControllerCompletion)initPickControllerCompletion;
-(void)takeAPhotoWithInitPickControllerCompletion:(initPickControllerCompletion)initPickControllerCompletion;
@end
