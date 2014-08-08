//
//  SLIMAPManager.h
//  Mail iOS
//
//  Created by Kevin Nguy on 1/16/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SLSender.h"

@protocol SLIMAPManagerDelegate <NSObject>

- (void)didGetMessages:(NSArray *)messages;

@end

@interface SLIMAPManager : NSObject
@property (nonatomic, assign) id<SLIMAPManagerDelegate> delegate;
@property (nonatomic, strong) MCOIMAPSession *session;
@property (nonatomic, strong) MCOIMAPMessage *message;
@property (nonatomic, strong) NSMutableArray *userFoldersMutableArray;
@property (nonatomic, strong) NSMutableDictionary *sendersMutableDictionary;
@property (nonatomic, strong) NSMutableSet *sendersNamesMutableSet;
@property (nonatomic, assign) MCOIMAPMessagesRequestKind messagesRequestKind;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *fetchMessagesOperation;

+ (SLIMAPManager *)sharedManager;
- (void)setupSharedManagerWithHostname:(NSString *)hostname port:(NSInteger)port;
- (void)loginWithUsername:(NSString *)username authToken:(NSString *)authToken;
- (void)getMessages;
- (void)sortMessagesBySender:(NSArray *)messages;
- (void)markMessages:(NSArray *)messages read:(BOOL)readFlag;

@end
