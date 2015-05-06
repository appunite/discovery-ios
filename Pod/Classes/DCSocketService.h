//
//  AUController.h
//  Discovery
//
//  Created by Emil Wojtaszek on 25/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//Sockets
#import "SRWebSocket.h"

//Others
#import "DCMessageSerializer.h"
#import "DCMessageDeserializer.h"

//Controllers
#import "DCBluetoothMonitor.h"

@protocol DCSocketServiceDelegate;

@interface DCSocketService : NSObject <SRWebSocketDelegate, DCBluetoothMonitorDelegate>
@property (nonatomic, weak) id<DCSocketServiceDelegate> delegate;

// serializers
@property (nonatomic, strong) id<DCMessageSerializerProtocol> messageSerializer;
@property (nonatomic, strong) id<DCMessageDeserializerProtocol> messageDeserializer;

// web socket
@property (nonatomic, strong, readonly) SRWebSocket *webSocket;

// sockets
- (void)openSocketWithURL:(NSURL *)url;
- (void)closeSocket;

// 
- (void)subscribeUsers:(NSSet *)users;

//
- (void)sendMessage:(NSDictionary *)message;
@end

@protocol DCSocketServiceDelegate <NSObject>
// socket
- (void)controllerDidOpenSocketConnection:(DCSocketService *)controller;
- (void)controllerDidCloseSocketConnection:(DCSocketService *)controller;
- (void)controller:(DCSocketService *)controller socketDidFailWithError:(NSError *)error;

// subscribe/unsubscribe to user in range
- (void)controller:(DCSocketService *)controller didSubscribeToUser:(NSUUID *)user;
- (void)controller:(DCSocketService *)controller didUnsubscribeFromUser:(NSUUID *)user;

// metadata update
- (void)controller:(DCSocketService *)controller didReceiveMessage:(NSDictionary *)data;
@end

@interface DCSocketService (Messages)

//
+ (NSDictionary *)messageWithType:(NSString *)type body:(NSDictionary *)body;

// predefined messages
+ (NSDictionary *)metadataMessageWithPayload:(NSDictionary *)metadata;
+ (NSDictionary *)presenceMessageForUserUUID:(NSUUID *)uuid;
+ (NSDictionary *)absenceMessageForUserUUID:(NSUUID *)uuid;

@end

extern NSString * const AUMessageTypePresenceKey;
extern NSString * const AUMessageTypeAbsenceKey;
extern NSString * const AUMessageTypeMetadataKey;
