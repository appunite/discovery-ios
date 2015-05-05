//
//  UserCell.h
//  Discovery
//
//  Created by Emil Wojtaszek on 04/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell
// content
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

// helpers
@property (weak, nonatomic) IBOutlet UIView *coverView;
@end
