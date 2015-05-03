//
//  AUController.m
//  Discovery
//
//  Created by Emil Wojtaszek on 25/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "DCSocketService.h"

//Controllers
#import "DCBluetoothMonitor.h"

NSString * const AUMessageTypePresenceKey = @"presence";
NSString * const AUMessageTypeAbsenceKey = @"absence";
NSString * const AUMessageTypeMetadataKey = @"metadata";

@interface DCSocketService () <DCBluetoothMonitorDelegate>

@end

@implementation DCSocketService

- (instancetype)initWithIdentityMonitor:(DCBluetoothMonitor *)monitor {
    NSParameterAssert(monitor);
    
    self = [super init];
    if (self) {
        // create basic serializer/deserializer
        _messageSerializer = [DCJSONMessageSerializer new];
        _messageDeserializer = [DCJSONMessageDeserializer new];

        // create identity monitor
        _centralManager = monitor;
        _centralManager.delegate = self;
    }
    return self;
}

- (void)openSocketWithURL:(NSURL *)url {
    if (_webSocket) return;

    // create request based on provider URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // create and open new web socket instance
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)closeSocket {
    // close socket
    [_webSocket close];
}

#pragma mark -
#pragma mark Private

- (void)sendMessage:(NSDictionary *)message {
    if (!_webSocket) return;
    
    // serialize to NSData object
    NSError *error = nil;
    NSData *data = [self.messageDeserializer deserializeMessage:message error:&error];
    
    // log if error
    if (!data || error) {
        NSLog(@"%@", error);
    }
    
    // send data over socket
    [_webSocket send:data];
}

#pragma mark - 
#pragma mark DCBluetoothMonitorDelegate

- (void)identityMonitor:(DCBluetoothMonitor *)monitor didRegiserUser:(NSUUID *)user {
    // send `presence` message
    [self sendMessage:[[self class] presenceMessageForUserUUID:user]];

    // forward delegate
    if ([_delegate respondsToSelector:@selector(controller:didSubscribeToUser:)]) {
        [_delegate controller:self didSubscribeToUser:user];
    }
}

- (void)identityMonitor:(DCBluetoothMonitor *)monitor didUnregiserUser:(NSUUID *)user {
    // send `absence` message
    [self sendMessage:[[self class] absenceMessageForUserUUID:user]];

    // forward delegate
    if ([_delegate respondsToSelector:@selector(controller:didUnsubscribeFromUser:)]) {
        [_delegate controller:self didUnsubscribeFromUser:user];
    }
}

#pragma mark -
#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)response {
    if (![response isKindOfClass:[NSData class]]) {
        return;
    }
    
    // create message
    NSDictionary *message = [_messageSerializer serializeMessage:response error:nil];
    
    // forward delegate
    if ([_delegate respondsToSelector:@selector(controller:didReceiveMessage:)]) {
        [_delegate controller:self didReceiveMessage:message];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    // forward delegate
    if ([_delegate respondsToSelector:@selector(controllerDidOpenSocketConnection:)]) {
        [_delegate controllerDidOpenSocketConnection:self];
    }
    
    // find some peripherials
    [_centralManager startScanning];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    _webSocket.delegate = nil;
    _webSocket = nil;

    // forward delegate
    if ([_delegate respondsToSelector:@selector(controllerDidOpenSocketConnection:)]) {
        [_delegate controllerDidCloseSocketConnection:self];
    }
    
    // stop scanning
    [_centralManager stopScanning];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    _webSocket.delegate = nil;
    _webSocket = nil;
    
    // forward delegate
    if ([_delegate respondsToSelector:@selector(controller:socketDidFailWithError:)]) {
        [_delegate controller:self socketDidFailWithError:error];
    }
    
    // stop scanning
    [_centralManager stopScanning];
}

#pragma mark -
#pragma mark Messages

+ (NSDictionary *)messageWithType:(NSString *)type body:(NSDictionary *)body {
    NSParameterAssert(type); NSParameterAssert(body);
    return @{@"header": @{@"id": [[NSUUID UUID] UUIDString], @"type": type}, @"body": body};
}

+ (NSDictionary *)metadataMessageWithPayload:(NSDictionary *)metadata {
    NSParameterAssert(metadata);
    return [self messageWithType:AUMessageTypeMetadataKey body:metadata];
}

+ (NSDictionary *)presenceMessageForUserUUID:(NSUUID *)uuid {
    NSParameterAssert(uuid);
    return [self messageWithType:AUMessageTypePresenceKey body:@{@"id": uuid.UUIDString}];
}

+ (NSDictionary *)absenceMessageForUserUUID:(NSUUID *)uuid {
    NSParameterAssert(uuid);
    return [self messageWithType:AUMessageTypeAbsenceKey body:@{@"id": uuid.UUIDString}];
}

@end
