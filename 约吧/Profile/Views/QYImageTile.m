//
//  QYImageWall.m
//  MoveView
//
//  Created by 青云-wjl on 16/4/19.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import "QYImageTile.h"
#import "Masonry.h"


#define BorderWidth 0.25
@interface QYImageTile ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,weak) UIViewController *topViewController;
@end

@implementation QYImageTile
//获取当前显示的控制器
-(UIViewController *)topViewController{
    if (_topViewController == nil) {
        UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *topVC = appRootVC;
        if (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        _topViewController = topVC;
    }
    return _topViewController;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.borderWidth = BorderWidth;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.masksToBounds = YES;
        self.image = nil;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImageFromImagePicker)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

//设置图片的时候更改_hadImage状态
-(void)setImage:(UIImage *)image{
    if (image) {
        [super setImage:image];
        self.contentMode = UIViewContentModeScaleAspectFill;
        _hadImage = YES;
    }else{
        [super setImage:[UIImage imageNamed:@"messageBar_Add"]];
        self.contentMode = UIViewContentModeCenter;
        _hadImage = NO;
    }
}

//通过重写setTileIndex方法来设置瓦片的约束，来固定瓦片的尺寸和位置
-(void)setTileIndex:(NSInteger)tileIndex{
    _tileIndex = tileIndex;
    NSLog(@"%@",NSStringFromCGRect(self.superview.frame));
    //计算各种瓦片的尺寸
    CGFloat width1 = kScreenW / 3;
    CGFloat width2 = 2 * width1;
    switch (tileIndex) {
        case 101:
        {
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(-BorderWidth);
                make.size.mas_equalTo(CGSizeMake(width2, width2));
            }];
        }break;
        case 102:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.right.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 103:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 104:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 105:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.centerX.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 106:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(-BorderWidth);
                make.bottom.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
            
        default:
            break;
    }
}

#pragma mark -添加、删除、图片

-(void)selectImageFromImagePicker{
    NSLog(@"%s",__func__);
    __weak QYImageTile *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf addImage:UIImagePickerControllerSourceTypeCamera];
    }];
    
    UIAlertAction *selectImagefromPhotoLibrary = [UIAlertAction actionWithTitle:@"选择照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf addImage:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *deleteImage = [UIAlertAction actionWithTitle:@"删除该图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_deleteImageFormTile) {
            _deleteImageFormTile(weakSelf);
        }
    }];
    
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    if (!self.hadImage) {
        [alertController addAction:takePhoto];
        [alertController addAction:selectImagefromPhotoLibrary];
    }else{
        [alertController addAction:deleteImage];
    }
    
    
    [alertController addAction:cancleAction];
    
    
    [self.topViewController presentViewController:alertController animated:YES
                                       completion:nil];
}

-(void)addImage:(UIImagePickerControllerSourceType)type{
    if ([UIImagePickerController isSourceTypeAvailable:type]) {
        //1.先选择图片
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        //指定类型为照片库
        imagePicker.sourceType = type;
        imagePicker.delegate = self;
        //用modelView展示
        [self.topViewController presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.topViewController dismissViewControllerAnimated:YES completion:nil];
    //保存选中的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (_addImageForTile) {
        _addImageForTile(image);
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.topViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
