//
//  QYCacheClearCell.m
//  约吧
//
//  Created by 云菲 on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYCacheClearCell.h"
#import "NSString+Extension.h"

@implementation QYCacheClearCell

- (void)awakeFromNib {
    // Initialization code
    NSString *path = [NSString pathInLibraryWithFileName:@"Caches/AVPaasFiles"];
    float size = [self fileSizeForDir:path];
    
    if (size == 0) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%.fMB",size];
    }else if (size < 1024.f) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%.fB",size];
    }else if (size < 1024.f * 1024.f){
        self.detailTextLabel.text = [NSString stringWithFormat:@"%.1fKB",size / 1024.f];
    }else{
        self.detailTextLabel.text = [NSString stringWithFormat:@"%.1fMB",size / 1024.f / 1024.f];
    }
}

//计算图片和音频缓存
-(float)fileSizeForDir:(NSString *)path{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float size =0;
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            size += [self fileSizeForDir:fullPath];
        }
    }
    return size;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
