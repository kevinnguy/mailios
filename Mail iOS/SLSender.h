//
//  SLSender.h
//  Mail iOS
//
//  Created by Kevin Nguy on 1/20/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLSender : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *messages;

- (id)initWithName:(NSString *)name message:(MCOAbstractMessage *)message;
@end
