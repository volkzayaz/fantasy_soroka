//
//  TextsHistoryViewController.h
//  SBL
//
//  Created by Anatoliy Afanasev on 6/27/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextsHistoryViewModel;
@interface TextsHistoryViewController : UIViewController
@property (strong, nonatomic) TextsHistoryViewModel *viewModel;
@end
