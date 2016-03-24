//
//  QYImagesPicker.m
//  约吧
//
//  Created by 云菲 on 3/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYImagesPicker.h"

@interface QYImagesPicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation QYImagesPicker
#pragma mark - custom metods
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)selectImagesWithInitPickControllerCompletion:(initPickControllerCompletion)initPickControllerCompletion{
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (initPickControllerCompletion) {
        initPickControllerCompletion(_pickerController);
    }
}

-(void)takeAPhotoWithInitPickControllerCompletion:(initPickControllerCompletion)initPickControllerCompletion{
    self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    if (initPickControllerCompletion) {
        initPickControllerCompletion(_pickerController);
    }
}

#pragma mark - Getters
-(UIImagePickerController *)pickerController{
    if (_pickerController == nil) {
        _pickerController = [[UIImagePickerController alloc] init];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    NSURL *url = info[UIImagePickerControllerReferenceURL];
//    NSArray *images = @[image];
    if ([self.delegate respondsToSelector:@selector(didFinishSelectImages:)]) {
        [self.delegate didFinishSelectImages:info];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if ([self.delegate respondsToSelector:@selector(didCancelSelectImages)]) {
        [self.delegate didCancelSelectImages];
    }
}

@end
