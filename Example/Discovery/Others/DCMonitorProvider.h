//
//  DCMonitorProvider.h
//  Discovery
//
//  Created by Emil Wojtaszek on 11/05/15.
//  Copyright (c) 2015 Emil Wojtaszek. All rights reserved.
//

#import <Foundation/Foundation.h>

//Others
#import "DCDiscoveryManager.h"

@protocol DCMonitorProviderDelegate;

@interface DCMonitorProvider : NSObject <DCDiscoveryManagerDelegate>
@property (nonatomic, weak) IBOutlet id<DCMonitorProviderDelegate> delegate;
//
@property (nonatomic, strong) DCDiscoveryManager *manager;

//
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableDictionary *metadata;

- (void)connect;
@end

@protocol DCMonitorProviderDelegate <NSObject>
- (void)provider:(DCMonitorProvider *)provider didAddUserAtIndexPath:(NSIndexPath *)indexPath;
- (void)provider:(DCMonitorProvider *)provider didRemoveUserAtIndexPath:(NSIndexPath *)indexPath;
- (void)provider:(DCMonitorProvider *)provider didUpdateUserAtIndexPath:(NSIndexPath *)indexPath;
@end
