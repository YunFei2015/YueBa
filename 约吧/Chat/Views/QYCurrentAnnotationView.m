//
//  QYCurrentAnnotationView.m
//  约吧
//
//  Created by 云菲 on 3/29/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYCurrentAnnotationView.h"
#import "UIView+Extension.h"

@implementation QYCurrentAnnotationView

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationSharing_Icon_MySelf"]];
        imageView.frame = CGRectMake(-10, 40, 100, 100);
        self.image = [self getImageFromView:imageView];
    }
    return self;
    
}

-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat blankW = 2;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 20, 20)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = view.frame.size.width;
        view.layer.masksToBounds = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationSharing_Icon_MySelf"]];
        imageView.frame = CGRectMake(blankW, blankW, view.frame.size.width - blankW * 2, view.frame.size.height - blankW * 2);
        [view addSubview:imageView];
        
        [self addSubview:view];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    
    
    [super drawRect:rect];
}

@end
