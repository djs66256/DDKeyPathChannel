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

#ifndef DDKeyPathChannelProtocol_h
#define DDKeyPathChannelProtocol_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 下面两个为channel属性和方法的标记，务必在使用到的时候加上
#define CHANNEL_PROPERTY
#define CHANNEL_FUNCTION

@protocol DDKeyPathChannelProtocol

@required
@property (readonly, nonatomic) NSString *channelId;
@property (readonly, nonatomic) NSInteger channelType;

- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)setValue:(nullable id)value forKey:(NSString *)key;

@optional
- (BOOL)canPerformKeyPath:(NSString *)keyPath;
- (NSString * _Nullable)translateKeyPath:(NSString *)keyPath;

//// 不需要重写这个方法，NSObject上已经实现，放在这里是为了约束只有服从本协议才可以调用
//- (void)emitKeyPath:(NSString *)keyPath forValue:(id)value;

@end

NS_ASSUME_NONNULL_END

#endif /* DDKeyPathChannelProtocol_h */
