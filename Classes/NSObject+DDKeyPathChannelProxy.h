// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Foundation/Foundation.h>
#import "DDKeyPathChannelProxy.h"

/**
 把代理绑定到消息发送者身上，生命周期跟随发送者，一旦发送者被释放，代理将失效！
 */
@interface NSObject (DDKeyPathChannelProxy)

// 让target接收任意类型的消息
- (DDKeyPathChannelProxy *)addChannelProxyWithChannelType:(NSInteger)channelType
                                                channelId:(NSString *)channelId
                                                   config:(void (NS_NOESCAPE ^)(DDKeyPathChannelProxy *proxy))proxyBlock;

// 监听某一消息，执行block内容，注意循环引用
- (DDKeyPathBlockChannelProxy *)addChannelProxyWithChannelType:(NSInteger)channelType
                                                     channelId:(NSString *)channelId
                                                       keyPath:(NSString *)keyPath
                                             vauleChangedBlock:(void(^)(__kindof NSObject *target, NSString *keyPath, __kindof id newValue))valueChangedBlock;

// 移除方法需要和add方法的发送者统一
- (void)removeChannelProxy:(DDKeyPathChannelBaseProxy *)proxy;
- (void)removeChannelProxyByChannelType:(NSInteger)type channelId:(NSString *)channelId;
- (void)removeChannelProxyByChannelType:(NSInteger)type;
- (void)removeAllChannelProxy;

@end
