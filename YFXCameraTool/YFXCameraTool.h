//
//  YFXCameraTool.h
//  Sight
//  
//  Created by fangxue on 2017/1/22.
//  Copyright © 2017年 fangxue. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol YFXCameraToolDelegate <NSObject>

//视频数据帧转图片
- (void)getVideoImage:(UIImage *)image;
//拍照图片
- (void)getPhoto:(UIImage *)image;

@end

@interface YFXCameraTool : NSObject<CAAnimationDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession     *captureSession;//服务Session
//拍照
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;//设备输入
@property (nonatomic, strong) AVCaptureStillImageOutput  *captureStillImageOutput;//照片输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//相机拍摄预览图层
//摄像
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;//视频文件输出
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInputAudio;//设备音频输入
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;//音频输出
//写入数据相关
@property (nonatomic, strong) NSURL *videoUrl;//写入文件文件本地URL
@property (nonatomic, strong) AVAssetWriter *writer;//媒体写入对象
@property (nonatomic, strong) AVAssetWriterInput *videoInput;//视频写入
@property (nonatomic, strong) AVAssetWriterInput *audioInput;//音频写入
@property (nonatomic, assign) NSInteger videoWidth;//视频宽
@property (nonatomic, assign) NSInteger videoHeight;//视频高
@property (nonatomic, assign) CGFloat   effectiveScale;//数码变焦  1.0 - 3.0
@property (nonatomic, weak  ) id<YFXCameraToolDelegate>cameraToolDelegate;
//控制相关
@property (nonatomic, assign) BOOL isGetImage;//是否回调视频帧代理

#pragma mark 拍照
//建立拍照会话
- (void)setupPhotoSession;
//拍照
- (void)takePhoto;
//切换摄像头
- (void)changeCameraInputDeviceis;
//打开闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//设置聚焦点
-(void)tapAction:(CGPoint )point;
//设置曝光点
-(void)doubleTapAction:(CGPoint )point;
//设置自动曝光/聚焦
- (BOOL)resetFocusAndExposureModes;
#pragma mark 录像
//建立视频会话
- (void)setupVideoSession;
//开始拍摄
- (void)startRecoard;
//停止拍摄
- (void)stopRecoard;
//启动拍摄
- (void)startUp;
//关闭拍摄
- (void)shutdown;
//改变录制视频输出分辨率
- (void)switchSessionPreset:(NSString *)sessionPreset;

@end
