//
//  SLSender.m
//  Mail iOS
//
//  Created by Kevin Nguy on 1/20/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import "SLSender.h"

@implementation SLSender
- (id)initWithName:(NSString *)name message:(MCOAbstractMessage *)message{
    if (self = [super init]) {
        self.name = name;
        self.messages = [NSMutableArray new];
        [self.messages addObject:message];
    }
    
    return self;
}
@end
