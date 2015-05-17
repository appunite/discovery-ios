//
//  EXMonitorViewController.m
//  Discovery
//
//  Created by Emil Wojtaszek on 11/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "EXMonitorViewController.h"
#import "EXProfileViewController.h"

//Cell
#import "EXUserCell.h"

//Categories
#import "UIImageView+AFNetworking.h"

//Others
#import "DCMonitorProvider.h"

@interface EXMonitorViewController () <DCMonitorProviderDelegate>
@property (strong, nonatomic) IBOutlet DCMonitorProvider *provider;
@end

@implementation EXMonitorViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // connect if needed
    [_provider connect];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (EXUserCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fetch user's metadata
    NSString *userUUID = _provider.users[indexPath.row];
    NSDictionary *metadata = _provider.metadata[userUUID];

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
    return [_provider.users count];
}

#pragma mark - 
#pragma mark DCSocketServiceDelegate

- (void)provider:(DCMonitorProvider *)provider didAddUserAtIndexPath:(NSIndexPath *)indexPath {
    // animate insertion
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    // update title
    [self updateTitle];
}

- (void)provider:(DCMonitorProvider *)provider didRemoveUserAtIndexPath:(NSIndexPath *)indexPath {
    // animate insertion
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    // update title
    [self updateTitle];
}

- (void)provider:(DCMonitorProvider *)provider didUpdateUserAtIndexPath:(NSIndexPath *)indexPath {
    // animate update
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark Private

- (void)updateTitle {
    NSUInteger count = [_provider.users count];
    self.navigationItem.prompt = count != 0 ? [NSString stringWithFormat:@"%ld user(s)", (unsigned long)count] : nil;
}

#pragma mark - 
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EXProfileViewController *viewController = [segue destinationViewController];
    viewController.manager = _provider.manager;
}

#pragma mark -
#pragma mark Actions

- (IBAction)advertiseAction:(UISwitch *)sender {
    if (sender.isOn) {
        [_provider.manager.bluetoothEmitter startAdvertising];
    } else {
        [_provider.manager.bluetoothEmitter stopAdvertising];
    }
}

@end

