//
//  QYPhotoBrowserCell.h
//  约吧
//
//  Created by 云菲 on 4/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYPhotoBrowserCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) NSString *url;

@end
