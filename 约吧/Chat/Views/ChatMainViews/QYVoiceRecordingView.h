//
//  QYVoiceRecordingView.h
//  约吧
//
//  Created by 云菲 on 3/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYVoiceRecordingView : UIView
@property (nonatomic, getter=isRecording) BOOL recording;
@property (nonatomic) float peakPower;
-(void)updatePowerValueViewWith:(float)peakPowerValue;
@end
