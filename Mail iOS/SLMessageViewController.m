//
//  SLMessageViewController.m
//  Mail iOS
//
//  Created by Kevin Nguy on 1/16/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import "SLMessageViewController.h"

@interface SLMessageViewController ()

@end

@implementation SLMessageViewController

- (void)viewDidLoad {
    [self setupTitleView];
}

- (void)setupTitleView {
    self.messageTitleLabel.text = self.message.header.subject;
}
@end
