//
//  ZWReceptionViewController.m
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "ZWReceptionViewController.h"
#import "HTTPServer.h"
#import "ZWHTTPConnection.h"

#import "AFNetworkReachabilityManager.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

@interface ZWReceptionViewController ()

@property (strong, nonatomic) HTTPServer *httpserver;

@property(weak, nonatomic)UIImageView *codeImageView;

@end

@implementation ZWReceptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    [self startHttpServer];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(zw_dismiss)];
//    [self zw_selectReceptionType:receptionFromIOS];
    [self zw_receptionFromIOS];
}

-(void)zw_dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//        NSLog(@"sadfhgasfsdfff");
    }];
}

-(void)zw_selectReceptionType:(receptionType)receptionType
{
    receptionType = _receptionType;
    switch (receptionType) {
        case receptionFromPC:
            [self zw_receptionFromPC];
            break;
        case receptionFromIOS:
            [self zw_receptionFromIOS];
            break;
            
        default:
            break;
    }
}

-(void)zw_receptionFromPC
{
    UIImageView *headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    headImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, 150);
    [self.view addSubview:headImageView];
    UILabel *pointsLable = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.frame.origin.x, headImageView.frame.origin.y + headImageView.frame.size.height + 10, headImageView.frame.size.width, 30)];
    pointsLable.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
    pointsLable.font = [UIFont systemFontOfSize:15];
    pointsLable.textAlignment = NSTextAlignmentCenter;
    pointsLable.text = @"在电脑浏览器中访问以下地址";
    [self.view addSubview:pointsLable];
    
    UIButton *IPbutton = [[UIButton alloc] initWithFrame:CGRectMake(50, pointsLable.frame.origin.y + pointsLable.frame.size.height + 10, [UIScreen mainScreen].bounds.size.width - 100, 40)];
    
    [IPbutton setTitle: [self zw_netWorkStatus] forState:UIControlStateNormal];
    [IPbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [IPbutton.layer setCornerRadius:20.0]; //设置矩形四个圆角半径
    IPbutton.backgroundColor = [UIColor redColor];
    IPbutton.enabled = NO;
    [self.view addSubview:IPbutton];
    
    UILabel *waringLable = [[UILabel alloc] initWithFrame:CGRectMake(pointsLable.frame.origin.x, IPbutton.frame.origin.y + IPbutton.frame.size.height + 10, pointsLable.frame.size.width, 40)];
    waringLable.numberOfLines = 0;
    waringLable.font = [UIFont systemFontOfSize:12];
    waringLable.textAlignment = NSTextAlignmentCenter;
    waringLable.text = @"请确保你的iPhone和电脑在同一个局域网中，在传输的过程中,请不要关闭这个页面";
    waringLable.textColor = [UIColor colorWithRed:174/255.0 green:162/255.0 blue:154/255.0 alpha:1.0];
    [self.view addSubview:waringLable];
}

-(NSString *)zw_netWorkStatus
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    if (manager.isReachableViaWiFi) {
       return [NSString stringWithFormat:@"htttp://%@:%hu", [self getIPAddress], [self.httpserver listeningPort]];
    }
    else
    {
        return [NSString stringWithFormat:@"当前网络不是Wi-Fi"];
    }
}

-(void)zw_receptionFromIOS
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 0.25 , 150, [UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.width * 0.5)];
    
    self.codeImageView = imageView;
    
    [self.view addSubview:self.codeImageView];
    
    UILabel *waringLable = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + 10, imageView.frame.size.width, 80)];
    waringLable.numberOfLines = 0;
    waringLable.font = [UIFont systemFontOfSize:12];
    waringLable.textAlignment = NSTextAlignmentCenter;
    waringLable.text = @"请使用摄像机扫描上面的二维码，请确保你的iPhone和对方iPhone在同一个局域网中，在传输的过程中,请不要关闭这个页面";
    waringLable.textColor = [UIColor colorWithRed:174/255.0 green:162/255.0 blue:154/255.0 alpha:1.0];
    [self.view addSubview:waringLable];
    
    [self zw_creatCode];
}

-(void)zw_creatCode

{
    
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[[NSString stringWithFormat:@"htttp://%@:%hu", [self getIPAddress], [self.httpserver listeningPort]] dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    self.codeImageView.image=[self zw_createNonInterpolatedUIImageFormCIImage:outputImage withSize:100.0];
    
    
    //如果还想加上阴影，就在ImageView的Layer上使用下面代码添加阴影
    
    self.codeImageView.layer.shadowOffset=CGSizeMake(0, 0.5);//设置阴影的偏移量
    
    self.codeImageView.layer.shadowRadius=1;//设置阴影的半径
    
    self.codeImageView.layer.shadowColor=[UIColor blackColor].CGColor;//设置阴影的颜色为黑色
    
    self.codeImageView.layer.shadowOpacity=0.3;
}



//改变二维码大小

- (UIImage *)zw_createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}

-(void)dealloc
{
    [self.httpserver stop];
    NSLog(@"httpserver stop");
}

-(void)startHttpServer
{
    HTTPServer *httpServer = [[HTTPServer alloc] init];
    self.httpserver = httpServer;
    [httpServer setType:@"_http._tcp."];
    [httpServer setPort:12345];
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    [httpServer setDocumentRoot:webPath];
    //    NSLog(@"%@",webPath);
    [httpServer setConnectionClass:[ZWHTTPConnection class]];
    
    NSError * error;
    if([httpServer start:&error])
    {
        NSLog(@"start server success in port %d %@",[httpServer listeningPort],[httpServer publishedName]);
        NSLog(@"%@",[self getIPAddress]);
    }
    else
    {
        NSLog(@"启动失败");
    }
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
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
