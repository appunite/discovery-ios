//
//  DCMessageDeserializer.h
//  Discovery
//
//  Created by Emil Wojtaszek on 14/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCMessageDeserializerProtocol <NSObject, NSSecureCoding, NSCopying>
- (NSData *)deserializeMessage:(id)payload
                         error:(NSError * __autoreleasing *)error;
@end

@interface DCJSONMessageDeserializer : NSObject <DCMessageDeserializerProtocol>

@end
