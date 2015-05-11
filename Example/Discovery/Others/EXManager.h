//
//  EXManager.h
//  Discovery
//
//  Created by Emil Wojtaszek on 11/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import <Foundation/Foundation.h>

//Discovery
#import "DCSocketService.h"
#import "DCBluetoothEmitter.h"
#import "DCBluetoothMonitor.h"

@interface EXManager : NSObject
// sockets
@property (strong, nonatomic) DCSocketService *socketService;

// bluetooth
@property (strong, nonatomic) DCBluetoothEmitter *bluetoothEmitter;
@property (strong, nonatomic) DCBluetoothMonitor *bluetoothMonitor;

- (void)assignUsers;
@end
