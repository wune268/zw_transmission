//
//  ZWSendFileController.m
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "ZWSendFileController.h"
#import "ZWFileObject.h"
#import "ZWHomeTableViewCell.h"

#import <AVFoundation/AVFoundation.h>


@interface ZWSendFileController ()<AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic)UIView *viewPreview;
@property (weak, nonatomic)UIButton *starButton;

@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;
@property (strong, nonatomic) UITableView *fileTableView;

@property( copy, nonatomic)NSString *scanfResult;

@property(strong, nonatomic)NSMutableArray *fileArray;

//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ZWSendFileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self zw_creatTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self zw_scanfCode];
    
}

-(void)zw_dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)zw_scanfCode
{
    self.captureSession = nil;
    self.isReading = NO;
    
    CGFloat viewPreviewX = 50;
    CGFloat viewPreviewY = 100;
    CGFloat viewPreviewW = [UIScreen mainScreen].bounds.size.width - viewPreviewX * 2;
    CGFloat viewPreviewH = viewPreviewW;
    CGFloat starButtonW = 100;
    CGFloat starButtonH = starButtonW;
    CGFloat starButtonX = ([UIScreen mainScreen].bounds.size.width - starButtonW) * 0.5;
    CGFloat starButtonY = viewPreviewH + viewPreviewY + 20;
    
    UIView *viewPreview = [[UIView alloc] initWithFrame:CGRectMake(viewPreviewX, viewPreviewY, viewPreviewW, viewPreviewH)];
    viewPreview.backgroundColor = [UIColor redColor];
    self.viewPreview = viewPreview;
    [self.view addSubview:viewPreview];
    
    UIButton *starButton = [[UIButton alloc] initWithFrame:CGRectMake(starButtonX, starButtonY, starButtonW, starButtonH)];
    [starButton setTitle: @"开始扫描" forState:UIControlStateNormal];
    starButton.backgroundColor = [UIColor grayColor];
    [starButton addTarget:self action:@selector(zw_startStopReading:) forControlEvents:UIControlEventTouchUpInside];
    [starButton.layer setCornerRadius:50];
    [self.view addSubview:starButton];
    self.starButton = starButton;

}


-(BOOL)zw_startReading
{
    NSError *error;
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [self.captureSession addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [self.captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    //7.设置预览图层填充方式
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [self.videoPreviewLayer setFrame:self.viewPreview.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    [self.viewPreview.layer addSublayer:self.videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    //10.1.扫描框
    self.boxView = [[UIView alloc] initWithFrame:CGRectMake(self.viewPreview.bounds.size.width * 0.2f, self.viewPreview.bounds.size.height * 0.2f, self.viewPreview.bounds.size.width - self.viewPreview.bounds.size.width * 0.4f, self.viewPreview.bounds.size.height - self.viewPreview.bounds.size.height * 0.4f)];
    self.boxView.layer.borderColor = [UIColor greenColor].CGColor;
    self.boxView.layer.borderWidth = 1.0f;
    
    [self.viewPreview addSubview:self.boxView];
    
    //10.2.扫描线
    self.scanLayer = [[CALayer alloc] init];
    self.scanLayer.frame = CGRectMake(0, 0, self.boxView.bounds.size.width, 1);
    self.scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [self.boxView.layer addSublayer:self.scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(zw_moveScanLayer:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    //10.开始扫描
    [self.captureSession startRunning];
    
    return YES;
}

- (void)zw_startStopReading:(UIButton *)button {
    if (!self.isReading) {
        if ([self zw_startReading]) {
            [self.starButton setTitle:@"停止扫描" forState:UIControlStateNormal];
        }
    }
    else{
        [self zw_stopReading:nil];
        [self.starButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    }
    
    self.isReading = !self.isReading;
}

#pragma mark - AVCaptureMetadataOutput 代理方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"%@--metadataObj",[metadataObj stringValue]);
            [self performSelectorOnMainThread:@selector(zw_stopReading:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            self.isReading = NO;
        }
    }
}

- (void)zw_moveScanLayer:(NSTimer *)timer
{
    CGRect frame = self.scanLayer.frame;
    if (self.boxView.frame.size.height < self.scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        self.scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 5;
        
        [UIView animateWithDuration:0.05 animations:^{
            self.scanLayer.frame = frame;
        }];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(void)zw_stopReading:(NSString *)string
{
    if (string) {
        self.title = @"连接成功";
        [self.viewPreview removeFromSuperview];
        [self.starButton removeFromSuperview];
        [self.boxView removeFromSuperview];
        [self zw_creatTableView];
    }
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.scanLayer removeFromSuperlayer];
    [self.videoPreviewLayer removeFromSuperlayer];
}

-(void)zw_creatTableView
{
    [self zw_getFileFromDocuments];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.fileTableView = tableView;
    self.fileTableView.delegate = self;
    self.fileTableView.dataSource = self;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    self.fileTableView.tableFooterView = footView;
}

-(void)zw_getFileFromDocuments
{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray  *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
    
    [self.fileArray removeAllObjects];
    for (NSString *fileName in fileArray)
    {
        if([fileName isEqualToString: @".DS_Store"]) continue;
        ZWFileObject *fileObject = [[ZWFileObject alloc] init];
        fileObject.sendFileName = fileName;
        fileObject.sendFileDetailsName = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
        fileObject.sendFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]] error:nil] fileSize]/1024.0;
        [self.fileArray addObject:fileObject];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWHomeTableViewCell *cell = [ZWHomeTableViewCell zw_cellForTableView:tableView];
    NSLog(@"cellForRowAtIndexPath");
    cell.fileObject = self.fileArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZWFileObject *fileObject = self.fileArray[indexPath.row];
# pragma 发送网络请求
}

-(NSMutableArray *)fileArray
{
    if (!_fileArray) {
        NSMutableArray *fileArray = [NSMutableArray array];
        _fileArray = fileArray;
    }
    return _fileArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
