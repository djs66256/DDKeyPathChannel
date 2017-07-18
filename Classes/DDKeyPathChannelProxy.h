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
#import "DDKeyPathChannelProtocol.h"

@interface DDKeyPathChannelBaseProxy : NSProxy <DDKeyPathChannelProtocol>

@property (readonly, nonatomic) NSInteger channelType;
@property (readonly, nonatomic) NSString *channelId;

@property (weak, readonly, nonatomic) __kindof NSObject *target;

- (instancetype)initWithChannelType:(NSInteger)channelType channelId:(NSString *)channelId target:(NSObject *)target;

- (BOOL)isEqual:(id)object;

@end

@interface DDKeyPathChannelProxy : DDKeyPathChannelBaseProxy

@property (strong, nonatomic) NSArray<NSString *> *whiteList;
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *keyPathMapper; // messageKeyPath : realKeyPath

@property (strong, nonatomic) void(^valueWillChangeBlock)(__kindof NSObject *target, NSString *keyPath, __kindof id newValue);
@property (strong, nonatomic) void(^valueDidChangeBlock)(__kindof NSObject *target, NSString *keyPath, __kindof id newValue);

//- (BOOL)canPerformKeyPath:(NSString *)keyPath newKeyPath:(out NSString ** )aKeyPath;
//- (void)setValue:(id)value forKey:(NSString *)key;

@end

@interface DDKeyPathBlockChannelProxy : DDKeyPathChannelBaseProxy

@property (strong, nonatomic) NSString *keyPath;

@property (strong, nonatomic) void(^valueChangedBlock)(__kindof NSObject *target, NSString *keyPath, __kindof id newValue);

//- (BOOL)canPerformKeyPath:(NSString *)keyPath newKeyPath:(out NSString ** )aKeyPath;
//- (void)setValue:(id)value forKey:(NSString *)key;

@end


