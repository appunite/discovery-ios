//
//  AUCentralManager.m
//  Discovery
//
//  Created by Emil Wojtaszek on 12/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "DCBluetoothMonitor.h"

@implementation DCBluetoothMonitor {
    BOOL _timer;
    
    // identifiers
    CBUUID *_serviceUUID;
    CBUUID *_characteristicUUID;

    // discovered peripherals
    NSMutableSet *_peripherals;
    NSMutableDictionary *_intervals;
    NSMutableDictionary *_users;
}

- (instancetype)initWithServiceUUID:(CBUUID *)service characteristicUUID:(CBUUID *)characteristic {
    self = [super init];
    if (self) {
        _timer = NO;
        
        // create containers
        _peripherals = [NSMutableSet new];
        _intervals = [NSMutableDictionary new];
        _users = [NSMutableDictionary new];
        
        // assign all UUID values
        _characteristicUUID = characteristic;
        _serviceUUID = service;

        // start up the CBCentralManager
        _managerQueue = dispatch_queue_create("com.appunite.central.queue", DISPATCH_QUEUE_SERIAL);
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:_managerQueue];
    }
    return self;
}

- (void)startScanning {
    NSParameterAssert(_serviceUUID);

    // start scanning
    [_manager scanForPeripheralsWithServices:@[_serviceUUID] options:@{
        CBCentralManagerScanOptionAllowDuplicatesKey: @YES,
        CBCentralManagerOptionShowPowerAlertKey: @YES
    }];
    
    // turn on timer flag
    _timer = YES;

    // create timer
    [self scheduledTimerWithTimeInterval:5];
}

- (void)stopScanning {
    dispatch_async(_managerQueue, ^{
        // turn of timer
        _timer = NO;
        
        // clear collections
        [_peripherals removeAllObjects];
        [_intervals removeAllObjects];
        [_users removeAllObjects];
    });

    // stop
    [_manager stopScan];
}

#pragma mark - 
#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }

    // test required values
    NSParameterAssert(_serviceUUID);
    NSParameterAssert(_characteristicUUID);
    
    // start scanning
    [self startScanning];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)ad RSSI:(NSNumber *)rssi {
    
    // check if current received signal strength indicator of the peripheral is acceptable
    if (_rssiAcceptanceBlock && !self.rssiAcceptanceBlock(rssi)) return;
    
    // update discovery date only if already registered
    if ([_intervals objectForKey:peripheral.identifier]) {
        [_intervals setObject:[NSDate date] forKey:peripheral.identifier]; return;
    }

    // already connected?
    if (![_peripherals containsObject:peripheral]) {
        // retain peripheral
        [_peripherals addObject:peripheral];
        
        // connect to peripheral
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    
    // clean up after connection fails
    [self cleanup:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [_manager stopScan];
    NSLog(@"Scanning stopped");
    
    // make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // search only for services that match our UUID
    [peripheral discoverServices:@[_serviceUUID]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup:peripheral]; return;
    }

    // discover characteristic of each service
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[_characteristicUUID] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup:peripheral]; return;
    }

    //
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // get only characteristic we want
        if ([characteristic.UUID isEqual:_characteristicUUID]) {
            
            // subscribe to it (let the peripheral know we want the data it contains)
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // if error, exit and wait for next notification
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]); return;
    }

    // get user uuid assign to characteristic
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDBytes:characteristic.value.bytes];
    
    // cache discovery date & value
    [_intervals setObject:[NSDate date] forKey:peripheral.identifier];
    [_users setObject:uuid forKey:peripheral.identifier];
    
    // send delegate message
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(identityMonitor:didRegiserUser:)]) {
            [_delegate identityMonitor:self didRegiserUser:uuid];
        }
    });
    
    // and disconnect from the peripehral
    [_manager cancelPeripheralConnection:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription); return;
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:_characteristicUUID]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [_manager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral Disconnected");
    [_peripherals removeObject:peripheral];
    
    // We're disconnected, so start scanning again
    [self startScanning];
}

- (void)cleanup:(CBPeripheral *)peripheral {
    // don't do anything if we're not connected
    if (peripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    
    // see if we are subscribed to a characteristic on the peripheral
    if (peripheral.services != nil) {
        for (CBService *service in peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:_characteristicUUID]) {
                        if (characteristic.isNotifying) {
                            // it is notifying, so unsubscribe
                            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // done
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // if we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [_manager cancelPeripheralConnection:peripheral];
}

- (void)removeOutdatedUsers:(NSTimeInterval)interval {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSMutableSet *uuids = [NSMutableSet new];
    
    // find outdated intervals
    [_intervals enumerateKeysAndObjectsUsingBlock:^(NSUUID *key, NSDate *obj, BOOL *stop) {
        if ([obj timeIntervalSinceNow] < -interval) {
            [uuids addObject:key];
        }
    }];
    
    // send delegate message
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUUID *uuid in uuids) {
            if ([_delegate respondsToSelector:@selector(identityMonitor:didUnregiserUser:)]) {
                [_delegate identityMonitor:self didUnregiserUser:_users[uuid]];
            }
        }
        
        // release semaphore
        dispatch_semaphore_signal(sem);
    });
    
    // wait until inform delegate
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    // remove cached intervals
    [_intervals removeObjectsForKeys:[uuids allObjects]];
}

- (void)scheduledTimerWithTimeInterval:(NSTimeInterval)interval {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), _managerQueue, ^{
        if (!_timer) return;
        
        // remove uuids
        [self removeOutdatedUsers:10];
        
        // repeat
        [self scheduledTimerWithTimeInterval:interval];
    });
}

@end
