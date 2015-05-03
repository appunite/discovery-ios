//
//  MyService.m
//  Discovery
//
//  Created by Emil Wojtaszek on 04/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import "MyService.h"

@implementation MyService

+ (id)sharedInstance {
    static DCSocketService *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        // create UUID's
        CBUUID *serviceUUID = [CBUUID UUIDWithString:MyServiceExampleServiceUUIDKey];
        CBUUID *characteristicUUID = [CBUUID UUIDWithString:MyServiceExampleCharacteristicUUIDKey];
        
        // create bluetooth monitor
        DCBluetoothMonitor *monitor = [[DCBluetoothMonitor alloc] initWithServiceUUID:serviceUUID
                                                                   characteristicUUID:characteristicUUID];
        
        // create socket service
        sharedInstance = [[DCSocketService alloc] initWithIdentityMonitor:monitor];

        // open socket connection
        [sharedInstance openSocketWithURL:[NSURL URLWithString:@"ws://discovery.io/1/2"]];
    });
    return sharedInstance;
}

@end

NSString * const MyServiceExampleServiceUUIDKey = @"689D5F89-8003-4F1F-9C35-21D615C87E6A";
NSString * const MyServiceExampleCharacteristicUUIDKey = @"8E6D7A6B-BF18-4A77-AEEF-E04B9D1265C2";
NSString * const MyServiceExampleUserUUIDKey = @"309B0F00-AD18-4E4B-AC82-178CE4565BB5";
