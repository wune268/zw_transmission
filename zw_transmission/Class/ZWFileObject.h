//
//  ZWFileObject.h
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZWFileObject : NSObject

@property(copy, nonatomic)NSString *sendFileName;
@property(assign, nonatomic)CGFloat sendFileSize;
@property(copy, nonatomic)NSString *sendFileDetailsName;

@end
