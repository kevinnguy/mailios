//
//  SLCollectionViewCell.m
//  Mail iOS
//
//  Created by Kevin Nguy on 1/8/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import "SLCollectionViewCell.h"

@implementation SLCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.circleView.layer.cornerRadius = CGRectGetWidth(self.circleView.frame) / 2;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
