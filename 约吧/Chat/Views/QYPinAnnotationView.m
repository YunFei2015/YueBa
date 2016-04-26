//
//  QYAnnotationView.m
//  约吧
//
//  Created by 云菲 on 3/29/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYPinAnnotationView.h"
#import "QYPaopaoView.h"
#import <BaiduMapAPI_Map/BMKAnnotation.h>

@implementation QYPinAnnotationView

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canShowCallout = YES;
        self.image = [UIImage imageNamed:@"located_pin"];
        
    }
    return self;
}

//-(instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.canShowCallout = YES;
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"located_pin"]];
//        imageView.frame = frame;
//        [self addSubview:imageView];
//        self.backgroundColor = [UIColor clearColor];
//    }
//    return self;
//}

@end
