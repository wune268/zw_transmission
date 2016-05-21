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
#import "MJRefresh.h"

#import <QuickLook/QuickLook.h>

@interface ZWHomeViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property(strong, nonatomic)NSMutableArray *fileArray;
@property(weak, nonatomic)QLPreviewController *qreviewController;
@property(copy,nonatomic)NSString *path;

@end

@implementation ZWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zw_getFileFromDocuments];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *PCbutton  = [[UIBarButtonItem alloc] initWithTitle:@"电脑" style:UIBarButtonItemStyleDone target:self action:@selector(zw_presentReceptionPC)];
    UIBarButtonItem *IOSbutton = [[UIBarButtonItem alloc] initWithTitle:@"手机" style:UIBarButtonItemStyleDone target:self action:@selector(zw_presentReceptionIOS)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:IOSbutton, PCbutton, nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发文件" style:UIBarButtonItemStyleDone target:self action:@selector(zw_presentSend)];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footView;
    
    __block typeof(self)myself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [myself zw_getFileFromDocuments];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView.mj_header beginRefreshing];
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
    
    NSArray  *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
    NSLog(@"%@", filePath);
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
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
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

-(void)zw_presentReceptionPC
{
    ZWReceptionViewController *receptionFileController= [[ZWReceptionViewController alloc] init];
    receptionFileController.receptionType = receptionFromPC;
    UINavigationController *naV = [[UINavigationController alloc] initWithRootViewController:receptionFileController];
    naV.title = @"接收文件";
    [self.navigationController presentViewController:naV animated:YES completion:^{
        
    }];
}

-(void)zw_presentReceptionIOS
{
    ZWReceptionViewController *receptionFileController= [[ZWReceptionViewController alloc] init];
    receptionFileController.receptionType = receptionFromIOS;
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
