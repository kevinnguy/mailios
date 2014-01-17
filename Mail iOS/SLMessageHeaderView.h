//
//  SLMessageHeaderView.h
//  Mail iOS
//
//  Created by Kevin Nguy on 1/16/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLMessageHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *senderImageView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *addRecipientButton;
@property (weak, nonatomic) IBOutlet UIScrollView *recipientScrollView;

@end
