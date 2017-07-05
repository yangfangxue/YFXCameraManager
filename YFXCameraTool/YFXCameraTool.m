//
//  YFXCameraTool.m
//  Sight
//
//  Created by fangxue on 2017/1/22.
//  Copyright © 2017年 fangxue. All rights reserved.
//
#import "YFXCameraTool.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UIImage+FixOrientation.h"
#import "MBProgressHUD+JDragon.h"
@interface YFXCameraTool()

@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic, assign) BOOL isStart;

@end

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@implementation YFXCameraTool

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    return self;
}
//启动
- (void)startUp{
   
    [self.captureSession startRunning];
}
//关闭
- (void)shutdown{
    
    if (self.captureSession) {
        
        [self.captureSession stopRunning];
    }
}
#pragma mark 懒加载
/*相册*/
- (ALAssetsLibrary *)library{
    
    if (!_library) {
        
        _library = [[ALAssetsLibrary alloc]init];
    }
    return _library;
}
/*变焦大小*/
- (CGFloat)effectiveScale{
    
    if (!_effectiveScale) {
        
        _effectiveScale = 1.0;
    }
    return _effectiveScale;
}
/*视频写入类*/
- (AVAssetWriter *)writer{
    
    if (!_writer) {
        
        _writer = [AVAssetWriter assetWriterWithURL:self.videoUrl fileType:AVFileTypeQuickTimeMovie error:nil];
        
        _writer.shouldOptimizeForNetworkUse = YES;
    }
    
    return _writer;
}
/*音频写入类*/
- (AVAssetWriterInput *)audioInput{
    
    if (!_audioInput) {
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [ NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                   [ NSNumber numberWithFloat: 44100], AVSampleRateKey,
                                   [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                                   nil];
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
        
        _audioInput.expectsMediaDataInRealTime = YES;
    }
    return _audioInput;
}
/*音频数据数据输出*/
- (AVCaptureAudioDataOutput *)audioOutput{
    
    if (!_audioOutput) {
        
        _audioOutput = [[AVCaptureAudioDataOutput alloc]init];
        
        [_audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    }
    return _audioOutput;
}
/*视频本地url路径*/
- (NSURL *)videoUrl{
    
    if (!_videoUrl) {
        
        NSDate *date = [NSDate date];
        
        NSString *string = [NSString stringWithFormat:@"%ld.mov",(unsigned long)(date.timeIntervalSince1970 * 1000)];
        
        NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:string];
        
        _videoUrl = [NSURL fileURLWithPath:cachePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        }
        
    }
    return _videoUrl;
}
/*相机预览层*/
- (AVCaptureVideoPreviewLayer *)previewLayer {
    
    if (!_previewLayer) {
        
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _previewLayer = preview;
    }
    return _previewLayer;
}
/*设备输入类*/
- (AVCaptureDeviceInput *)captureDeviceInput{
    
    if (!_captureDeviceInput) {
        
        AVCaptureDevice *captureDevice =[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
        
        _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:nil];
    }
    return _captureDeviceInput;
}
/*管理拍照和视频会话*/
- (AVCaptureSession *)captureSession{
    
    if (!_captureSession) {
        
        _captureSession = [[AVCaptureSession alloc]init];
        
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;//默认输出分辨率
        
        //摄像头设备输入
        if ([_captureSession canAddInput:self.captureDeviceInput]) {
            
            [_captureSession addInput:self.captureDeviceInput];
        }
        //麦克风音频设备输入
        if ([_captureSession canAddInput:self.captureDeviceInputAudio]) {
            
            [_captureSession addInput:self.captureDeviceInputAudio];
        }
        //视频数据输出
        if ([_captureSession canAddOutput:self.videoOutput]) {
            
            [_captureSession addOutput:self.videoOutput];
        }
        //图片数据输出
        if ([_captureSession canAddOutput:self.captureStillImageOutput]) {
            
            [_captureSession addOutput:self.captureStillImageOutput];
        }
    }
    return _captureSession;
}
/*图片输出*/
- (AVCaptureStillImageOutput *)captureStillImageOutput{
    
    if (!_captureStillImageOutput) {
        
        _captureStillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        
        NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        
        [_captureStillImageOutput setOutputSettings:outputSettings];
    }
    
    return _captureStillImageOutput;
}
/*音频设备输入*/
- (AVCaptureDeviceInput *)captureDeviceInputAudio{
    
    if (!_captureDeviceInputAudio) {
        
        AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        _captureDeviceInputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:nil];
    }
    return _captureDeviceInputAudio;
}
/*视频数据输出*/
- (AVCaptureVideoDataOutput *)videoOutput{
    
    if (!_videoOutput) {
        
        _videoOutput = [[AVCaptureVideoDataOutput alloc]init];
        
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        _videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],kCVPixelBufferPixelFormatTypeKey,nil];
    }
    return _videoOutput;
}
#pragma mark 拍照
- (void)setupPhotoSession{
    
    [self.captureSession beginConfiguration];
    
    for (AVCaptureInput *input in self.captureSession.inputs) {
        
        [self.captureSession removeInput:input];
    }
    for (AVCaptureOutput *ouput in self.captureSession.outputs) {
        
        [self.captureSession removeOutput:ouput];
    }
    //视频数据输出
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        
        [self.captureSession addOutput:self.videoOutput];
    }
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        
        [self.captureSession addInput:self.captureDeviceInput];
    }
    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        
        [self.captureSession addOutput:self.captureStillImageOutput];
    }
    [self.captureSession commitConfiguration];
}
- (BOOL)resetFocusAndExposureModes{
    
    AVCaptureDevice *device= [self.captureDeviceInput device];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
        return YES;
    }
    else{
       
        return NO;
    }
}
//聚焦
-(void)tapAction:(CGPoint )point{
    
    if ([self cameraSupportsTapToFocus]) {
        
        [self focusAtPoint:point];
    }
}
- (void)focusAtPoint:(CGPoint)point{
    
    AVCaptureDevice *device = [self.captureDeviceInput device];
    
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else{
            
            NSLog(@"error");
        }
    }
}
- (BOOL)cameraSupportsTapToFocus {
    
    return [[self.captureDeviceInput device] isFocusPointOfInterestSupported];
}
//曝光
-(void)doubleTapAction:(CGPoint )point{
    
    if ([self cameraSupportsTapToExpose]) {
        
        [self exposeAtPoint:point];
    }
}
- (BOOL)cameraSupportsTapToExpose {
    
    return [[self.captureDeviceInput device] isExposurePointOfInterestSupported];
}

static const NSString *CameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self.captureDeviceInput device];
    if ([self cameraSupportsTapToExpose] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        else{
            
             NSLog(@"error");
        }
    }
}
- (void)cameraBackgroundDidClickOpenAntiShake {
    
    AVCaptureConnection *captureConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    if ([videoDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &CameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                     device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }
                else{
                   
                    NSLog(@"error");
                }
            });
        }
    }
    else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

//开启闪光灯
- (void)openFlashLight {
    
    AVCaptureDevice *backCamera = [self backCamera];
    
    if (backCamera.flashMode == AVCaptureTorchModeOff||backCamera.flashMode==AVCaptureFlashModeAuto) {
        
        [backCamera lockForConfiguration:nil];
        
        backCamera.flashMode = AVCaptureFlashModeOn;
        
        [backCamera unlockForConfiguration];
    }
}
//关闭闪光灯
- (void)closeFlashLight{
    
    AVCaptureDevice *backCamera = [self backCamera];
    
    if (backCamera.flashMode == AVCaptureTorchModeOn||backCamera.flashMode==AVCaptureFlashModeAuto) {
        
        [backCamera lockForConfiguration:nil];
        
        backCamera. flashMode = AVCaptureTorchModeOff;
        
        [backCamera unlockForConfiguration];
    }
}
- (void)takePhoto{
    
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([captureConnection isVideoOrientationSupported])
    {   //输出图片的方向
        [captureConnection setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
    }
    [captureConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIImage *image = [[UIImage imageWithData:imageData]fixOrientation];
            
            [self savePhoto:[UIImage imageWithData:UIImagePNGRepresentation(image)]];
            
            if ([self.cameraToolDelegate respondsToSelector:@selector(getPhoto:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [self.cameraToolDelegate getPhoto:image];
                    
                });
            }
        }
    }];
}
//改变摄像头
- (void)changeCameraInputDeviceis{
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    
    if (cameraCount > 1) {
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.captureDeviceInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.captureDeviceInput];
            if ([self.captureSession canAddInput:newInput]) {
                [self.captureSession addInput:newInput];
                 self.captureDeviceInput = newInput;
            }else {
                [self.captureSession addInput:self.captureDeviceInput];
            }
            [self.captureSession commitConfiguration];
        }
    }
}
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}
//切换摄像头动画
- (void)changeCameraAnimation{
    
    CATransition *changeAnimation = [CATransition animation];
    
    changeAnimation.delegate = self;
    
    changeAnimation.duration = 0.30;
    
    changeAnimation.type = @"oglFlip";
    
    changeAnimation.subtype = kCATransitionFromRight;
    
    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    
    [self.previewLayer addAnimation:changeAnimation forKey:@"changeAnimation"];
}
- (void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    
    NSError *error;
    
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
       
    }
}

- (AVCaptureDevice *)backCamera {
    
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}
//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
//对焦
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        if ([captureDevice isFocusModeSupported:focusMode]) {
            
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}
//数码变焦
- (void)cameraBackgroundDidChangeZoom{
    
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    
    NSError *error;
    
    if ([captureDevice lockForConfiguration:&error]) {
        
        [captureDevice rampToVideoZoomFactor:self.effectiveScale withRate:50];
        
        [captureDevice unlockForConfiguration];
    }
}
//改变视频分辨率
- (void)switchSessionPreset:(NSString *)sessionPreset{
    
    [self.captureSession beginConfiguration];
    
    if ([sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            
            self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        }
    }
    if ([sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720]) {
        
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]){
            
            self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        }
    }
    [self.captureSession commitConfiguration];
}
#pragma mark 摄像
-(void)setupVideoSession{
    
    [self.captureSession beginConfiguration];
    
    for (AVCaptureInput *input in self.captureSession.inputs) {
        
        [self.captureSession removeInput:input];
    }
    for (AVCaptureOutput *ouput in self.captureSession.outputs) {
        
        [self.captureSession removeOutput:ouput];
    }
    //摄像头设备输入
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        
        [self.captureSession addInput:self.captureDeviceInput];
    }
    //麦克风音频设备输入
    if ([self.captureSession canAddInput:self.captureDeviceInputAudio]) {
        
        [self.captureSession addInput:self.captureDeviceInputAudio];
    }
    //视频数据输出
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        
        [self.captureSession addOutput:self.videoOutput];
    }
    //音频数据输出
    if ([self.captureSession canAddOutput:self.audioOutput]) {
        
        [self.captureSession addOutput:self.audioOutput];
    }
       [self cameraBackgroundDidClickOpenAntiShake];
    
       [self.captureSession commitConfiguration];
}
- (void)startRecoard{
   
        self.isStart = YES;
}
- (void)stopRecoard{
    
        self.isStart = NO;
        
        [self.videoInput markAsFinished];
        
        [self.audioInput markAsFinished];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.writer finishWritingWithCompletionHandler:^{
                
                [self savePhotoCmare:self.videoUrl];
                
                self.videoUrl = nil;
                
                self.writer = nil;
            }];
        });
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (captureOutput == self.videoOutput) {
        
        AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([videoConnection isVideoOrientationSupported]){
            
            [videoConnection setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
        }
        //代理
        if ([self.cameraToolDelegate respondsToSelector:@selector(getVideoImage:)]&&self.isGetImage==YES) {
            
            UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.cameraToolDelegate getVideoImage:image];
            });
        }
        
    }
    static int frame = 0;
    
    @synchronized(self) {
     
    if( frame == 0 && self.writer.status == AVAssetWriterStatusUnknown && self.isStart == YES)
    {
            AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
            NSDictionary *settings;
        
            if ([videoConnection isVideoOrientationSupported]){
            
                [videoConnection setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
            }
            if (videoConnection.videoOrientation == AVCaptureVideoOrientationPortrait) {
                
                    settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInteger: self.videoWidth], AVVideoWidthKey,
                                              [NSNumber numberWithInteger: self.videoHeight], AVVideoHeightKey,
                                              nil];
                }
                else{
                    
                    settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInteger: self.videoHeight], AVVideoWidthKey,
                                              [NSNumber numberWithInteger: self.videoWidth], AVVideoHeightKey,
                                              nil];
        }
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        
        self.videoInput.expectsMediaDataInRealTime = YES;
    
        [self.captureSession beginConfiguration];
        
        //视频数据输入
        if ([self.writer canAddInput:self.videoInput]) {
            
            [self.writer addInput:self.videoInput];
        }
        //音频数据输入
        if ([self.writer canAddInput:self.audioInput]) {
            
            [self.writer addInput:self.audioInput];
        }
        [self.captureSession commitConfiguration];
        
        CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        [self.writer startWriting];
        
        [self.writer startSessionAtSourceTime:lastSampleTime];
        
        NSLog(@"写入数据");
    }
    //写入失败
    if (self.writer.status == AVAssetWriterStatusFailed) {
        
        NSLog(@"%@",self.writer.error.localizedDescription);
    }
    if (self.isStart == YES) {
        
        if (captureOutput == self.videoOutput) {
            
            if ([self.videoInput isReadyForMoreMediaData]) {
                //拼接视频数据
                [self.videoInput appendSampleBuffer:sampleBuffer];
                
                [self cameraBackgroundDidChangeZoom];
            }
        }
        if (captureOutput ==self.audioOutput) {
            
            if ([self.audioInput isReadyForMoreMediaData]){
                //拼接音频数据
                [self.audioInput appendSampleBuffer:sampleBuffer];
            }
        }
     }
  }
}
// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return (image);
}
#pragma mark  保存
- (void)savePhotoCmare:(NSURL *)url
{
    [self.library saveVideo:url toAlbum:@"视频相册" completion:^(NSURL *assetURL, NSError *error) {
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"保存视频成功");
                
                [MBProgressHUD showSuccessMessage:NSLocalizedString(@"保存视频成功", nil)];
                
            });
        }
        
    } failure:^(NSError *error) {
        
        
    }];
}
- (void)savePhoto:(UIImage *)image{
    
    [self.library saveImage:image toAlbum:@"图片相册" completion:^(NSURL *assetURL, NSError *error) {
        
        if (!error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"保存照片成功");
                
                [MBProgressHUD showSuccessMessage:NSLocalizedString(@"保存照片成功", nil)];
                
            });
        }
    } failure:^(NSError *error) {
        
        
    }];
}

@end
