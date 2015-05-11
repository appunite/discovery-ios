//
//  EXProfileViewController.m
//  Discovery
//
//  Created by Emil Wojtaszek on 11/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "EXProfileViewController.h"

//Categories
#import "UIImageView+AFNetworking.h"

@interface EXProfileViewController () <UITextFieldDelegate>
//Outlets
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@end

@implementation EXProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // fetch avatar image
    [self updateAvatar];
}

#pragma mark -
#pragma mark Actions

- (IBAction)updateAction:(id)sender {
    // hide keyboard
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
    // check connection
    DCSocketService *service = [_manager socketService];
    if (service.webSocket.readyState != SR_OPEN) return;

    // metadata payload
    NSDictionary *metadata = @{
        @"id": [[NSUUID alloc] initWithUUIDString:EXUserUUIDKey],
        @"name": self.nameTextField.text,
        @"email": self.emailTextField,
        @"avatar": [self avatarURLString]
    };
    
    // send update user metadata socket message
    [service sendMessage:[DCSocketService messageWithType:AUMessageTypeMetadataKey body:metadata]];
    
    // update avatar image view
    [self updateAvatar];
}

#pragma mark - 
#pragma mark Private

- (void)updateAvatar {
    // generate random avator image based on user name
    [self.imageView setImageWithURL:[NSURL URLWithString:[self avatarURLString]]];
}

- (IBAction)textFieldValueChangedAction:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = [sender.text length] > 0;
}

- (NSString *)avatarURLString {
    return [NSString stringWithFormat:@"http://api.adorable.io/avatars/150/%@.png", self.nameTextField.text];
}

@end
