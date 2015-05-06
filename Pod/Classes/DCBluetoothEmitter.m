//
//  AUPeripheralManager.m
//  Discovery
//
//  Created by Emil Wojtaszek on 12/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "DCBluetoothEmitter.h"

@implementation DCBluetoothEmitter {
    // keep as ivar to retain value
    CBUUID *_uuid;
    NSDictionary *_advertisment;
    CBMutableService *_service;
}

- (instancetype)initWithService:(CBUUID *)service characteristic:(CBUUID *)characteristic value:(NSUUID *)value {
    self = [super init];
    if (self) {
        _uuid = service;
        
        // create manager
        _managerQueue = dispatch_queue_create("com.appunite.peripheral.queue", DISPATCH_QUEUE_SERIAL);
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_managerQueue options:@{
            CBPeripheralManagerOptionShowPowerAlertKey: @YES,
            CBPeripheralManagerOptionRestoreIdentifierKey: AUIdentityEmitterRestoreIdentifierKey
        }];
        
        // register service with characteristic
        [self createServiceWithUUID:service characteristicUUID:characteristic value:value];
    }
    return self;
}

- (void)startAdvertising {
    dispatch_sync(_managerQueue, ^{
        // save payload
        _advertisment = @{CBAdvertisementDataServiceUUIDsKey:@[_uuid]};
        
        // register service
        if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
            [_peripheralManager startAdvertising:_advertisment];
        }
    });
}

- (void)stopAdvertising {
    dispatch_sync(_managerQueue, ^{
        // stop advrtising
        _advertisment = nil;
        [_peripheralManager stopAdvertising];
    });
}

#pragma mark -
#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    // restore service
    NSArray *services = dict[CBPeripheralManagerRestoredStateServicesKey];
    _service = [services firstObject];
    
    // restore advertide payload
    _advertisment = dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // re-register service
    [_peripheralManager removeAllServices];
    [_peripheralManager addService:_service];

    // start advertising
    if (_advertisment) {
        [_peripheralManager startAdvertising:_advertisment];
    } else {
        [_peripheralManager stopAdvertising];
    }
}

#pragma mark - 
#pragma mark Logs

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Starting advertising failed: %@", error);
    } else {
        NSLog(@"Peripherial did start advertising");
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    } else {
        NSLog(@"Peripherial did add service: %@", [[service UUID] UUIDString]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central: %@ did subscribe to characteristic: %@", [[central identifier] UUIDString], [[characteristic UUID] UUIDString]);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central: %@ did unsubscribe from characteristic: %@", [[central identifier] UUIDString], [[characteristic UUID] UUIDString]);
}

#pragma mark - 
#pragma mark Private 

- (void)createServiceWithUUID:(CBUUID *)service characteristicUUID:(CBUUID *)characteristic value:(NSUUID *)value {
    // convert value to bytes
    uuid_t uuid; [value getUUIDBytes:uuid];
    
    // create characteristic
    CBMutableCharacteristic *mutableCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristic
                                                                                        properties:CBCharacteristicPropertyRead
                                                                                             value:[NSData dataWithBytes:uuid length:16]
                                                                                       permissions:CBAttributePermissionsReadable];
    
    // create service
    _service = [[CBMutableService alloc] initWithType:service primary:YES];
    
    // add the characteristic to the service
    _service.characteristics = @[mutableCharacteristic];
}

@end

NSString * const AUIdentityEmitterRestoreIdentifierKey = @"com.appunite.peripherial.restore-identifier";

