//
//  ZWHomeTableViewCell.h
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWFileObject.h"

@interface ZWHomeTableViewCell : UITableViewCell

@property(nonatomic, weak)ZWFileObject *fileObject;

+(instancetype)zw_cellForTableView:(UITableView *)tableView;

@end
