//
//  ZWReceptionViewController.h
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, receptionType)
{
    receptionFromPC,
    receptionFromIOS
} ;

@interface ZWReceptionViewController : UIViewController
@property(assign, nonatomic)receptionType receptionType;
@end
