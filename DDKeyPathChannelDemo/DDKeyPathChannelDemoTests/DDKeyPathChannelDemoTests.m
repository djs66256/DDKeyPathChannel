//
//  DDKeyPathChannelDemoTests.m
//  DDKeyPathChannelDemoTests
//
//  Created by daniel on 2017/7/9.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DDKeyPathChannel/DDKeyPathChannel.h>

typedef NS_ENUM(NSInteger, ChannelType) {
    ChannelTypeUser = 1
};

@interface UserModel1 : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger age;

@end

@implementation UserModel1

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: id(%@), nickName(%@), age(%zd)>",
            NSStringFromClass(self.class), self.id, self.name, self.age];
}

@end

@interface UserModel2 : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *nickName;
@property (assign, nonatomic) NSInteger age;

@end

@implementation UserModel2

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: id(%@), nickName(%@), age(%zd)>",
            NSStringFromClass(self.class), self.id, self.nickName, self.age];
}

@end

@interface DDKeyPathChannelDemoTests : XCTestCase

@property (strong, nonatomic) UserModel1 *user1;
@property (strong, nonatomic) UserModel2 *user2;

@end

@implementation DDKeyPathChannelDemoTests

- (void)setUp {
    [super setUp];
   
    self.user1 = [UserModel1 new];
    self.user1.id = @"1";
    self.user1.name = @"Nike";
    self.user1.age = 21;
    
    self.user2 = [UserModel2 new];
    self.user2.id = @"1";
    self.user2.nickName = @"Daniel";
    self.user2.age = 24;
    
    NSLog(@"user1: %@\n user2: %@", self.user1, self.user2);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTAssert([self.user1.name isEqualToString:@"Nike"], @"initial");
    XCTAssert(self.user1.age == 21, @"initial");
    
    XCTAssert([self.user2.nickName isEqualToString:@"Daniel"], @"initial");
    XCTAssert(self.user2.age == 24, @"initial");
    
    [self.user1 bindChannelType:ChannelTypeUser
                      channelId:self.user1.id];
    [self.user2 addChannelProxyWithChannelType:ChannelTypeUser
                                     channelId:self.user2.id
                                        config:^(DDKeyPathChannelProxy *proxy) {
                                            proxy.keyPathMapper = @{@"name": @"nickName"};
    }];
    
    NSLog(@"user1: %@\n user2: %@", self.user1, self.user2);
    
    [[DDKeyPathChannelManager sharedChannel] emitChannelType:ChannelTypeUser
                                                   channelId:@"1"
                                                       value:@"Tom"
                                                  forKeyPath:@"name"];
    [[DDKeyPathChannelManager sharedChannel] emitChannelType:ChannelTypeUser
                                                   channelId:@"1"
                                                       value:@(30)
                                                  forKeyPath:@"age"];
    
    NSLog(@"user1: %@\n user2: %@", self.user1, self.user2);
    
    XCTAssert([self.user1.name isEqualToString:@"Tom"], @"sync");
    XCTAssert(self.user1.age == 30, @"sync");
    XCTAssert([self.user2.nickName isEqualToString:@"Tom"], @"sync");
    XCTAssert(self.user2.age == 30, @"sync");
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testMultiThread {
    NSMutableArray *exposeBag = [NSMutableArray new];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    
    dispatch_group_t group = dispatch_group_create();
    
    XCTestExpectation *expect = [self expectationWithDescription:@"channel"];
    
    const NSInteger count = 10000;
    for (int i = 0; i < count; i++) {
        dispatch_group_enter(group);
        [queue addOperationWithBlock:^{
            dispatch_group_leave(group);
            UserModel1 *obj = ({
                UserModel1 *obj = [UserModel1 new];
                obj.id = [@(i) stringValue];
                obj.name = @"Nike";
                obj.age = 21;
                obj;
            });
            [obj addChannelProxyWithChannelType:ChannelTypeUser channelId:obj.id config:^(DDKeyPathChannelProxy *proxy) {
                
            }];
            [exposeBag addObject:obj];
            
            dispatch_group_enter(group);
            [queue addOperationWithBlock:^{
                dispatch_group_leave(group);
                [[DDKeyPathChannelManager sharedChannel] emitChannelType:ChannelTypeUser channelId:[@(i) stringValue] value:@(10) forKeyPath:@"age"];
            }];
            
            dispatch_group_enter(group);
            [queue addOperationWithBlock:^{
                dispatch_group_leave(group);
                [obj removeChannelProxyByChannelType:ChannelTypeUser];
            }];
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [expect fulfill];
    });
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        [queue cancelAllOperations];
        XCTAssert(error == nil);
    }];
}

@end
