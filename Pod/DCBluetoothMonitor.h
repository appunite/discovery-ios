//
//  AUCentralManager.h
//  Discovery
//
//  Created by Emil Wojtaszek on 12/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol DCBluetoothMonitorDelegate;

@interface DCBluetoothMonitor : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
//
@property (nonatomic, weak) id<DCBluetoothMonitorDelegate>delegate;

// bluetooth central manager
@property (nonatomic, strong, readonly) CBCentralManager *manager;
@property (nonatomic, strong, readonly) dispatch_queue_t managerQueue;

// list of discovered users' uuids
@property (nonatomic, strong, readonly) NSSet *users;

//
@property (nonatomic, copy) BOOL (^rssiAcceptanceBlock)(NSNumber *rssi);

/*!
 *  @method initWithServiceUUID:characteristicUUID:userUUID:
 *
 *  @param service			The Bluetooth UUID of the service.
 *  @param characteristic	The Bluetooth UUID of the characteristic.
 *
 *  @discussion Returns an initialized identity monitor.
 *
 */
- (instancetype)initWithServiceUUID:(CBUUID *)service
                 characteristicUUID:(CBUUID *)characteristic NS_DESIGNATED_INITIALIZER;

/*!
 *  @method startScanning
 *
 *  @discussion Start scaning for registered services. This method is dispatched on central manager queue.
 *
 */
- (void)startScanning;

/*!
 *  @method stopScanning
 *
 *  @discussion Stop scaning for all services. This method is dispatched on central manager queue.
 *
 */
- (void)stopScanning;
@end

@protocol DCBluetoothMonitorDelegate<NSObject>
@optional
- (void)identityMonitor:(DCBluetoothMonitor *)monitor didRegiserUser:(NSUUID *)user;
- (void)identityMonitor:(DCBluetoothMonitor *)monitor didUnregiserUser:(NSUUID *)user;
@end
