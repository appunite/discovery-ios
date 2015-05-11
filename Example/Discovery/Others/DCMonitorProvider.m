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
  
    // assign delegate
    _manager.socketService.delegate = self;
}

#pragma mark -
#pragma mark DCSocketServiceDelegate

- (void)controllerDidOpenSocketConnection:(DCSocketService *)controller {
    NSLog(@"Socket connection status: open");
    
    // register already discovered user
    [_manager assignUsers];
}

- (void)controllerDidCloseSocketConnection:(DCSocketService *)controller {
    NSLog(@"Socket connection status: closed");
}

- (void)controller:(DCSocketService *)controller socketDidFailWithError:(NSError *)error {
    NSLog(@"Socket error: %@", error.localizedDescription);
}

- (void)controller:(DCSocketService *)controller didSubscribeToUser:(NSUUID *)user {
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

- (void)controller:(DCSocketService *)controller didUnsubscribeFromUser:(NSUUID *)user {
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

- (void)controller:(DCSocketService *)controller didReceiveMessage:(NSDictionary *)data {
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
