//
//  DCJSONMessageDeserializerTests.m
//  Discovery
//
//  Created by Emil Wojtaszek on 01/05/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

//Serializer
#import "DCMessageDeserializer.h"

@interface DCJSONMessageDeserializerTests : XCTestCase
@property (nonatomic, strong) DCJSONMessageDeserializer *deserializer;
@end

@implementation DCJSONMessageDeserializerTests

- (void)setUp {
    [super setUp];
    self.deserializer = [DCJSONMessageDeserializer new];
}

- (void)testExample {
    // create sample payload
    NSDictionary *message = @{@"header": @{@"id": @"C29B87FB-DBC7-4CDE-ABDC-03AE12A1FEFD", @"type": @"presence"}};
    
    // test if not nil
    NSData *payload = [self.deserializer deserializeMessage:message error:nil];
    XCTAssertNotNil(payload);

    // test if equal
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
    XCTAssertTrue([message isEqualToDictionary:dict]);
}

@end
