//
//  SLIMAPManager.m
//  Mail iOS
//
//  Created by Kevin Nguy on 1/16/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import "SLIMAPManager.h"

@implementation SLIMAPManager

static SLIMAPManager *sharedManager = nil;

+ (SLIMAPManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)setupSharedManagerWithHostname:(NSString *)hostname port:(NSInteger)port {
    self.session = [[MCOIMAPSession alloc] init];
    self.session.hostname = hostname;
    self.session.port = port;
    self.session.connectionType = MCOConnectionTypeTLS;  /** Encrypted connection using TLS/SSL.*/
    self.userFolders = [@[@"INBOX"] mutableCopy];
    self.messagesRequestKind = (MCOIMAPMessagesRequestKind)
	(MCOIMAPMessagesRequestKindExtraHeaders | MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindFullHeaders | MCOIMAPMessagesRequestKindGmailLabels | MCOIMAPMessagesRequestKindGmailMessageID | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindSize | MCOIMAPMessagesRequestKindStructure | MCOIMAPMessagesRequestKindUid);
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    self.session.username = username;
    self.session.password = password;
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]; // Get all messages
    self.fetchMessagesOperation = [self.session fetchMessagesByUIDOperationWithFolder:self.userFolders.firstObject requestKind:self.messagesRequestKind uids:uids];
    [self getMessages];
}

- (void)getMessages {
    [self.fetchMessagesOperation setProgress:^(unsigned int progress) {
        NSLog(@"Progress: %u of total messages", progress);
    }];
    
    __weak SLIMAPManager *weakSelf = self;
    [self.fetchMessagesOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        //Let's check if there was an error:
        if(error) {
            NSLog(@"Error downloading message headers:%@", error);
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
        messages = [messages sortedArrayUsingDescriptors:@[sort]];
        
        if (messages.count) {
            [weakSelf.delegate didGetMessages:messages];
            //            message.uid;
            //            message.size;
            //            message.gmailLabels;
            //            message.gmailMessageID;
            //            message.gmailThreadID;
            //            message.header.messageID;
            //            message.header.references;
            //            message.header.inReplyTo;
            //            message.header.sender;
            //            message.header.from;
            //            message.header.to;
            //            message.header.cc;
            //            message.header.bcc;
            //            message.header.replyTo;
            //            message.header.subject;
            //            message.header.date;
            //            message.header.receivedDate;
            //            message.mainPart;
        }
    }];
}
@end
