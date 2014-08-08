//
//  SLViewController.m
//  Mail iOS
//
//  Created by Kevin Nguy on 1/1/14.
//  Copyright (c) 2014 Kevin Nguy. All rights reserved.
//

#import "SLViewController.h"
#import "SLMessageViewController.h"
#import "SLCollectionViewCell.h"

#import "SLIMAPManager.h"
#import <GTMOAuth2ViewControllerTouch.h>

@interface SLViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, UIAlertViewDelegate, SLIMAPManagerDelegate>
@property (nonatomic, strong) UIView *popUpView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) MCOIMAPMessage *message;
@end

@implementation SLViewController

#define HOSTNAME @"imap.gmail.com"
#define PORT 993

#define MESSAGE_SEGUE @"MessageSegue"

static NSString *const kClientId = @"293978694811-ajeg5v894043t1j2gvntv4klka86353r.apps.googleusercontent.com";
static NSString *const kClientSecret = @"Bq1FxqN61Rd_TB6UECyPIWXi";
static NSString *const kOAuthKeychain = @"Sail OAuth Google";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self setupPopUpView];
    [self setupIMAP];
    [self setupOAuth];
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SLCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CollectionViewCellIdentifier"];
    
    // Grid View
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SLCollectionViewCell" owner:self options:nil];
    SLCollectionViewCell *collectionViewCell = nibArray.firstObject;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(CGRectGetWidth(collectionViewCell.frame), CGRectGetHeight(collectionViewCell.frame));
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = INT16_MAX;
    flowLayout.minimumLineSpacing = 20;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Add long press gesture recognizer
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    self.longPressGesture.minimumPressDuration = .5f;
    self.longPressGesture.delaysTouchesBegan = YES;
//    self.longPressGesture.delegate = self;
//    longPressGesture.cancelsTouchesInView = NO;
    [self.collectionView addGestureRecognizer:self.longPressGesture];
}

- (void)setupPopUpView {
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"SLCollectionViewCell" owner:self options:nil];
    SLCollectionViewCell *collectionViewCell = nibArray.firstObject;
    
    self.popUpView = [[UIView alloc] initWithFrame:collectionViewCell.frame];
    self.popUpView.backgroundColor = collectionViewCell.backgroundColor;
    
    UIView *circleView = [[UIView alloc] initWithFrame:collectionViewCell.frame];
    circleView.layer.cornerRadius = CGRectGetWidth(circleView.frame) / 2;
    circleView.backgroundColor = [UIColor redColor];
    
    [self.popUpView addSubview:circleView];
    
    self.popUpView.hidden = YES;
    [self.view addSubview:self.popUpView];
    
    // Add pan gesture recognizer
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesturePressed:)];
    self.panGesture.delegate = self;
    self.panGesture.cancelsTouchesInView = NO;
    self.panGesture.delaysTouchesBegan = YES;
//    [self.panGesture requireGestureRecognizerToFail:self.longPressGesture];
    [self.popUpView addGestureRecognizer:self.panGesture];
}

- (void)setupIMAP {
    [SLIMAPManager sharedManager];
    [[SLIMAPManager sharedManager] setupSharedManagerWithHostname:HOSTNAME port:PORT];
    [SLIMAPManager sharedManager].delegate = self;
}

- (void)setupOAuth {
    GTMOAuth2Authentication * auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kOAuthKeychain
                                                                                           clientID:kClientId
                                                                                       clientSecret:kClientSecret];
    
    if (auth.refreshToken) {
        [auth beginTokenFetchWithDelegate:self didFinishSelector:@selector(auth:finishedRefreshWithFetcher:error:)];
    } else {
        // Show OAuth view controller
        SLIMAPManager * __weak weakManager = [SLIMAPManager sharedManager];
        GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:@"https://mail.google.com/"
                                                                                                clientID:kClientId
                                                                                            clientSecret:kClientSecret
                                                                                        keychainItemName:kOAuthKeychain
                                                                                       completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *retrievedAuth, NSError *error) {
                                                                                           [weakManager loginWithUsername:auth.userEmail authToken:auth.accessToken];
                                                                                       }];
        
    }
}

- (void)auth:(GTMOAuth2Authentication *)auth finishedRefreshWithFetcher:(GTMHTTPFetcher *)fetcher error:(NSError *)error {
    [[SLIMAPManager sharedManager] loginWithUsername:auth.userEmail authToken:auth.accessToken];
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
            
            CGRect frame = self.popUpView.frame;
            frame.origin = point;
            self.popUpView.frame = frame;
            self.popUpView.hidden = NO;
            
            [UIView animateWithDuration:0.3f animations:^{
                cell.transform = CGAffineTransformMakeScale(0, 0);
                self.popUpView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL finished) {
                cell.hidden = YES;
                cell.transform = CGAffineTransformMakeScale(1, 1);
//                NSLog(@"%@", self.collectionView.gestureRecognizers.description);
//                [self.collectionView removeGestureRecognizer:self.collectionView.gestureRecognizers[1]];
            }];
        }
    }
}

- (void)panGesturePressed:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [sender velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(sender.view.center.x + (velocity.x * slideFactor),
                                         sender.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            sender.view.center = finalPoint;
        } completion:nil];
        
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:MESSAGE_SEGUE]) {
        SLMessageViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.message = self.message;
    }
}

#pragma mark - SLIMAPManagerDelegate
- (void)didGetMessages:(NSArray *)messages {
    // Sort messages
    [[SLIMAPManager sharedManager] sortMessagesBySender:messages];
    
    // Get senders from dictionary
    NSArray *senders = [[SLIMAPManager sharedManager].sendersMutableDictionary allValues];
    
    for (SLSender *sender in senders) {
        int unreadCount = sender.messages.count;
        for (MCOIMAPMessage *message in sender.messages) {
            if (message.flags == MCOMessageFlagSeen) {
                unreadCount--;
            }
        }

        NSLog(@"Sender: %40@  Messages: %d Unread:%d", sender.name, sender.messages.count, unreadCount);
        
        // Mark message if sender is NYTimes.com
        if ([sender.name isEqualToString:@"NYTimes.com"]) {
            [[SLIMAPManager sharedManager] markMessages:sender.messages read:YES];
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"\ngestureRecognizer: %@ \n\n otherGestureRecognizer: %@", gestureRecognizer.description, otherGestureRecognizer.description);
    NSLog(@"\n");

    BOOL flag = NO;
    
    if (gestureRecognizer == self.panGesture) {
        flag = YES;
    }
    
    return flag;
}


@end
