//
//  CSReachability.h
//  CSReachabilityDemo
//
//  Created by Suns孙泉 on 2016/11/21.
//  Copyright © 2016年 cyou-inc.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

/**
 网络状态枚举

 - CSNotReachable: 无法访问网络
 - CSReachableViaWiFi: 通过无线网络访问
 - CSReachableVia2G: 通过2G移动网络访问
 - CSReachableVia3G: 通过3G移动网络访问
 - CSReachableVia4G: 通过4G移动网络访问
 - CSReachableViaWWAN: 通过其他移动网络访问
 */
typedef NS_ENUM(NSUInteger, CSNetworkStatus)
{
    CSNotReachable = 0,
    CSReachableViaWiFi,
    CSReachableVia2G,
    CSReachableVia3G,
    CSReachableVia4G,
    CSReachableViaWWAN
};

#pragma mark IPv6 Support

extern NSString *kCSNetworkChangedNotification;

@interface CSReachability : NSObject

/**
 访问主机名检测网络连接状态

 @param hostName 主机名
 @return 实例化对象
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;


/**
 访问IP地址检测网络连接状态

 @param hostAddress IP地址
 @return 实例化对象
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/**
 访问默认路线检测网络连接状态

 @return 实例化对象
 */
+ (instancetype)reachabilityForInternetConnection;


/**
 开始监听网络状态变化通知

 @return 是否开启成功
 */
- (BOOL)startNotifier;


/**
 停止监听网络状态变化通知
 */
- (void)stopNotifier;


/**
 查看当前网络状态

 @return 当前网络状态
 */
- (CSNetworkStatus)currentReachabilityStatus;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;

@end


