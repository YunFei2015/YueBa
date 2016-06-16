//
//  QYScrollPhotoView.m
//  约吧
//
//  Created by 青云-wjl on 16/6/13.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYScrollPhotoView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface QYScrollPhotoView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation QYScrollPhotoView

+(instancetype)scrollPhotoViewWithImages:(NSArray *)images {
    QYScrollPhotoView *scrollPhotoView = [[QYScrollPhotoView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW)];
    //添加scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollPhotoView.frame];
    [scrollPhotoView addSubview:scrollView];
    
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = scrollPhotoView;
    
    //往scrollView添加子视图
    [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = nil;
        if ([obj isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)obj;
            imageView = [[UIImageView alloc] initWithImage:image];
        }else if ([obj isKindOfClass:[NSString class]]){
            NSString *imagePath = (NSString *)obj;
            imageView = [[UIImageView alloc] init];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil];
        }
        imageView.tag = 1000 + idx;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        [scrollView addSubview:imageView];
        scrollPhotoView.scrollView = scrollView;
        
        //添加约束
        if (idx == 0) {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.bottom.mas_equalTo(0);
                make.width.mas_equalTo(kScreenW);
                make.height.mas_equalTo(CGRectGetHeight(scrollPhotoView.frame));
                if (images.count == 1) {
                    make.trailing.mas_equalTo(0);
                }
            }];
        }else if (idx == images.count - 1){
            UIImageView *previousImageView = [scrollPhotoView viewWithTag:imageView.tag - 1];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.trailing.mas_equalTo(0);
                make.leading.equalTo(previousImageView.mas_trailing).with.offset(0);
                make.size.equalTo(previousImageView);
            }];
        }else{
            UIImageView *previousImageView = [scrollPhotoView viewWithTag:imageView.tag - 1];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(0);
                make.leading.equalTo(previousImageView.mas_trailing).with.offset(0);
                make.size.equalTo(previousImageView);
            }];
        }
    }];
    //添加pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    [scrollPhotoView addSubview:pageControl];
    pageControl.numberOfPages = images.count;
    [pageControl addTarget:scrollPhotoView action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenW);
        make.centerX.bottom.mas_equalTo(0);
    }];
    scrollPhotoView.pageControl = pageControl;
    
    return scrollPhotoView;
}

//获取当前显示的imageView
-(UIImageView *)currentDisplayImageView{
    UIImageView *currentImageView = [_scrollView viewWithTag:1000 + _pageControl.currentPage];
    return currentImageView;
}

//根据pageControl页码更改scrollView的偏移量
-(void)pageControlValueChanged:(UIPageControl *)pageControl{
    [_scrollView setContentOffset:CGPointMake(kScreenW * pageControl.currentPage, 0) animated:YES];
}

#pragma mark  -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = scrollView.contentOffset.x / kScreenW;
}

@end
