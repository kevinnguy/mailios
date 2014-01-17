//
//  SLIMAPManager.h
//  Mail iOS
//
//  Created by Kevin Nguy on 1/16/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLIMAPManagerDelegate <NSObject>

- (void)didGetMessages:(NSArray *)messages;

@end

@interface SLIMAPManager : NSObject
@property (nonatomic, assign) id<SLIMAPManagerDelegate> delegate;
@property (nonatomic, strong) MCOIMAPSession *session;
@property (nonatomic, strong) MCOIMAPMessage *message;
@property (nonatomic, strong) NSMutableArray *userFolders;
@property (nonatomic, assign) MCOIMAPMessagesRequestKind messagesRequestKind;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *fetchMessagesOperation;

+ (SLIMAPManager *)sharedManager;
- (void)setupSharedManagerWithHostname:(NSString *)hostname port:(NSInteger)port;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)getMessages;

@end