//
//  DCDiscoveryManager.m
//  Pods
//
//  Created by Emil Wojtaszek on 17/05/15.
//
//

#import "DCDiscoveryManager.h"

@interface DCDiscoveryManager ()
@property (nonatomic, strong) NSUUID *userIdentifier;
@property (nonatomic, strong) CBUUID *service;
@property (nonatomic, strong) CBUUID *characteristic;
@end

@implementation DCDiscoveryManager
@synthesize socketService = _socketService;
@synthesize bluetoothMonitor = _bluetoothMonitor;
@synthesize bluetoothEmitter = _bluetoothEmitter;

- (instancetype)initWithService:(CBUUID *)service characteristic:(CBUUID *)characteristic userIdentifier:(NSUUID *)value {
    self = [super init];
    if (self) {
        // assign identifiers
        _service = service;
        _characteristic = characteristic;
        _userIdentifier = value;
    }
    return self;
}

- (void)openConnectionWithURL:(NSURL *)url {
    [self.socketService openConnectionWithURL:url];
}

- (void)closeConnection {
    [self.socketService closeConnection];
    _socketService = nil;
}

- (void)startAdvertising {
    [self.bluetoothEmitter startAdvertising];
}

- (void)stopAdvertising {
    [self.bluetoothEmitter stopAdvertising];
}

- (void)startScanning {
    [self.bluetoothMonitor startScanning];
}

- (void)stopScanning {
    [self.bluetoothMonitor stopScanning];
}

#pragma mark -
#pragma mark Getters

- (DCSocketService *)socketService {
    if (!_socketService) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[_service UUIDString]];
        _socketService = [[DCSocketService alloc] initWithService:uuid];
        _socketService.delegate = self;
    }
    return _socketService;
}

- (DCBluetoothEmitter *)bluetoothEmitter {
    if (!_bluetoothEmitter) {
        _bluetoothEmitter = [[DCBluetoothEmitter alloc] initWithService:_service characteristic:_characteristic value:_userIdentifier];
    }
    return _bluetoothEmitter;
}

- (DCBluetoothMonitor *)bluetoothMonitor {
    if (!_bluetoothMonitor) {
        _bluetoothMonitor = [[DCBluetoothMonitor alloc] initWithServiceUUID:_service characteristicUUID:_characteristic];
        _bluetoothMonitor.delegate = self;
    }
    return _bluetoothMonitor;
}

#pragma mark -
#pragma mark DCBluetoothMonitorDelegate

- (void)identityMonitor:(DCBluetoothMonitor *)monitor didRegiserUser:(NSUUID *)user {
    // send `presence` message
    NSDictionary *payload = [_socketService presenceMessageForUserUUID:user];
    [self.socketService sendMessage:payload];

    //
    if ([_delegate respondsToSelector:@selector(discoveryManager:didSubscribeUser:)]) {
        [_delegate discoveryManager:self didSubscribeUser:user];
    }
}

- (void)identityMonitor:(DCBluetoothMonitor *)monitor didUnregiserUser:(NSUUID *)user {
    // send `absence` message
    NSDictionary *payload = [_socketService absenceMessageForUserUUID:user];
    [self.socketService sendMessage:payload];

    //
    if ([_delegate respondsToSelector:@selector(discoveryManager:didUnsubscribeUser:)]) {
        [_delegate discoveryManager:self didUnsubscribeUser:user];
    }
}

#pragma mark -
#pragma mark DCSocketServiceDelegate

- (void)service:(DCSocketService *)service didReceiveMessage:(NSDictionary *)data {
    // forward message
    if ([_delegate respondsToSelector:@selector(discoveryManager:didReceiveMessage:)]) {
        [_delegate discoveryManager:self didReceiveMessage:data];
    }
}

- (void)serviceDidOpenConnection:(DCSocketService *)service {
    NSLog(@"Socket service did open connection");
    [self.socketService subscribeUsers:self.bluetoothMonitor.users];
}

- (void)serviceDidCloseConnection:(DCSocketService *)service {
    NSLog(@"Socket service did close connection");
}

- (void)service:(DCSocketService *)service didFailWithError:(NSError *)error {
    NSLog(@"Socket service did faild with error: %@", error);
}

@end
