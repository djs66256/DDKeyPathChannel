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

#import "DDKeyPathChannelProxy.h"

@implementation DDKeyPathChannelBaseProxy

- (instancetype)initWithChannelType:(NSInteger)type channelId:(NSString *)channelId target:(NSObject *)target
{
    NSParameterAssert(type >= 0);
    NSParameterAssert(target != nil);
    
    _channelType = type;
    _target = target;
    _channelId = channelId;
    return self;
}

- (BOOL)canPerformKeyPath:(NSString *)keyPath {
    return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(canPerformKeyPath:)) {
        return YES;
    }
    return [self.target respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (BOOL)isEqualToChannelProxy:(DDKeyPathChannelBaseProxy *)proxy {
    return self.channelType == proxy.channelType && [self.channelId isEqualToString:proxy.channelId];
}

- (BOOL)isEqual:(id)other {
    __strong id object = other;
    if (object == self) {
        return YES;
    }
    else if (![object isKindOfClass:[DDKeyPathChannelBaseProxy class]]) {
        return NO;
    }
    else {
        return [self isEqualToChannelProxy:object];
    }
}

@end

@implementation DDKeyPathChannelProxy

- (BOOL)canPerformKeyPath:(NSString *)keyPath {
    if (self.whiteList) {
        if ([self.whiteList containsObject:keyPath]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return YES;
    }
}

- (NSString *)translateKeyPath:(NSString *)keyPath {
    NSString *trans = self.keyPathMapper[keyPath];
    if (trans && trans.length) {
        return trans;
    }
    else {
        return keyPath;
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(translateKeyPath:)) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (self.valueWillChangeBlock) self.valueWillChangeBlock(self.target, key, value);
    [self.target setValue:value forKey:key];
    if (self.valueDidChangeBlock) self.valueDidChangeBlock(self.target, key, value);
}

@end

@implementation DDKeyPathBlockChannelProxy

- (BOOL)canPerformKeyPath:(NSString *)keyPath {
    return [keyPath isEqualToString:self.keyPath];
}

//- (BOOL)canPerformKeyPath:(NSString *)keyPath newKeyPath:(out NSString *__autoreleasing *)aKeyPath {
//    if ([self channelType] <= 0) {
//        return NO;
//    }
//    if (![keyPath isEqualToString:self.keyPath]) {
//        return NO;
//    }
//    if (aKeyPath) {
//        *aKeyPath = keyPath;
//    }
//    return YES;
//}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:self.keyPath]) {
        if (self.valueChangedBlock) {
            self.valueChangedBlock(self.target, key, value);
        }
    }
}

@end
