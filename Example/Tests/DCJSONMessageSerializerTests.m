//
//  DCJSONMessageSerializerTests.m
//  Discovery
//
//  Created by Emil Wojtaszek on 01/05/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

//Serializer
#import "DCMessageSerializer.h"

@interface DCJSONMessageSerializerTests : XCTestCase
@property (nonatomic, strong) DCJSONMessageSerializer *serializer;
@end

@implementation DCJSONMessageSerializerTests

- (void)setUp {
    [super setUp];
    self.serializer = [DCJSONMessageSerializer new];
}

- (void)testExample {
    // create sample payload
    NSString *message = @"{\"header\":{\"id\":\"C29B87FB-DBC7-4CDE-ABDC-03AE12A1FEFD\",\"type\":\"presence\"}}";
    NSData *payload = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    // test if not nil
    NSDictionary *serializedMessage = [self.serializer serializeMessage:payload error:nil];
    XCTAssertNotNil(serializedMessage);
    
    // test if equal
    NSData *data = [NSJSONSerialization dataWithJSONObject:serializedMessage options:0 error:nil];
    XCTAssertTrue([payload isEqualToData:data]);
}

@end
