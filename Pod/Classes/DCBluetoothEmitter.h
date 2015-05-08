//
//  AUPeripheralManager.h
//  Discovery
//
//  Created by Emil Wojtaszek on 12/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

//Frameworks
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString * const DCBluetoothEmitterRestoreIdentifierKey;

@interface DCBluetoothEmitter : NSObject <CBPeripheralManagerDelegate>
// bluetooth peripheral manager
@property (nonatomic, strong, readonly) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong, readonly) dispatch_queue_t managerQueue;

/*!
 *  @method initWithService:characteristic:user:
 *
 *  @param service			The Bluetooth UUID of the service.
 *  @param characteristic	The Bluetooth UUID of the characteristic.
 *  @param value            Value assing to characteristic, describes user identifer.
 *
 *  @discussion This method initialize `CBPeripheralManager` and assing new 
 *              service to peripherial manager based on provided data.
 *
 */
- (instancetype)initWithService:(CBUUID *)service
                 characteristic:(CBUUID *)characteristic
                          value:(NSUUID *)value NS_DESIGNATED_INITIALIZER;

/*!
 *  @method startAdvertising
 *
 *  @discussion This method starts broadcasting advertisment data.
 *
 */
- (void)startAdvertising;

/*!
 *  @method stopAdvertising:
 *
 *  @discussion This method stops broadcast advertisment data.
 *
 */
- (void)stopAdvertising;
@end

