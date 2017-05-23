//
//  ViewController.m
//  YFXCameraTool
//
//  Created by fangxue on 2017/5/23.
//  Copyright © 2017年 fangxue. All rights reserved.
//  
#import "YFXCameraViewController.h"
#import "YFXCameraTool.h"
typedef enum {
    takeCamera,//拍照
    recordVideo//录像
}RecordStytle;
@interface YFXCameraViewController ()<YFXCameraToolDelegate>


@property (weak, nonatomic) IBOutlet UIButton *A;

@property (weak, nonatomic) IBOutlet UIButton *B;

@property (weak, nonatomic) IBOutlet UIButton *C;

@property (nonatomic,strong)YFXCameraTool        *cameraTool;

@property (nonatomic,assign)RecordStytle         recordStytle;
@end

@implementation YFXCameraViewController
//隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    
    return YES;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //默认设置
    self.recordStytle = takeCamera;
    
    self.cameraTool.videoWidth  = 720;       //相机分辨率宽
    
    self.cameraTool.videoHeight = 1280;      //相机分辨率高
    
    [self.cameraTool switchSessionPreset:AVCaptureSessionPresetiFrame1280x720];
    
}
- (void)changeAVCaptureSessionPresetiFrame{
    
    //具体分辨率还有很多 switchSessionPreset方法中我只写了2个
    [self.cameraTool switchSessionPreset:AVCaptureSessionPreset1920x1080];
    
    self.cameraTool.videoWidth  = 1080;
    
    self.cameraTool.videoHeight = 1920;
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.cameraTool.previewLayer.frame = [UIScreen mainScreen].bounds;
    
    if ([[self.cameraTool.previewLayer connection] isVideoOrientationSupported])
    {
        [[self.cameraTool.previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
    }
    [self.view.layer insertSublayer:self.cameraTool.previewLayer atIndex:0];
    
    [self.cameraTool startUp];
    //设置自动对焦
    [self.cameraTool resetFocusAndExposureModes];
    
    if (self.recordStytle==takeCamera) {
        
        [self.cameraTool setupPhotoSession];
    }
    if (self.recordStytle==recordVideo) {
        
        [self.cameraTool setupVideoSession];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.cameraTool shutdown];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.cameraTool.previewLayer.frame = [UIScreen mainScreen].bounds;
    
    if ([[self.cameraTool.previewLayer connection] isVideoOrientationSupported])
    {
        //设置视频方向的正确性
        [[self.cameraTool.previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[UIApplication sharedApplication].statusBarOrientation];
    }
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft|toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        
        //横屏 用于改变UI按钮frame
    }
    else {
        
        //竖屏 用于改变UI按钮frame
    }
}
- (YFXCameraTool *)cameraTool{
    
    if (!_cameraTool) {
        
        _cameraTool = [[YFXCameraTool alloc]init];
        
        _cameraTool.cameraToolDelegate = self;
    }
    return _cameraTool;
}
//视频数据帧转图片
- (void)getVideoImage:(UIImage *)image{
    
    NSLog(@"%@",image);
}
//拍照图片
- (void)getPhoto:(UIImage *)image{
    
    NSLog(@"%@",image);
}
- (IBAction)A:(id)sender {
    
    self.A.selected = !self.A.selected;
    
    if (self.A.selected==YES) {
        
        [self.A setTitle:@"录像模式" forState:0];
        
        self.recordStytle = recordVideo;
        
        [self.cameraTool setupVideoSession];
    }
    if (self.A.selected==NO) {
        
        self.recordStytle = takeCamera;
        
        [self.A setTitle:@"拍照模式" forState:0];
        
        [self.cameraTool setupPhotoSession];
    }
    if (self.recordStytle==takeCamera) {
        
        [self.B setTitle:@"点击拍照" forState:0];
        
    }
    if (self.recordStytle==recordVideo) {
        
        [self.B setTitle:@"点击录像" forState:0];
    }
}
- (IBAction)B:(id)sender {
    
    if (self.recordStytle==takeCamera) {
        
        [self.B setTitle:@"点击拍照" forState:0];
        
        [self.cameraTool takePhoto];
    }
    if (self.recordStytle==recordVideo) {
        
        [self.B setTitle:@"点击录像" forState:0];
        
        [self.cameraTool startRecoard];
    }
}
- (IBAction)C:(id)sender {
    
    //停止录像
    [self.cameraTool stopRecoard];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
