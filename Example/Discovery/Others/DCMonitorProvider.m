//
//  DCMonitorProvider.m
//  Discovery
//
//  Created by Emil Wojtaszek on 11/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import "DCMonitorProvider.h"


@implementation DCMonitorProvider 

- (instancetype)init {
    self = [super init];
    if (self) {
        // create containers
        _users = [NSMutableArray new];
        _metadata = [NSMutableDictionary new];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
  
    // create socket service
    NSUUID *service = [[NSUUID alloc] initWithUUIDString:@"689D5F89-8003-4F1F-9C35-21D615C87E6A"];
    NSUUID *characteristic = [[NSUUID alloc] initWithUUIDString:@"8E6D7A6B-BF18-4A77-AEEF-E04B9D1265C2"];
    NSUUID *userIdentifier = [self userUUID];

    // create new manager
    _manager = [[DCDiscoveryManager alloc] initWithService:service
                                            characteristic:characteristic
                                            userIdentifier:userIdentifier];
    _manager.delegate = self;
}

- (void)connect {
    NSURL *url = [NSURL URLWithString:@"ws://192.168.1.115:8888/chat"];

    // connect if needed
    if (_manager.socketService.webSocket.readyState != SR_OPEN) {
        [_manager openConnectionWithURL:url];
    }
}

#pragma mark -
#pragma mark Private

- (NSUUID *)userUUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [userDefaults objectForKey:@"kUserUUIDKey"];
    if (!uuid) {
        uuid = [[NSUUID UUID] UUIDString];
        [userDefaults setObject:uuid forKey:@"kUserUUIDKey"];
    }
    
    return [[NSUUID alloc] initWithUUIDString:uuid];;
}

#pragma mark -
#pragma mark DCDiscoveryManagerDelegate

- (void)discoveryManager:(DCDiscoveryManager *)manager didSubscribeUser:(NSUUID *)user {
    NSLog(@"Subscribed to user: %@", [user UUIDString]);
    
    // update list of currently visible users
    [_users addObject:[user UUIDString]];
    
    // last index path
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_users count] -1 inSection:0];
    
    // send delegate
    if ([_delegate respondsToSelector:@selector(provider:didAddUserAtIndexPath:)]) {
        [_delegate provider:self didAddUserAtIndexPath:indexPath];
    }
}

- (void)discoveryManager:(DCDiscoveryManager *)manager didUnsubscribeUser:(NSUUID *)user {
    NSLog(@"Unsubscribed from user: %@", [user UUIDString]);
    
    // get idex of user to delete
    NSInteger idx = [_users indexOfObject:[user UUIDString]];
    if (idx == NSNotFound) return;
    
    // user's index path
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    // update list of currently visible users
    [_users removeObjectAtIndex:idx];
    
    // send delegate
    if ([_delegate respondsToSelector:@selector(provider:didRemoveUserAtIndexPath:)]) {
        [_delegate provider:self didRemoveUserAtIndexPath:indexPath];
    }
}

- (void)discoveryManager:(DCDiscoveryManager *)manager didReceiveMessage:(NSDictionary *)data {
    // desompose response
    NSDictionary *body = data[@"body"];
    NSString *uid = body[@"id"];
    
    // update metadata
    [_metadata setObject:body forKey:uid];
    
    // reload cell
    NSUInteger idx = [_users indexOfObject:uid];
    if (idx == NSNotFound) {
        return;
    }
    
    // user's index path
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];

    // send delegate
    if ([_delegate respondsToSelector:@selector(provider:didUpdateUserAtIndexPath:)]) {
        [_delegate provider:self didUpdateUserAtIndexPath:indexPath];
    }

}

@end
