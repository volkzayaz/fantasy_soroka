//
//  TextsHistoryViewController.m
//  SBL
//
//  Created by Anatoliy Afanasev on 6/27/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

#import "TextsHistoryViewController.h"
#import "GHMViewControllerProtocol.h"

///views
#import "SLKTextInputbar.h"
#import "SLKTextView.h"
#import "TextMessageCell.h"
#import "TipView.h"

///view model
#import "TextsHistoryViewModel.h"
#import "TextsAttachmentViewModel.h"

///data
#import "TextsHistoryDataSource.h"

///libraries
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Grasshopper-Swift.h"

///model
#import "GHMessageObject.h"

///categories
#import "RACStream+Utils.h"
#import "UIColor+AppColors.h"
#import "UITableView+TextsHistory.h"
#import "UIView+ProgressIndicator.h"
#import "UIImage+Rescale.h"
#import "UIImage+AppImages.h"
#import "UIFont+AppFont.h"
#import "UIButton+Inspectable.h"

@interface TextsHistoryViewController ()<GHMViewControllerProtocol, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIDocumentMenuDelegate>

///IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet SLKTextInputbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;

///Activity indicator
@property (nonatomic, strong) UIRefreshControl *activity;

///tips
@property (nonatomic, weak) TipView* tip;
@end

@implementation TextsHistoryViewController

#pragma mark - View LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    
    @weakify(self);
    [[RACObserve(self.viewModel, scrollToBottom)
      .notNil
      filter:^BOOL(NSNumber *value) { return value.boolValue; }]
     subscribeNext:^(id _) {
         @strongify(self);
         [self scrollTableView:NO];
     }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize tipViewSize = self.view.bounds.size;
    tipViewSize.width -= 50;
    tipViewSize.height = 70;
    
    self.tip.frame = CGRectMake(0, 0, tipViewSize.width, tipViewSize.height);
    
    CGFloat offset = CGRectGetHeight(self.tableView.bounds) - CGRectGetHeight(self.toolbar.bounds) - self.tip.frame.size.height / 2;
    
    self.tip.center = CGPointMake(self.view.center.x, offset);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.viewModel.isMMSEnabled) {
        [self.tip showOnce];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.movingFromParentViewController) {
        [self.viewModel markAsRead];
    }
}


#pragma mark - Setup

- (void)setupActivityIndicator {
    ///Activity indicator preparation
    self.activity = UIRefreshControl.new;
    self.activity.backgroundColor = [UIColor clearColor];
    self.activity.tintColor = [UIColor ghPrimaryGreen];
    [self.activity addTarget:self
                      action:@selector(loadMoreData)
            forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.activity];
    
    @weakify(self);
    [[RACObserve(self.viewModel, loadMoreProgressAnimation)
      .notNil
      filter:^BOOL(NSNumber *value) { return !value.boolValue; }]
     .deliverOnMainThread
     subscribeNext:^(NSNumber *x) {
         @strongify(self);
         [self.activity endRefreshing];
     }];
}

- (void)setupNavigationBarItem{
    if (self.viewModel.isGroupMessage) {
        
        UIButton *infoButton =
        [UIButton buttonWithType:UIButtonTypeInfoLight];
        infoButton.ghButtonColorType = 5;
        [infoButton addTarget:self
                       action:@selector(navigateToDetail:)
             forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *navBarItem =
        [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        
        self.navigationItem.rightBarButtonItem = navBarItem;
    }
}

- (void)setup {
    [self setupKeyboardObserving];
    [self setupToolbar];
    [self setupActivityIndicator];
    [self setupNavigationBarItem];
    [self setupTip];
    
    ///configure table view
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TextMessageCell" bundle:nil]
         forCellReuseIdentifier:TextMessageCell.myCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextMessageCell" bundle:nil]
         forCellReuseIdentifier:TextMessageCell.otherCellId];
    
    [self.tableView prepare];
    self.viewModel.dataSource.tableView = self.tableView;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 24;
    
    ///configure table view
    RAC(self.navigationItem, title) =
    RACObserve(self.viewModel, conversationName);
    
    ///spinner binding
    self.tableView.bindIndicatorProgresTo =
    RACObserve(self.viewModel, progressAnimation);
    
    ///data binding
    
    @weakify(self);
    [[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(id x) {
         @strongify(self);
         [self.viewModel updateList];
     }];
    
    [self.viewModel initialCacheLoad];
    
    [self.viewModel.updateSignal
     subscribeNext:^(id x) {
         @strongify(self);
         [self.tableView reloadData];
     }];
    
}

- (void)setupKeyboardObserving {
    @weakify(self);
    [[[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     deliverOnMainThread]
     subscribeNext:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
         
         if (CGRectIsNull(keyboardEndFrame)) {
             return;
         }
         
         UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
         NSInteger animationCurveOption = (animationCurve << 16);
         double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
         
         @strongify(self);
         [UIView animateWithDuration:animationDuration
                               delay:0.0
                             options:animationCurveOption
                          animations:^{
                              UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, CGRectGetHeight(keyboardEndFrame), 0.0f);
                              self.tableView.contentInset = insets;
                              self.tableView.scrollIndicatorInsets = insets;
                          } completion:nil];
     }];
}

- (void)setupToolbar {
    
    [self.toolbar setShadowImage:UIColor.ghBackground1.image
              forToolbarPosition:UIBarPositionAny];
    
    [self.toolbar setBackgroundImage:UIImage.new
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    
    self.toolbar.barTintColor = [UIColor ghWhite];
    self.toolbar.autoHideRightButton = NO;
    self.toolbar.maxCharCount = 0;
    self.toolbar.counterStyle = SLKCounterStyleSplit;
    
    [self.toolbar.leftButton setTintColor:UIColor.ghBlue];
    
    [self.toolbar.rightButton setTitle:nil forState:UIControlStateNormal];
    [self.toolbar.rightButton setTitle:nil forState:UIControlStateDisabled];
    
    [self.toolbar.rightButton setBackgroundImage:[UIImage imageNamed:@"send"]
                                        forState:UIControlStateNormal];
    [self.toolbar.rightButton setBackgroundImage:[UIImage imageNamed:@"disabled send"]
                                        forState:UIControlStateDisabled];
    
    self.toolbar.textView.textColor = [UIColor ghPrimaryTextGray];
    self.toolbar.textView.layer.cornerRadius = self.toolbar.textView.bounds.size.height / 2;
    self.toolbar.textView.layer.borderColor = [UIColor ghBackground1].CGColor;
    self.toolbar.textView.placeholder = NSLocalizedString(@"Type a message...", nil);
    self.toolbar.textView.placeholderColor = [UIColor ghSecondaryTextGray];
    self.toolbar.textView.delegate = self;
    self.toolbar.textView.tintColor = [UIColor ghPrimaryGreen];
    self.toolbar.textView.font = [UIFont ghText16];
    
    self.toolbar.leftButton.hidden = NO;
    
    [self.toolbar removeFromSuperview];
    
    @weakify(self);
    [[[[NSNotificationCenter.defaultCenter rac_addObserverForName:SLKTextViewContentSizeDidChangeNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self);
         if (self.toolbar.appropriateHeight != self.toolbarHeightConstraint.constant) {
             self.toolbarHeightConstraint.constant = self.toolbar.appropriateHeight;
             
             @weakify(self);
             [UIView animateWithDuration:0.1f
                                   delay:0.0
                                 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                              animations:^{
                                  @strongify(self);
                                  [self.toolbar layoutIfNeeded];
                              }
                              completion:nil];
         }
     }];
    
    
    [[[[self.toolbar.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     takeUntil:self.rac_willDeallocSignal]
    deliverOnMainThread]
     subscribeNext:^(UIButton *x) {
         @strongify(self);
         
         id attachment = self.viewModel.attachmentViewModel.attachments.firstObject;
         GHMessageObject *message = nil;
        if ([attachment isKindOfClass:[UIImage class]]){
             message = [[GHMessageObject alloc]initWithText:self.toolbar.textView.text image:attachment];
         } else if ([attachment isKindOfClass:[NSURL class]]){
             message = [[GHMessageObject alloc]initWithText:self.toolbar.textView.text fileURL:attachment];
         } else {
             message = [[GHMessageObject alloc]initWithText:self.toolbar.textView.text];
         }

         self.toolbar.rightButton.enabled = NO;
         self.toolbar.userInteractionEnabled = NO;

         @weakify(self);
         [[self.viewModel send:message]
          .deliverOnMainThread
          subscribeNext:^(GHMessageModel *x) {
              @strongify(self);
              [self.viewModel.attachmentViewModel.attachments removeAllObjects];
              [self.tableView reloadData];
              [self.toolbar reset];
              self.toolbar.userInteractionEnabled = YES;
              [self scrollTableView:NO];
          } error:^(NSError *error) {
              @strongify(self);
              self.toolbar.rightButton.enabled = YES;
              self.toolbar.userInteractionEnabled = YES;
          }];
     }];

    RACSignal *textSignal =
    [self.toolbar.textView.rac_textSignal merge:
     RACObserve(self.toolbar.textView, text)];

    RAC(self.toolbar.rightButton, enabled) =
    [[[[RACSignal combineLatest:@[textSignal, RACObserve(self.toolbar, hasMediaAttachment)]]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     map:^id(RACTuple *value) {
         NSNumber *b = [NSNumber numberWithBool:[value.first length] > 0 || [value.last boolValue]];
         return b;
     }];
    
    [RACObserve(self.toolbar, hasMediaAttachment)
     subscribeNext:^(id x) {
        @strongify(self);
        if (![x boolValue] && self.viewModel.attachmentViewModel.attachments.count > 0){
            [self.viewModel.attachmentViewModel.attachments removeLastObject];
        }
    }];
    
    [[self.toolbar.leftButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton *x) {
         @strongify(self);
         [self.viewModel.attachmentViewModel showAttachmentOptions];
     }];
    
    [[[RACObserve(self.viewModel, isMMSEnabled)
     takeUntil:self.rac_willDeallocSignal]
    deliverOnMainThread]
     subscribeNext:^(id x) {
         
         @strongify(self);
         
         if (![x boolValue]) {
             
             [self.toolbar.leftButton setImage:nil forState:UIControlStateNormal];
             
         } else {
             
             [self.toolbar.leftButton setImage:[UIImage imageNamed:@"icon - attach file"]
                                      forState:UIControlStateNormal];
             self.toolbar.leftButton.tintColor = [UIColor ghBlue];
             
         }
     }];
    
    [[[RACObserve(self.viewModel.attachmentViewModel, routActionData)
       takeUntil:self.rac_willDeallocSignal]
      .notNil
      deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self);
         if ([x isKindOfClass:[UIImagePickerController class]]){
             UIImagePickerController *imagePicker = x;
             imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
             imagePicker.delegate = self;
         } else if ([x isKindOfClass:[UIDocumentMenuViewController class]]){
             UIDocumentMenuViewController *menuPicker = x;
             menuPicker.delegate = self;
         }
         
         [self.toolbar.textView resignFirstResponder];
         [self presentViewController:x
                            animated:YES
                          completion:NULL];
     }];
    
    [RACObserve(self.viewModel.attachmentViewModel, lastTakenPhoto)
     .notNil
     subscribeNext:^(id x) {
         @strongify(self);
         [self.viewModel.attachmentViewModel addTextInputBarWithAttachment:x];
     }];
    
    [self.viewModel.attachmentViewModel setToolbar:self.toolbar];
    
}

- (void)setupTip {
    TipView *tv =
    [TipView tipViewWithFirstLine:NSLocalizedString(@"Now you can send photos and videos", nil)
                       secondLine:nil
                         position:TipViewTrianglePositionBottom];
    
    tv.tipIdentifier = @"com.grasshopper.tips.mediaAttachment";
    tv.hidden = YES;
    tv.baseTriangleVertexPoint = 30;
    
    [self.view addSubview:tv];
    
    self.tip = tv;
}

#pragma mark - Input

- (UIView *)inputAccessoryView {
    return self.toolbar;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self scrollTableView:NO];
}


#pragma mark - Common

- (void)loadMoreData {
    [self.viewModel loadMoreTextsMessages];
}

- (void)scrollTableView:(BOOL)animated {
    NSInteger sections = [self.tableView numberOfSections] - 1;
    if (sections >= 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:sections] - 1
                                               inSection:sections];
        [self.tableView scrollToRowAtIndexPath:path
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark - Actions

- (IBAction)callClick:(id)sender {
    
    [self.viewModel performCall];
}

- (IBAction)cancelClick:(id)sender {
    [self.toolbar.textView resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segue

- (IBAction)navigateToDetail:(id)sender {
    [self.viewModel showGroupDetails];
}

#pragma mark - Image Picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.toolbar.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.viewModel.attachmentViewModel addTextInputBarWithAttachment:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    self.toolbar.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Document Menu Delegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url {
    ///empty so far
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu
didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
    documentPicker.delegate = self.viewModel.attachmentViewModel;
    [self presentViewController:documentPicker
                       animated:YES
                     completion:nil];
}

@end
