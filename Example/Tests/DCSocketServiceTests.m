//
//  DCSocketServiceTests.m
//  Discovery
//
//  Created by Emil Wojtaszek on 03/05/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// Discovery
#import "DCSocketService.h"
#import "DCBluetoothMonitor.h"

//Others
#import "SRWebSocket.h"
#import "Expecta.h"
#import "OCMock.h"

@interface DCSocketServiceTests : XCTestCase
@property (nonatomic, strong) DCBluetoothMonitor *bluetoothMonitor;
@property (nonatomic, strong) DCSocketService *socketService;
@end

@implementation DCSocketServiceTests {
    NSUUID *_serviceUUID;
}

- (void)setUp {
    _serviceUUID = [NSUUID UUID];
    
    // create bluetooth monitor
    _bluetoothMonitor = [[DCBluetoothMonitor alloc] initWithServiceUUID:[CBUUID UUIDWithString:@"689D5F89-8003-4F1F-9C35-21D615C87E6A"]
                                                   characteristicUUID:[CBUUID UUIDWithString:@"8E6D7A6B-BF18-4A77-AEEF-E04B9D1265C2"]];

    // create socket service
    _socketService = [[DCSocketService alloc] initWithService:_serviceUUID];
}

- (void)testSocketConnectionOpening {
    // open socket with given URL
    NSURL *url = [NSURL URLWithString:@"ws://discovery.io/1/2"];
    [_socketService openConnectionWithURL:url];

    // verify
    XCTAssertNotNil(_socketService.webSocket);
    XCTAssertEqual(_socketService.webSocket.url, url);
    XCTAssertEqual(_socketService.webSocket.delegate, _socketService);
}

- (void)testPresenceMessageStructure {
    // prepare message
    NSDictionary *message = [_socketService presenceMessageForUserUUID:[[NSUUID alloc] initWithUUIDString:@"E3207135-0116-4CC2-843C-4E930F3F08C3"]];
    
    // decompose message
    NSDictionary *header = message[@"header"];
    NSDictionary *body = message[@"body"];

    // test header
    XCTAssertNotNil(header[@"id"]);
    XCTAssertEqual(header[@"type"], @"presence");
    XCTAssertTrue([header[@"service"] isEqualToString:[_serviceUUID UUIDString]]);
    
    // test body value
    XCTAssertTrue([body[@"id"] isEqualToString:@"E3207135-0116-4CC2-843C-4E930F3F08C3"]);
}

- (void)testAbsenceMessageStructure {
    // prepare message
    NSDictionary *message = [_socketService absenceMessageForUserUUID:[[NSUUID alloc] initWithUUIDString:@"E3207135-0116-4CC2-843C-4E930F3F08C3"]];
    
    // decompose message
    NSDictionary *header = message[@"header"];
    NSDictionary *body = message[@"body"];
    
    // test header
    XCTAssertNotNil(header[@"id"]);
    XCTAssertEqual(header[@"type"], @"absence");
    XCTAssertTrue([header[@"service"] isEqualToString:[_serviceUUID UUIDString]]);
    
    // test body value
    XCTAssertTrue([body[@"id"] isEqualToString:@"E3207135-0116-4CC2-843C-4E930F3F08C3"]);
}

- (void)testMetadataMessageStructure {
    // prepare message
    NSDictionary *message = [_socketService metadataMessageWithPayload:@{@"name": @"appunite"}];
    
    // decompose message
    NSDictionary *header = message[@"header"];
    NSDictionary *body = message[@"body"];
    
    // test header
    XCTAssertNotNil(header[@"id"]);
    XCTAssertEqual(header[@"type"], @"metadata");
    XCTAssertTrue([header[@"service"] isEqualToString:[_serviceUUID UUIDString]]);
    
    // test body value
    XCTAssertTrue([body[@"name"] isEqualToString:@"appunite"]);
}

@end
