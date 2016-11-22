//
//  ViewController.m
//  CSReachabilityDemo
//
//  Created by Suns孙泉 on 2016/11/21.
//  Copyright © 2016年 cyou-inc.com. All rights reserved.
//

#import "ViewController.h"

#import "CSReachability.h"

@interface ViewController ()

@property (nonatomic, strong) CSReachability *instance;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *remoteHostName = @"www.apple.com";
    
    self.instance = [CSReachability reachabilityWithHostName:remoteHostName];
    
    [self.instance networkStatusHasChanged:^(CSNetworkStatus status)
    {
        switch (status)
        {
            case CSNotReachable:
                NSLog(@"无法访问网络");
                break;
            case CSReachableViaWiFi:
                NSLog(@"通过无线网络访问");
                break;
            case CSReachableVia2G:
                NSLog(@"通过2G移动网络访问");
                break;
            case CSReachableVia3G:
                NSLog(@"通过3G移动网络访问");
                break;
            case CSReachableVia4G:
                NSLog(@"通过4G移动网络访问");
                break;
            case CSReachableViaWWAN:
                NSLog(@"通过其他移动网络访问");
                break;
            default:
                break;
        }

    }];
}

@end
