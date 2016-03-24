//
//  QYNetworkManager.h
//  约吧
//
//  Created by 云菲 on 3/22/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QYDownloadFileCompletion)(NSString *filePath);

@interface QYNetworkManager : NSObject
+(instancetype)sharedInstance;
-(void)downloadWithUrl:(NSString *)url withMessageID:(NSString *)messageID completion:(QYDownloadFileCompletion)downloadFileCompletion;
@end
