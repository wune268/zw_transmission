//
//  ZWHomeViewController.m
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "ZWHomeViewController.h"
#import "ZWReceptionViewController.h"
#import "ZWSendFileController.h"
#import "ZWHomeTableViewCell.h"
#import "ZWFileObject.h"

#import <QuickLook/QuickLook.h>

@interface ZWHomeViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property(strong, nonatomic)NSMutableArray *fileArray;
@property(weak, nonatomic)QLPreviewController *qreviewController;
@property(copy,nonatomic)NSString *path;

@end

@implementation ZWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收文件" style:UIBarButtonItemStyleDone target:self action:@selector(zw_presentReception)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发文件" style:UIBarButtonItemStyleDone target:self action:@selector(zw_presentSend)];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    [self zw_getFileFromDocuments];
}

-(void)zw_openFielWithPath:(NSString *)cachePath fileName:(NSString *)fileName
{
    QLPreviewController *previewoCntroller = [[QLPreviewController alloc] init];
    
    self.path = cachePath;
    previewoCntroller.dataSource=self;
    [self.navigationController pushViewController: previewoCntroller animated:YES];
    [previewoCntroller setTitle:fileName];
    previewoCntroller.navigationItem.rightBarButtonItem=nil;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}


- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.path];
}

-(void)zw_getFileFromDocuments
{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
//    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:filePath];
    
    
//    //第一种方法： NSFileManager实例方法读取数据
//    filePath = [filePath stringByAppendingPathComponent:@"post.html"];
//    NSLog(@"桌面目录：%@", filePath);
//    NSFileManager* fm = [NSFileManager defaultManager];
//    NSData* data = [[NSData alloc] init];
//    data = [fm contentsAtPath:filePath];
//    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//
//    
//    //第二种方法： NSData类方法读取数据
//    data = [NSData dataWithContentsOfFile:filePath];
//    NSLog(@"NSData类方法读取的内容是：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    
//    
//    //第三种方法： NSString类方法读取内容
//    NSString* content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"NSString类方法读取的内容是：\n%@",content);
//    
//    
//    //第四种方法： NSFileHandle实例方法读取内容
//    NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
//    data = [fh readDataToEndOfFile];
//    NSLog(@"NSFileHandle实例读取的内容是：\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    
    
    
    NSArray  *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
//     return [[manager attributesOfItemAtPath:filePath error:nil] fileSize]/(1024.0*1024);
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
    
    cell.fileObject = self.fileArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZWFileObject *fileObject = self.fileArray[indexPath.row];
    [self zw_openFielWithPath:fileObject.sendFileDetailsName fileName:fileObject.sendFileName];
}

-(NSMutableArray *)fileArray
{
    if (!_fileArray) {
        NSMutableArray *fileArray = [NSMutableArray array];
        _fileArray = fileArray;
    }
    return _fileArray;
}

-(void)zw_presentSend
{
    ZWSendFileController *sendFileController = [[ZWSendFileController alloc] init];
    sendFileController.title = @"发送文件";
    [self.navigationController pushViewController:sendFileController animated:YES];
}

-(void)zw_presentReception
{
    ZWReceptionViewController *receptionFileController= [[ZWReceptionViewController alloc] init];
    UINavigationController *naV = [[UINavigationController alloc] initWithRootViewController:receptionFileController];
    naV.title = @"接收文件";
    [self.navigationController presentViewController:naV animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
