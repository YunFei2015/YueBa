//
//  FaceView.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "FacesView.h"
#import "FaceModel.h"
#import "FaceCell.h"


#define kFaceWidth 60
#define kFaceHeight 40

@interface FacesView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *facesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UIView *faceCategoriesView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@property (strong, nonatomic) NSArray *twoDimenFaces;
@property (strong, nonatomic) FaceModel *removeFace;
@property (strong, nonatomic) FaceModel *nilFace;

@property (nonatomic) NSInteger columns;//每页列数，即每行的表情个数
@property (nonatomic) NSInteger lines;//每页行数
@property (nonatomic) NSInteger page;//页数

@end

@implementation FacesView

-(void)awakeFromNib{
    [_facesCollectionView registerNib:[UINib nibWithNibName:kFaceCellNib bundle:nil] forCellWithReuseIdentifier:kFaceCellIdentifier];
    
    //根据屏幕宽度调整表情视图布局
    _columns = kScreenW / kFaceWidth;//每页列数，即每行的表情个数
    _lines = _facesCollectionView.bounds.size.height / kFaceHeight;//每页行数
    CGFloat width = kScreenW / _columns;
    CGFloat height = _facesCollectionView.bounds.size.height / _lines;
    _collectionViewFlowLayout.itemSize = CGSizeMake(width, height);
    
    //页数
    _page = self.faces.count / _columns / _lines;
    _pageControl.numberOfPages = _page;
}

#pragma mark - events
- (IBAction)faceCatAction:(UIButton *)sender {
    switch (sender.tag) {
        case kFaceCategoryTT://探探自带的表情
        
            break;
            
        case kFaceCategoryCharacter://符号表情
            
            break;
            
        default:
            break;
    }
    
    [_facesCollectionView reloadData];
}

#pragma mark - collection view delegate & dataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.twoDimenFaces.count;//即总列数
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _lines;//即行数
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFaceCellIdentifier forIndexPath:indexPath];
    
    //configure cell
    FaceModel *face = _twoDimenFaces[indexPath.section][indexPath.row];
    cell.face = face;

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FaceCell *cell = (FaceCell *) [collectionView cellForItemAtIndexPath:indexPath];
    if (cell.face.category == 0) {
        return;
    }
    
    self.selectFace(cell.face);
}

#pragma mark - scroll view delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = scrollView.contentOffset.x / kScreenW;
}

#pragma mark - getters
-(NSArray *)faces{
    if (_faces == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Faces" ofType:@"plist"];
        NSDictionary *facesDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *TTFaces = facesDict[kFaceTT];
        NSMutableArray *faces = [NSMutableArray array];
        NSInteger countPerPage = _columns * _lines;//每页的表情数
        [TTFaces enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((idx + 1) % countPerPage == 0) {//每页的最后一个表情用删除键占位
                [faces addObject:self.removeFace];
            }
            FaceModel *face = [FaceModel faceModelWithDictionary:obj];
            [faces addObject:face];
            if (idx == TTFaces.count - 1) {
                [faces addObject:self.removeFace];
            }
        }];
        
        if (faces.count % countPerPage != 0) {//如果表情个数不满_page页，则剩余补上空face
            NSInteger count = faces.count;
            for (NSInteger i = 0; i < countPerPage - count % countPerPage; i++) {//在最后一个删除键前面插入nilFace
                [faces insertObject:self.nilFace atIndex:faces.count - 1];
            }
        }
        
        _faces = faces;
    }
    return _faces;
}

//根据行数和列数构造二维数组(每列表情构造为一个数组)
-(NSArray *)twoDimenFaces{
    if (_twoDimenFaces == nil) {
        //初始化二维数组
        NSInteger countOfArray = _columns * _page;
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 0; i < countOfArray; i++) {
            NSMutableArray *array = [NSMutableArray array];
            [tempArr addObject:array];
        }
        
        //填充数据
        [self.faces enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger indexInArr = idx / _columns % _lines;
            NSInteger indexForArr = idx % _columns + _columns * (idx / _columns / _lines);
            [tempArr[indexForArr] insertObject:obj atIndex:indexInArr];
        }];
        _twoDimenFaces = tempArr;
    }
    return _twoDimenFaces;
}

-(FaceModel *)removeFace{
    if (_removeFace == nil) {
        _removeFace = [[FaceModel alloc] init];
        _removeFace.imgName = @"ic_back_emojis";
        _removeFace.category = kFaceCategoryRemove;
    }
    return _removeFace;
}

-(FaceModel *)nilFace{
    if (_nilFace == nil) {
        _nilFace = [[FaceModel alloc] init];
        _nilFace.imgName = nil;
        _nilFace.category = 0;
    }
    return _nilFace;
}

@end
