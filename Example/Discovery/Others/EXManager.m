//
//  EXManager.m
//  Discovery
//
//  Created by Emil Wojtaszek on 11/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import "EXManager.h"

//Others
#import "EXConstants.h"

@implementation EXManager

- (instancetype)init {
    self = [super init];
    if (self) {
        // create UUID's
        CBUUID *serviceUUID = [CBUUID UUIDWithString:EXServiceUUIDKey];
        CBUUID *characteristicUUID = [CBUUID UUIDWithString:EXCharacteristicUUIDKey];
        NSUUID *userUUID = [[NSUUID alloc] initWithUUIDString:EXUserUUIDKey];
        
        // create socket service
        self.socketService = [[DCSocketService alloc] init];
        
        // create bluetooth monitor
        self.bluetoothMonitor = [[DCBluetoothMonitor alloc] initWithServiceUUID:serviceUUID
                                                             characteristicUUID:characteristicUUID];

        // create bluetooth emmiter
        self.bluetoothEmitter = [[DCBluetoothEmitter alloc] initWithService:serviceUUID
                                                             characteristic:characteristicUUID
                                                                      value:userUUID];

        // assign delegate
        _bluetoothMonitor.delegate = _socketService;
    }
    return self;
}

- (void)assignUsers {
    [_socketService subscribeUsers:_bluetoothMonitor.users];
}

@end
