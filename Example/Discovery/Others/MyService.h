//
//  MyService.h
//  Discovery
//
//  Created by Emil Wojtaszek on 04/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import "DCSocketService.h"

//Bluetooth
#import "DCBluetoothEmitter.h"
#import "DCBluetoothMonitor.h"

@interface MyService : DCSocketService

+ (id)sharedInstance;
@end

extern NSString * const MyServiceExampleServiceUUIDKey;
extern NSString * const MyServiceExampleCharacteristicUUIDKey;
extern NSString * const MyServiceExampleUserUUIDKey;
