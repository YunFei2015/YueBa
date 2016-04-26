//
//  QYPhotoBrowser.m
//  约吧
//
//  Created by 云菲 on 4/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYPhotoBrowser.h"
#import "QYPhotoBrowserCell.h"

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
    //TODO: 弹出保存菜单
    
}

#pragma mark - Setters
-(void)setPhotos:(NSArray *)photos{
    _photos = photos;
    
    [_collectionView reloadData];
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - UICollectionView Delegate & Datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoBrowserCell" forIndexPath:indexPath];
    cell.image = _photos[indexPath.row];
    
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
