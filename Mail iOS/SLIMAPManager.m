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
    self.userFoldersMutableArray = [@[@"INBOX"] mutableCopy];
    self.messagesRequestKind = (MCOIMAPMessagesRequestKind)
	(MCOIMAPMessagesRequestKindExtraHeaders | MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindFullHeaders | MCOIMAPMessagesRequestKindGmailLabels | MCOIMAPMessagesRequestKindGmailMessageID | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindHeaderSubject | MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindSize | MCOIMAPMessagesRequestKindStructure | MCOIMAPMessagesRequestKindUid);
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    self.session.username = username;
    self.session.password = password;
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)]; // Get all messages
    self.fetchMessagesOperation = [self.session fetchMessagesByUIDOperationWithFolder:self.userFoldersMutableArray.firstObject requestKind:self.messagesRequestKind uids:uids];
    [self getMessages];
}

- (void)getMessages {
//    [self.fetchMessagesOperation setProgress:^(unsigned int progress) {
//        NSLog(@"Progress: %u of total messages", progress);
//    }];
    
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

- (void)sortMessagesBySender:(NSArray *)messages {
    if (!self.sendersMutableDictionary) {
        self.sendersMutableDictionary = [NSMutableDictionary new];
    }
    
    if (!self.sendersNamesMutableSet) {
        self.sendersNamesMutableSet = [NSMutableSet new];
    }
    
    for (MCOAbstractMessage *message in messages) {
        // Example: Bank of America
        NSString *displayName = message.header.from.displayName;
        if (!displayName) {
            // Example: alert@bankofamerica.com
            displayName = message.header.from.mailbox;
        }
        
        if ([self.sendersNamesMutableSet containsObject:displayName]) {
            SLSender *sender = [self.sendersMutableDictionary objectForKey:displayName];
            [sender.messages addObject:message];
        } else {
            [self.sendersNamesMutableSet addObject:displayName];
            SLSender *sender = [[SLSender alloc] initWithName:displayName message:message];
            [self.sendersMutableDictionary setObject:sender forKey:displayName];
        }
    }
}
@end
