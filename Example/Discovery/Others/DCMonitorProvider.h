//
//  DCMonitorProvider.h
//  Discovery
//
//  Created by Emil Wojtaszek on 11/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import <Foundation/Foundation.h>

//Others
#import "EXManager.h"
#import "EXConstants.h"

@protocol DCMonitorProviderDelegate;

@interface DCMonitorProvider : NSObject <DCSocketServiceDelegate>
@property (nonatomic, weak) IBOutlet id<DCMonitorProviderDelegate> delegate;
//
@property (nonatomic, strong) IBOutlet EXManager *manager;

//
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableDictionary *metadata;

@end

@protocol DCMonitorProviderDelegate <NSObject>
- (void)provider:(DCMonitorProvider *)provider didAddUserAtIndexPath:(NSIndexPath *)indexPath;
- (void)provider:(DCMonitorProvider *)provider didRemoveUserAtIndexPath:(NSIndexPath *)indexPath;
- (void)provider:(DCMonitorProvider *)provider didUpdateUserAtIndexPath:(NSIndexPath *)indexPath;
@end
