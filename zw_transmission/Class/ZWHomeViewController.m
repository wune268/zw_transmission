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

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
//    if (editingStyle == UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
//        if (indexPath.row<[self.fileArray count]) {
//            ZWFileObject *fileObject = self.fileArray[indexPath.row];
//            [self zw_deleteFile:fileObject.sendFileDetailsName];
//            [self.fileArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
//        }
//    }
//}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row<[self.fileArray count]) {
            ZWFileObject *fileObject = self.fileArray[indexPath.row];
            [self zw_deleteFile:fileObject.sendFileDetailsName];
            [self.fileArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
        }
    }];
    UITableViewRowAction *renameButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        ZWFileObject *fileObject = self.fileArray[indexPath.row];
        UIAlertController *renameController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"重命名%@", fileObject.sendFileName] message:nil preferredStyle:UIAlertControllerStyleAlert];
        [renameController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"请输入名字";
        }];
        [renameController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }]];
        [renameController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textfield = [[renameController textFields] firstObject];
            
            NSString *string = fileObject.sendFileName;
            NSRange range = [string rangeOfString:@"."];//匹配得到的下标
            string = [string substringFromIndex:range.location];
            NSLog(@"截取的值为：%@",string);
            
            
            [self zw_renameFile:[NSString stringWithFormat:@"%@%@", textfield.text, string] pathname:fileObject.sendFileDetailsName];
        }]];
        [self presentViewController:renameController animated:YES completion:^{
            
        }];
    }];
    return @[deleteButton, renameButton];
}

////修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}

// 删除沙盒里的文件
-(void)zw_deleteFile:(NSString *)uniquePath {
    NSFileManager* fileManager=[NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    
//    //文件名
//    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"pin.png"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
        
    }
}


-(void)zw_renameFile:(NSString *)firename pathname:(NSString *)pathname
{
    NSError *error;
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
//    NSArray  *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
    
    //通过移动该文件对文件重命名
    NSString *filePath2= [filePath stringByAppendingPathComponent:firename];
    //判断是否移动
    if ([[NSFileManager defaultManager] moveItemAtPath:pathname toPath:filePath2 error:&error] != YES)
    {
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
    }
    else
    {
        [self zw_deleteFile:pathname];
        [self.tableView.mj_header beginRefreshing];
    }
    //显示文件目录的内容
//    NSLog(@"Documentsdirectory: %@",
//          [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryerror:&error]);
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
}

@end
