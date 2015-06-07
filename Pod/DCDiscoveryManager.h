//
//  DCDiscoveryManager.h
//  Pods
//
//  Created by Emil Wojtaszek on 17/05/15.
//
//

#import <Foundation/Foundation.h>

//Discovery
#import "DCSocketService.h"
#import "DCBluetoothEmitter.h"
#import "DCBluetoothMonitor.h"

@protocol DCDiscoveryManagerDelegate;
@interface DCDiscoveryManager : NSObject <DCBluetoothMonitorDelegate, DCSocketServiceDelegate>
@property (nonatomic, weak) id<DCDiscoveryManagerDelegate> delegate;

//
@property (nonatomic, strong, readonly) NSUUID *userIdentifier;
- (instancetype)initWithService:(NSUUID *)service
                 characteristic:(NSUUID *)characteristic
                 userIdentifier:(NSUUID *)value NS_DESIGNATED_INITIALIZER;

// sockets
@property (strong, nonatomic, readonly) DCSocketService *socketService;
- (void)openConnectionWithURL:(NSURL *)url;
- (void)closeConnection;

// bluetooth peripherial manager
@property (strong, nonatomic, readonly) DCBluetoothEmitter *bluetoothEmitter;
- (void)startAdvertising;
- (void)stopAdvertising;

// bluetooth central manager
@property (strong, nonatomic, readonly) DCBluetoothMonitor *bluetoothMonitor;
- (void)startScanning;
- (void)stopScanning;

@end

@protocol DCDiscoveryManagerDelegate <NSObject>
// subscribe/unsubscribe to user in range
- (void)discoveryManager:(DCDiscoveryManager *)manager didSubscribeUser:(NSUUID *)user;
- (void)discoveryManager:(DCDiscoveryManager *)manager didUnsubscribeUser:(NSUUID *)user;

// recived payload
- (void)discoveryManager:(DCDiscoveryManager *)manager didReceiveMessage:(NSDictionary *)data;
@end
