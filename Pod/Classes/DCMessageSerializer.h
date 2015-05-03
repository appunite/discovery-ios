//
//  DCMessageSerializer.h
//  Discovery
//
//  Created by Emil Wojtaszek on 14/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCMessageSerializerProtocol <NSObject, NSSecureCoding, NSCopying>
- (id)serializeMessage:(NSData *)data
                 error:(NSError * __autoreleasing *)error;
@end

@interface DCJSONMessageSerializer : NSObject <DCMessageSerializerProtocol>

@end
