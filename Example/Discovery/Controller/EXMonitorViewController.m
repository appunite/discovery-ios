//
//  EXMonitorViewController.m
//  Discovery
//
//  Created by Emil Wojtaszek on 11/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "EXMonitorViewController.h"

//Cell
#import "EXUserCell.h"

//Categories
#import "UIImageView+AFNetworking.h"

//Others
#import "EXConstants.h"

//Discovery
#import "DCSocketService.h"
#import "DCBluetoothMonitor.h"

@interface EXMonitorViewController () <DCSocketServiceDelegate>
@property (nonatomic, strong) DCBluetoothMonitor *bluetoothMonitor;
@end

@implementation EXMonitorViewController {
    NSMutableArray *_users;
    NSMutableDictionary *_metadata;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // create containers
    _users = [NSMutableArray new];
    _metadata = [NSMutableDictionary new];

    // create UUID's
    CBUUID *serviceUUID = [CBUUID UUIDWithString:EXServiceUUIDKey];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:EXCharacteristicUUIDKey];
    
    // assign delegate
    DCSocketService *service = [DCSocketService sharedService];
    [service setDelegate:self];

    // create bluetooth monitor
    _bluetoothMonitor = [[DCBluetoothMonitor alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    _bluetoothMonitor.delegate = service;
    [_bluetoothMonitor startScanning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //
    DCSocketService *service = [DCSocketService sharedService];
    
    // connect if needed
    if (service.webSocket.readyState != SR_OPEN) {
        [service openSocketWithURL:[NSURL URLWithString:EXSocketURL]];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (EXUserCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fetch user's metadata
    NSString *userUUID = _users[indexPath.row];
    NSDictionary *metadata = _metadata[userUUID];

    // dequeue and populate cell
    EXUserCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EXUserCell class]) forIndexPath:indexPath];
    // fill content
    [cell.idLabel setText:metadata[@"id"]];
    [cell.nameLabel setText:metadata[@"name"]];
    [cell.emailLabel setText:metadata[@"email"]];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:metadata[@"avatar"]]];

    // add temporary cover until revice data
    cell.coverView.hidden = metadata != nil;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_users count];
}

#pragma mark - 
#pragma mark DCSocketServiceDelegate

- (void)controllerDidOpenSocketConnection:(DCSocketService *)controller {
    NSLog(@"Socket connection status: open");
    
    // register already discovered user
    [[DCSocketService sharedService] subscribeUsers:_bluetoothMonitor.users];
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

    // animate insertion
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    // update title
    [self updateTitle];
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
    
    // animate insertion
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    // update title
    [self updateTitle];
}

- (void)controller:(DCSocketService *)controller didReceiveMessage:(NSDictionary *)data {
    // desompose response
    NSDictionary *body = data[@"body"];
    NSString *uid = body[@"id"];
    
    // update metadata
    [_metadata setObject:body forKey:uid];

    // reload cell
    NSUInteger idx = [_users indexOfObject:uid];
    if (idx != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark Private

- (void)updateTitle {
    self.navigationItem.prompt = [_users count] != 0 ? [NSString stringWithFormat:@"%ld user(s)", (unsigned long)[_users count]] : nil;
}

@end

