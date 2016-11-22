//
//  CSReachability.m
//  CSReachabilityDemo
//
//  Created by Suns孙泉 on 2016/11/21.
//  Copyright © 2016年 cyou-inc.com. All rights reserved.
//

#import "CSReachability.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>

#pragma mark IPv6 Support


NSString *kCSNetworkChangedNotification = @"kCSNetworkChangedNotification";


#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void CSReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [CSReachability class]], @"info was wrong class in ReachabilityCallback");
    
    CSReachability* noteObject = (__bridge CSReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kCSNetworkChangedNotification
                                                        object: noteObject];
}


#pragma mark - Reachability implementation

@implementation CSReachability
{
    SCNetworkReachabilityRef _reachabilityRef;
    void(^networkChanged)(CSNetworkStatus status);
    CSNetworkStatus previousStatus;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
    CSReachability *returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL)
    {
        returnValue= [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    CSReachability *returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}


- (void)networkStatusHasChanged:(void (^)(CSNetworkStatus))changed
{
    networkChanged = changed;
    
    previousStatus = self.currentReachabilityStatus;
    
    [self addNetworkChangedObserver];
    
    [self startNotifier];
}

- (void)addNetworkChangedObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kCSNetworkChangedNotification
                                               object:nil];
}

- (void)networkChanged:(NSNotification *)notification
{
    CSNetworkStatus currentStatus = self.currentReachabilityStatus;
    
    if (networkChanged && previousStatus != currentStatus)
    {
        previousStatus = currentStatus;
        
        networkChanged(currentStatus);
    }
}

- (void)removeNetworkChangedObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCSNetworkChangedNotification
                                                  object:nil];
}

#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, CSReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)stopNotifier
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc
{
    [self stopNotifier];
    
    [self removeNetworkChangedObserver];
    
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}


#pragma mark - Network Flag Handling

- (CSNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return CSNotReachable;
    }
    
    CSNetworkStatus returnValue = CSNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = CSReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = CSReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = CSReachableViaWWAN;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
        {
            CTTelephonyNetworkInfo *phonyNetwork = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStr = phonyNetwork.currentRadioAccessTechnology;
            
            if (currentStr)
            {
                // 2G网络标准: GPRS/Edge
                // 3G网路标准: WCDMA/HSDPA/HSUPA/CDMA1x/CDMAEVDORev0/CDMAEVDORevA/CDMAEVDORevB/HRPD
                // 4G网络标准: LTE
                if ([currentStr isEqualToString:CTRadioAccessTechnologyLTE])
                {
                    return CSReachableVia4G;
                }
                else if ([currentStr isEqualToString:CTRadioAccessTechnologyGPRS]|| [currentStr isEqualToString:CTRadioAccessTechnologyEdge])
                {
                    return CSReachableVia2G;
                }
                else
                {
                    return CSReachableVia3G;
                }
            }
        }
        
        if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection)
        {
            if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired)
            {
                return CSReachableVia2G;
            }
            
            return CSReachableVia3G;
        }
    }
    
    return returnValue;
}


- (BOOL)connectionRequired
{
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}


- (CSNetworkStatus)currentReachabilityStatus
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    CSNetworkStatus returnValue = CSNotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        returnValue = [self networkStatusForFlags:flags];
    }
    
    return returnValue;
}


@end
