//
//  QYVoiceRecordingView.m
//  约吧
//
//  Created by 云菲 on 3/23/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYVoiceRecordingView.h"

@interface QYVoiceRecordingView ()
@property (weak, nonatomic) IBOutlet UIImageView *recordingStateImgView;
@property (weak, nonatomic) IBOutlet UIImageView *powerValueAnimatingImgView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation QYVoiceRecordingView

-(void)setRecording:(BOOL)recording{
    _recording = recording;
    
    if (_recording) {
        _recordingStateImgView.image = [UIImage imageNamed:@"Sending-voice-mic"];
        _tipLabel.text = @"手指上滑，取消发送";
    }else{
        _recordingStateImgView.image = [UIImage imageNamed:@"Cancel-voice-mic"];
        _tipLabel.text = @"松开手指，取消发送";
    }
}

-(void)setPeakPower:(float)peakPower{
    NSLog(@"peakPowerValue：%f", peakPower);
    for (int i = 0; i < 8; i++) {
        float j = (i + 1) / 10.f;
        if (peakPower <= j && peakPower > j - 0.1) {
            NSString *imageName = [NSString stringWithFormat:@"RecordingSignal00%d", i + 1];
            _powerValueAnimatingImgView.image = [UIImage imageNamed:imageName];
            break;
        }
    }
}

@end
