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

#import "DDKeyPathChannelManager.h"

@interface DDKeyPathChannelObject : NSObject
@property (assign, nonatomic) NSInteger channelType;
@property (strong, nonatomic) NSHashTable<id<DDKeyPathChannelProtocol>> *hashTable;
@property (strong, nonatomic) NSLock *lock;

- (void)addObject:(id<DDKeyPathChannelProtocol>)object;
- (void)removeObject:(id<DDKeyPathChannelProtocol>)object;
- (void)emitChannelType:(NSInteger)channelType
              channelId:(NSString *)channelId
                  value:(id)value
             forKeyPath:(NSString *)keyPath;
@end

@implementation DDKeyPathChannelObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        _hashTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addObject:(id<DDKeyPathChannelProtocol>)object {
    [self.lock lock];
    [_hashTable addObject:object];
    [self.lock unlock];
}

- (void)removeObject:(id<DDKeyPathChannelProtocol>)object {
    [self.lock lock];
    [_hashTable removeObject:object];
    [self.lock unlock];
}

- (BOOL)object:(id<DDKeyPathChannelProtocol>)object canPerformKeyPath:(NSString *)keyPath newKeyPath:(out NSString **)aKeyPath {
    NSAssert(keyPath.length > 0, @"[DDKeyPathChannel] KeyPath Must Be NOT Nil!");
    if (keyPath.length > 0) {
        if ([object channelType] <= 0) {
            return NO;
        }
        if ([object respondsToSelector:@selector(canPerformKeyPath:)] && ![object canPerformKeyPath:keyPath]) {
            return NO;
        }
        NSString *selectorStr = [NSString stringWithFormat:@"set%@%@:", [keyPath substringToIndex:1].uppercaseString, [keyPath substringFromIndex:1]];
        if ([object respondsToSelector:NSSelectorFromString(selectorStr)]) {
            return YES;
        }
        else if ([object respondsToSelector:@selector(translateKeyPath:)]) {
            NSString *transKeyPath = [object translateKeyPath:keyPath];
            if (transKeyPath) {
                if (transKeyPath.length > 0) {
                    selectorStr = [NSString stringWithFormat:@"set%@%@:", [keyPath substringToIndex:1].uppercaseString, [transKeyPath substringFromIndex:1]];
                    if ([object respondsToSelector:NSSelectorFromString(selectorStr)]) {
                        if (aKeyPath) *aKeyPath = transKeyPath;
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}


- (void)emitChannelType:(NSInteger)channelType channelId:(NSString *)channelId value:(id)value forKeyPath:(NSString *)keyPath {
    if (channelType == self.channelType) {
        [self.lock lock];
        for (id<DDKeyPathChannelProtocol> obj in _hashTable) {
            NSString *aKeyPath = nil;
            if ([obj.channelId isEqualToString:channelId] && [self object:obj canPerformKeyPath:keyPath newKeyPath:&aKeyPath]) {
                dispatch_block_t updateValue =^() {
                    if (aKeyPath) {
                        [obj setValue:value forKey:aKeyPath];
                    }
                    else {
                        [obj setValue:value forKey:keyPath];
                    }
                };
                if ([NSThread currentThread].isMainThread) {
                    updateValue();
                }
                else {
                    // 防止KVO刷新页面的时候的子线程操作UI
                    dispatch_sync(dispatch_get_main_queue(), updateValue);
                }
            }
        }
        [self.lock unlock];
    }
}

@end

@implementation DDKeyPathChannelManager {
    NSMutableDictionary *_channelDict;
    NSLock *_lock;
}

+ (instancetype)sharedChannel {
    static DDKeyPathChannelManager *g_channel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_channel = [DDKeyPathChannelManager new];
    });
    return g_channel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _channelDict = [NSMutableDictionary new];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addObject:(id<DDKeyPathChannelProtocol>)obj {
    DDKeyPathChannelObject *channel = [self _channelObjectForChannelType:obj.channelType];
    [channel addObject:obj];
}

- (void)removeObject:(id<DDKeyPathChannelProtocol>)obj {
    DDKeyPathChannelObject *channel = [self _channelObjectForChannelType:obj.channelType];
    [channel removeObject:obj];
}

- (void)emitChannelType:(NSInteger)channelType channelId:(NSString *)channelId value:(id)value forKeyPath:(NSString *)keyPath {
    if (keyPath.length > 0) {
        DDKeyPathChannelObject *channel = [self _channelObjectForChannelType:channelType];
        [channel emitChannelType:channelType channelId:channelId value:value forKeyPath:keyPath];
    }
}

- (DDKeyPathChannelObject *)_channelObjectForChannelType:(NSInteger)channelType {
    if (channelType <= 0) {
        return nil;
    }
    
    [_lock lock];
    DDKeyPathChannelObject *obj = _channelDict[@(channelType)];
    if (obj == nil) {
        obj = [DDKeyPathChannelObject new];
        obj.channelType = channelType;
        _channelDict[@(channelType)] = obj;
    }
    [_lock unlock];
    return obj;
}

@end
