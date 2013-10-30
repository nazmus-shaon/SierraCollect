//
//  SCMainViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 24.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "SCLatestRecordView.h"
#import "SCDataService.h"
#import "SCNewsView.h"
#import "SCDetailViewController.h"
#import "SCSyncViewController.h"

@interface SCMainViewController : SCAbstractViewController <SCLatestRecordViewDelegate, SCSyncViewControllerDelegate, UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *wifiLabel;
@property (weak, nonatomic) IBOutlet UILabel *brightnessLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
- (IBAction)refreshInformation:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;

@property (weak, nonatomic) IBOutlet UIScrollView *latesRecordSrollView;
- (IBAction)showLeftMenu:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *demoSegment;

- (IBAction)uploadToWebDAV:(id)sender;

@end
