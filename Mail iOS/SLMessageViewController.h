//
//  SLMessageViewController.h
//  Mail iOS
//
//  Created by Kevin Nguy on 1/16/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCOMessageView.h"

@interface SLMessageViewController : UIViewController
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPMessage *message;

@property (weak, nonatomic) IBOutlet UIView *messageTitleView;
@property (weak, nonatomic) IBOutlet UILabel *messageTitleLabel;
@property (weak, nonatomic) IBOutlet MCOMessageView *messageView;


@end
