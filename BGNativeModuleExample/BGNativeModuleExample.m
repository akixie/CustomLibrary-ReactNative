//
//  BGNativeModuleExample.m
//  BGNativeModuleExample
//
//  Created by akixie on 16/8/23.
//  Copyright © 2016年 Aki.Xie. All rights reserved.
//

#import "BGNativeModuleExample.h"
#import "RCTLog.h"
#import "RCTEventDispatcher.h"

static NSString * const kTestNotificationName = @"kTestNotificationName";
static NSString * const TestEventName = @"TestEventName";

@implementation BGNativeModuleExample

//注意： 编写OC代码时，需要添加@synthesize bridge = _bridge;，否则接收事件的时候就会报Exception -[BGNativeModuleExample brige]; unrecognized selector sent to instance的错误。
@synthesize bridge = _bridge;

- (instancetype)init {
    if(self = [super init]) {
        //在这里，我们为了能够接收到事件，我们开一个定时器，每一秒发送一次事件。
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendEventToJS) userInfo:nil repeats:YES];
    }
    return self;
}

//此处不能使用OC的字符串，直接输入就行了
RCT_EXPORT_MODULE(BGNativeModuleExample);

//为原生模块添加方法,测试方法导出
RCT_EXPORT_METHOD(testPrint:(NSString *)name info:(NSDictionary *)info) {
    RCTLogInfo(@"%@: %@", name, info);
}

//测试回调函数,将当前模块的类名回调给JS
RCT_EXPORT_METHOD(getNativeClass:(RCTResponseSenderBlock)callback) {
    callback(@[NSStringFromClass([self class])]);
}

//Promiss
//原生模块还可以使用promise来简化代码，搭配ES2016(ES7)标准的async/await语法则效果更佳。如果桥接原生方法的最后两个参数是RCTPromiseResolveBlock和RCTPromiseRejectBlock，则对应的JS方法就会返回一个Promise对象。
//我们通过Promises来实现原生模块是否会响应方法，响应则返回YES，不响应则返回一个错误信息，
//如果使用Promiss我们不需要参数，则在OC去掉name那一行就行了；如果需要多个参数，在name下面多加一行就行了，注意它们之间不需要添加逗号。
RCT_REMAP_METHOD(testRespondMethod,
                 name:(NSString *)name
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    if([self respondsToSelector:NSSelectorFromString(name)]) {
        resolve(@YES);
    }
    else {
        reject(@"-1001", @"not respond this method", nil);
    }
}

//多线程
//我们这里操作的模块没有涉及到UI，所以专门建立一个串行的队列给它使用，注意: 在模块之间共享分发队列
//methodQueue方法会在模块被初始化的时候被执行一次，然后会被React Native的桥接机制保存下来，所以你不需要自己保存队列的引用，除非你希望在模块的其它地方使用它。但是，如果你希望在若干个模块中共享同一个队列，则需要自己保存并返回相同的队列实例；仅仅是返回相同名字的队列是不行的。
//更多线程的操作细节可以参考：http://reactnative.cn/docs/0.24/native-modules-ios.html#content
- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.liuchungui.demo", DISPATCH_QUEUE_SERIAL);
}


//导出常量
//原生模块可以导出一些常量，这些常量在JavaScript端随时都可以访问。用这种方法来传递一些静态数据，可以避免通过bridge进行一次来回交互。
//OC中，我们实现constantsToExport方法，如下：
- (NSDictionary *)constantsToExport {
    return @{ @"BGModuleName" : @"BGNativeModuleExample",
              TestEventName: TestEventName
              };
}

//给JS发送事件
//即使没有被JS调用，本地模块也可以给JS发送事件通知。最直接的方式是使用eventDispatcher。
//在这里，我们为了能够接收到事件，我们开一个定时器，每一秒发送一次事件。
- (void)sendEventToJS {
    [self.bridge.eventDispatcher sendAppEventWithName:TestEventName body:@{@"name": @"Jack"}];
}


@end
