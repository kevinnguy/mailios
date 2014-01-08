//
//  SLViewController.m
//  Mail iOS
//
//  Created by Kevin Nguy on 1/1/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import "SLViewController.h"

#import "SLCollectionViewCell.h"

@interface SLViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@end

@implementation SLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self setupGestureRecognizer];
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // Grid View
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SLCollectionViewCell" owner:self options:nil];
    SLCollectionViewCell *collectionViewCell = nibArray.firstObject;
    
    flowLayout.itemSize = CGSizeMake(CGRectGetWidth(collectionViewCell.frame), CGRectGetHeight(collectionViewCell.frame));
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = INT16_MAX;
    flowLayout.minimumLineSpacing = 20;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SLCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CollectionViewCellIdentifier"];
}

- (void)setupGestureRecognizer {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressGesture.minimumPressDuration = .5f;
    longPressGesture.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPressGesture];
}

- (void)longPressed:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:self.collectionView];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            // get the cell at indexPath (the one you long pressed)
            SLCollectionViewCell *cell = (SLCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            // Center point of touch
            point.x -= CGRectGetWidth(cell.frame) / 2;
            point.y -= CGRectGetHeight(cell.frame) / 2;
            
            CGRect frame;
            frame.origin = point;
            frame.size = CGSizeMake(CGRectGetWidth(cell.frame), CGRectGetHeight(cell.frame));
            
            UIView *view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = cell.backgroundColor;
            
            frame.origin = CGPointMake(0, 0);
            
            UIView *circleView = [[UIView alloc] initWithFrame:frame];
            circleView.layer.cornerRadius = CGRectGetWidth(circleView.frame) / 2;
            circleView.backgroundColor = [UIColor redColor];
            
            [view addSubview:circleView];
            [self.view addSubview:view];
            
            [UIView animateWithDuration:0.3f animations:^{
                cell.transform = CGAffineTransformMakeScale(0, 0);
                view.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL finished) {
                cell.hidden = YES;
                cell.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }
    }
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Collection view datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellIdentifier" forIndexPath:indexPath];
    
    if (indexPath.section == 1) {
        cell.circleView.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}


@end
