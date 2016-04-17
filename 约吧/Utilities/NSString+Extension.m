//
//  NSString+Extension.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "NSString+Extension.h"
#import "FaceModel.h"

@implementation NSString (Extension)

-(CGSize)sizeWithFont:(UIFont *)font forSize:(CGSize)scheduleSize attributes:(NSDictionary *)attributes{
    CGRect rect = [self boundingRectWithSize:scheduleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size;
}

+(BOOL)isTelephoneNumber:(NSString *)telephone{
    //检查是否为手机号
    //    电信号段:133/153/180/181/189/177
    //    联通号段:130/131/132/155/156/185/186/145/176
    //    移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    //    虚拟运营商:170
    NSString *telFormat = @"^1(3\\d|4[57]|5[0-35-9]|7[06-8]|8\\d)\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telFormat];
    BOOL isTel = [predicate evaluateWithObject:telephone];
    return isTel;
}

+(NSString *)pathInDocumentWithFileName:(NSString *)fileName{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+(NSAttributedString *)faceAttributeTextWithMessage:(NSString *)message withAttributes:(NSDictionary *)attributes faceSize:(CGFloat)faceSize{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Faces" ofType:@"plist"];
    NSArray *faces = [NSDictionary dictionaryWithContentsOfFile:path][kFaceTT];
    
    NSMutableAttributedString *messageAttriText = [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
    [faces enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FaceModel *face = [FaceModel faceModelWithDictionary:obj];
        if ([message containsString:face.text]) {
            UIFont *font = attributes[NSFontAttributeName];
            //创建富文本
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *image = [UIImage imageNamed:face.imgName];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, -8, faceSize, faceSize);
            NSAttributedString *attributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
            
            //用富文本替换表情文本
            NSRange resultRange;
            NSRange searchRange = NSMakeRange(0, messageAttriText.length);
            while ((resultRange = [[messageAttriText string] rangeOfString:face.text options:0 range:searchRange]).location != NSNotFound) {
                [messageAttriText replaceCharactersInRange:resultRange withAttributedString:attributeStr];
                resultRange.length = 1;
                searchRange = NSMakeRange(NSMaxRange(resultRange), messageAttriText.length - NSMaxRange(resultRange));
            }
        }
    }];
    return messageAttriText;
}

@end
