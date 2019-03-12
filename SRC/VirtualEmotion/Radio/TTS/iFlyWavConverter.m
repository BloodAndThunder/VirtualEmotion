//
//  iFlyWavConverter.m
//  TripStickyInScene
//
//  Created by JiangZhuo on 7/15/17.
//  Copyright © 2017 qunar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iFlyWavConverter.h"
#import <iflyMSC/iflyMSC.h>
#import "TTSConfig.h"
#import "NSString+Hash.h"

@interface iFlyWavConverter ()

@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, strong) void (^completionHandlerBlock)(NSString *);

@end

@implementation iFlyWavConverter

+ (void)initUtility{
    
    //Set APPID
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"56df95f3"];
    
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSynthesizer];
    }
    return self;
}

- (void)initSynthesizer
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //TTS singleton
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //set speed,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //set volume,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //set pitch,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //set sample rate
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //set TTS speaker
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:@"vixq"];
    
    //set text encoding mode
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
}

- (void)getPathTextToSpeech:(NSString *)text completionHandler:(void (^)(NSString *))block {
    
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    //Set the audio file name for URI TTS
    _uriPath = [NSString stringWithFormat:@"%@/%@",prePath,text.sha1];
    NSString *wavPath = [_uriPath stringByAppendingString:@".wav"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:wavPath]) {
        block(wavPath);
        return;
    }
    
    // 获取语音
    NSString *pcmPath = [_uriPath stringByAppendingString:@".pcm"];
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer synthesize:text toUri:pcmPath];
    _completionHandlerBlock = block;
}

- (void)onCompleted:(IFlySpeechError*)error {
    if (error.errorCode != 0) {
        NSLog(@"%@",error.errorDesc);
        return;
    }
    
    NSString *pcmPath = [_uriPath stringByAppendingString:@".pcm"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:pcmPath]) {
        
        TTSConfig *instance = [TTSConfig sharedInstance];
        NSData *audioData = [NSData dataWithContentsOfFile:pcmPath];
        
        NSString *wavPath = [_uriPath stringByAppendingString:@".wav"];
        
        [self writeWaveHead:audioData sampleRate:[instance.sampleRate integerValue] saveInPath:wavPath];
        
        if (_completionHandlerBlock != nil) {
            _completionHandlerBlock(wavPath);
        }
    }
}

- (void)writeWaveHead:(NSData *)audioData sampleRate:(long)sampleRate saveInPath:(NSString *)path{
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = sampleRate * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    NSMutableData *pcmData = [[NSMutableData alloc]initWithBytes:&waveHead length:sizeof(waveHead)];
    [pcmData appendData:audioData];
    
    //Set the audio file name for URI TTS
    [pcmData writeToFile:path atomically:NO];
}

@end
