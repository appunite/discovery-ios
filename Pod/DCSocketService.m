//
//  AUController.m
//  Discovery
//
//  Created by Emil Wojtaszek on 25/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "DCSocketService.h"

NSString * const AUMessageTypePresenceKey = @"presence";
NSString * const AUMessageTypeAbsenceKey = @"absence";
NSString * const AUMessageTypeMetadataKey = @"metadata";

@implementation DCSocketService {
    NSString *_serviceUUID;
}

- (instancetype)initWithService:(NSUUID *)service {
    self = [super init];
    if (self) {
        _serviceUUID = [service UUIDString];
        NSParameterAssert(_serviceUUID);
        
        // create basic serializer/deserializer
        _messageSerializer = [DCJSONMessageSerializer new];
        _messageDeserializer = [DCJSONMessageDeserializer new];
    }
    return self;
}

- (void)openConnectionWithURL:(NSURL *)url {
    if (_webSocket) return;

    // create request based on provider URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // create and open new web socket instance
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)closeConnection {
    // close socket
    [_webSocket close];
}

- (void)subscribeUsers:(NSSet *)users {
    for (NSUUID *user in users) {
        // send `presence` message
        [self sendMessage:[[self class] presenceMessageForUserUUID:user]];
    }
}

#pragma mark -
#pragma mark Private

- (void)sendMessage:(NSDictionary *)message {
    if (_webSocket.readyState != SR_OPEN) return;
    
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
}

- (void)identityMonitor:(DCBluetoothMonitor *)monitor didUnregiserUser:(NSUUID *)user {
    // send `absence` message
    [self sendMessage:[[self class] absenceMessageForUserUUID:user]];
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
    if ([_delegate respondsToSelector:@selector(service:didReceiveMessage:)]) {
        [_delegate service:self didReceiveMessage:message];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    // forward delegate
    if ([_delegate respondsToSelector:@selector(serviceDidOpenConnection:)]) {
        [_delegate serviceDidOpenConnection:self];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    _webSocket.delegate = nil;
    _webSocket = nil;

    // forward delegate
    if ([_delegate respondsToSelector:@selector(serviceDidCloseConnection:)]) {
        [_delegate serviceDidCloseConnection:self];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    _webSocket.delegate = nil;
    _webSocket = nil;
    
    // forward delegate
    if ([_delegate respondsToSelector:@selector(service:didFailWithError:)]) {
        [_delegate service:self didFailWithError:error];
    }
}

#pragma mark -
#pragma mark Messages

- (NSDictionary *)messageWithType:(NSString *)type body:(NSDictionary *)body {
    NSParameterAssert(type); NSParameterAssert(body);
    return @{@"header": @{@"id": [[NSUUID UUID] UUIDString], @"type": type, @"service": _serviceUUID}, @"body": body};
}

- (NSDictionary *)metadataMessageWithPayload:(NSDictionary *)metadata {
    NSParameterAssert(metadata);
    return [self messageWithType:AUMessageTypeMetadataKey body:metadata];
}

- (NSDictionary *)presenceMessageForUserUUID:(NSUUID *)uuid {
    NSParameterAssert(uuid);
    return [self messageWithType:AUMessageTypePresenceKey body:@{@"id": uuid.UUIDString}];
}

- (NSDictionary *)absenceMessageForUserUUID:(NSUUID *)uuid {
    NSParameterAssert(uuid);
    return [self messageWithType:AUMessageTypeAbsenceKey body:@{@"id": uuid.UUIDString}];
}

@end
