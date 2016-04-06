//
//  QYNetworkManager.m
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYNetworkManager.h"
#import "QYDataManager.h"
#import <AFNetworking.h>

@interface QYNetworkManager ()
@property (strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation QYNetworkManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(AFHTTPSessionManager *)manager{
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}



//-(void)downloadWithUrl:(NSString *)url withMessageID:(NSString *)messageID completion:(QYDownloadFileCompletion)downloadFileCompletion{
//    //???: 为何用AFNetworking下载后无法播放？
//#if 0
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        NSString *voicePath = [[QYDataManager sharedInstance] voiceFilePathForMessageID:messageID];
//        return [NSURL URLWithString:voicePath];
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"下载失败：%@", error);
//        }
//        NSLog(@"%@", filePath.absoluteString);
//        downloadFileCompletion(filePath.absoluteString);
//    }];
//    [task resume];
//#else
//    
//        //下载音频文件，存储到本地后播放
//    NSString *voicePath = [[QYDataManager sharedInstance] voiceFilePathForMessageID:messageID];
//        NSURLSession *session=[NSURLSession sharedSession];
//        NSURLSessionDownloadTask *task=[session downloadTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//            if (error) {
//                NSLog(@"语音文件下载失败：error===%@",error);
//                return;
//            }
//            NSLog(@"语音文件下载成功");
//            NSFileManager *manager=[NSFileManager defaultManager];
//            NSString *filesrc=[location.absoluteString substringFromIndex:6];
//            if ([manager copyItemAtPath:filesrc toPath:voicePath error:&error]) {//存储到本地
//                if (error) {
//                    NSLog(@"语音文件拷贝失败：error===%@",error);
//                    return;
//                }
//                //播放语音
//                [manager removeItemAtPath:filesrc error:&error];
//                downloadFileCompletion(voicePath);
//                return;
//            }
//        }];
//        //启动任务
//        [task resume];
//#endif
//}
@end
