//
//  DCMessageSerializer.m
//  Discovery
//
//  Created by Emil Wojtaszek on 14/04/15.
//  Copyright (c) 2015 AppUnite.com. All rights reserved.
//

#import "DCMessageSerializer.h"

@implementation DCJSONMessageSerializer

#pragma mark -
#pragma mark DCMessageSerializerProtocol

- (id)serializeMessage:(NSData *)data error:(NSError * __autoreleasing *)error {
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

#pragma mark -
#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] init];
}

@end
