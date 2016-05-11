//
//  QYPhotoBrowser.m
//  约吧
//
//  Created by 云菲 on 4/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYPhotoBrowser.h"
#import "QYPhotoBrowserCell.h"

#import <UIImageView+WebCache.h>

@interface QYPhotoBrowser () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation QYPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_collectionView registerNib:[UINib nibWithNibName:@"QYPhotoBrowserCell" bundle:nil] forCellWithReuseIdentifier:@"photoBrowserCell"];
    
    _flowLayout.itemSize = CGSizeMake(kScreenW, kScreenH);
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [_collectionView addGestureRecognizer:longPress];
}


#pragma mark - Custom Methods
-(void)longPressAction:(UILongPressGestureRecognizer *)sender{
    CGPoint point = [sender locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    QYPhotoBrowserCell *cell = (QYPhotoBrowserCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImageWriteToSavedPhotosAlbum(cell.photoView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    [controller addAction:action];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [controller addAction:action1];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    if (error == nil) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片已存入手机相册" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Setters
-(void)setUrls:(NSArray *)urls{
    _urls = urls;
    
    [_collectionView reloadData];
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - UICollectionView Delegate & Datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _urls.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoBrowserCell" forIndexPath:indexPath];
    
    NSString *url = _urls[indexPath.row];
    [cell.photoView sd_setImageWithURL:[NSURL fileURLWithPath:url]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _selectedCell = (QYPhotoBrowserCell *)[collectionView cellForItemAtIndexPath:indexPath];
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
