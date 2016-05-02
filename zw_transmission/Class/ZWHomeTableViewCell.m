//
//  ZWHomeTableViewCell.m
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "ZWHomeTableViewCell.h"

@implementation ZWHomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)zw_cellForTableView:(UITableView *)tableView
{
    static NSString *ID = @"file";
    ZWHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[ZWHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

-(void)setFileObject:(ZWFileObject *)fileObject
{
    _fileObject = fileObject;
    self.detailTextLabel.text = [NSString stringWithFormat:@"文件大小：%.1fKB",fileObject.sendFileSize];
    self.textLabel.text = fileObject.sendFileName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
