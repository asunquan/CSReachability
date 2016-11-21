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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kCSNetworkChangedNotification
                                               object:nil];
    
    [self networkChanged:nil];
}

- (void)networkChanged:(NSNotification *)notification
{
    NSString *remoteHostName = @"www.apple.com";

    CSReachability *instance = [CSReachability reachabilityWithHostName:remoteHostName];
    
    switch (instance.currentReachabilityStatus)
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCSNetworkChangedNotification
                                                  object:nil];
}


@end
