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

#import <objc/runtime.h>
#import "NSObject+DDKeyPathChannelProxy.h"
#import "DDKeyPathChannelManager.h"
#import "DDKeyPathChannelProtocol.h"

@implementation NSObject (DDKeyPathChannelProxy)

- (NSMutableDictionary<NSNumber *, NSMutableArray<DDKeyPathChannelBaseProxy *> *> *)dd_channelProxies {
    static const char key;
    NSMutableDictionary *dict = nil;
    @synchronized (self) {
        dict = objc_getAssociatedObject(self, &key);
        if (dict == nil) {
            dict = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, &key, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    return dict;
}

- (NSMutableArray<DDKeyPathChannelBaseProxy *> *)_channelProxiesWithType:(NSInteger)type {
    NSMutableDictionary *dict = [self dd_channelProxies];
    @synchronized (self) {
        NSMutableArray<DDKeyPathChannelBaseProxy *> *proxies = dict[@(type)];
        if (proxies == nil) {
            proxies = [NSMutableArray new];
            dict[@(type)] = proxies;
        }
        return proxies;
    }
}

- (void)_addChannelProxy:(DDKeyPathChannelBaseProxy *)proxy {
    NSMutableArray<DDKeyPathChannelBaseProxy *> *proxies = [self _channelProxiesWithType:proxy.channelType];
    @synchronized (self) {
        [proxies addObject:proxy];
    }
}

- (DDKeyPathChannelProxy *)addChannelProxyWithChannelType:(NSInteger)channelType channelId:(NSString *)channelId config:(void (^)(DDKeyPathChannelProxy *))proxyBlock {
    if (channelType <= 0 || channelId == nil) {
        return nil;
    }
    
    DDKeyPathChannelProxy *proxy = [[DDKeyPathChannelProxy alloc] initWithChannelType:channelType channelId:channelId target:self];
    if (proxyBlock) proxyBlock(proxy);
    [self _addChannelProxy:proxy];
    [[DDKeyPathChannelManager sharedChannel] addObject:proxy];
    return proxy;
}

- (DDKeyPathBlockChannelProxy *)addChannelProxyWithChannelType:(NSInteger)channelType channelId:(NSString *)channelId keyPath:(NSString *)keyPath vauleChangedBlock:(void (^)(__kindof NSObject *, NSString *, __kindof id))valueChangedBlock {
    if (channelType <= 0 || channelId == nil) {
        return nil;
    }
    DDKeyPathBlockChannelProxy *proxy = [[DDKeyPathBlockChannelProxy alloc] initWithChannelType:channelType channelId:channelId target:self];
    proxy.keyPath = keyPath;
    proxy.valueChangedBlock = valueChangedBlock;
    [self _addChannelProxy:proxy];
    [[DDKeyPathChannelManager sharedChannel] addObject:proxy];
    return proxy;
}

- (void)removeChannelProxy:(DDKeyPathChannelBaseProxy *)proxy {
    NSMutableArray<DDKeyPathChannelBaseProxy *> *proxies = [self _channelProxiesWithType:proxy.channelType];
    @synchronized (self) {
        [proxies removeObject:proxy];
    }
    [[DDKeyPathChannelManager sharedChannel] removeObject:proxy];
}

- (void)removeChannelProxyByChannelType:(NSInteger)type channelId:(NSString *)channelId {
    NSMutableArray<DDKeyPathChannelBaseProxy *> *proxies = [self _channelProxiesWithType:type];
    @synchronized (self) {
        NSIndexSet *indexSet = [proxies indexesOfObjectsPassingTest:^BOOL(DDKeyPathChannelBaseProxy * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.channelId isEqualToString:channelId];
        }];
        [proxies enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(DDKeyPathChannelBaseProxy * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[DDKeyPathChannelManager sharedChannel] removeObject:obj];
        }];
        [proxies removeObjectsAtIndexes:indexSet];
    }
}

- (void)removeChannelProxyByChannelType:(NSInteger)type {
    if (type <= 0) {
        return ;
    }
    NSMutableArray<DDKeyPathChannelBaseProxy *> *proxies = [self _channelProxiesWithType:type];
    for (DDKeyPathChannelBaseProxy *proxy in proxies) {
        [[DDKeyPathChannelManager sharedChannel] removeObject:proxy];
    }
    @synchronized (self) {
        [proxies removeAllObjects];
    }
}

- (void)removeAllChannelProxy {
    NSMutableDictionary<NSNumber *, NSMutableArray<DDKeyPathChannelBaseProxy *> *> *dict = [self dd_channelProxies];
    @synchronized (self) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray<DDKeyPathChannelBaseProxy *> *obj, BOOL * _Nonnull stop) {
            for (DDKeyPathChannelBaseProxy *proxy in obj) {
                [[DDKeyPathChannelManager sharedChannel] removeObject:proxy];
            }
        }];
        [dict removeAllObjects];
    }
}

@end

