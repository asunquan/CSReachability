# CSReachability

##### 一个基于Apple-Inc的Reachability改造的, 辅助捕获网络状态的小玩意. 支持IPv6-only网络, 可以实时识别出无限广域网络包括2/3/4G, 无线局域网络wifi, 以及无网络状态.

##### [Reachability](https://developer.apple.com/library/content/samplecode/Reachability/Introduction/Intro.html)

### 通过访问不同的内容来检测网络连接状态

初始化方法, 返回一个实例化对象一共后续使用

* 访问主机名

  ```objective-c
  /**
   访问主机名检测网络连接状态

   @param hostName 主机名
   @return 实例化对象
   */
  + (instancetype)reachabilityWithHostName:(NSString *)hostName;
  ```

  示例

  ```objective-c
  [CSReachability reachabilityWithHostName:@"www.apple.com"];
  ```

* 访问IP地址

  ```objective-c
  /**
   访问IP地址检测网络连接状态

   @param hostAddress IP地址
   @return 实例化对象
   */
  + (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;
  ```

* 访问默认线路

  ```objective-c
  /**
   访问默认路线检测网络连接状态

   @return 实例化对象
   */
  + (instancetype)reachabilityForInternetConnection;
  ```

### 获取当前网络状态

通过调用对象方法, 查询网络连接状态, 并返回网络状态枚举

```objective-c
/**
 查看当前网络状态

 @return 当前网络状态
 */
- (CSNetworkStatus)currentReachabilityStatus;
```

### CSNetworkStatus 网络状态枚举

| 枚举名                | 解释         | 枚举值  |
| ------------------ | ---------- | ---- |
| CSNotReachable     | 无法访问网络     | 0    |
| CSReachableViaWiFi | 通过无线网络访问   | 1    |
| CSReachableVia2G   | 通过2G移动网络访问 | 2    |
| CSReachableVia3G   | 通过3G移动网络访问 | 3    |
| CSReachableVia4G   | 通过4G移动网络访问 | 4    |
| CSReachableViaWWAN | 通过其他移动网络访问 | 5    |

### 实时监听网络状态变化

当网络状态发生变化时会发送通知, 可以监听该通知实时获取网络状态变化或进行自定义操作.

* 通知名

  ```objective-c
  extern NSString *kCSNetworkChangedNotification;
  ```

* 开启实时监听网络状态

  ```objective-c
  /**
   开始监听网络状态变化通知

   @return 是否开启成功
   */
  - (BOOL)startNotifier;
  ```

* 停止实时监听网络状态

  ```objective-c
  /**
   停止监听网络状态变化通知
   */
  - (void)stopNotifier;
  ```

* CSReachability中封装了一个实时监测网络变化的方法

  ```objective-c
  /**
   监测实时网络状态变化
   
   @param changed 实时网络状态
   */
  - (void)networkStatusHasChanged:(void(^)(CSNetworkStatus status))changed;
  ```

​       注: 实时监控网络状态但只有在网络状态发生改变的时候才会收到changed回调.

[MyBlog](http://www.sunquan.club)