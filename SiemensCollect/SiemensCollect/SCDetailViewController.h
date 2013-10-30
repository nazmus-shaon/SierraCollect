//
//  SCDetailViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 17.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPopOverOverviewViewControllerDelegate.h"
#import <MapBox/MapBox.h>
#import "SCPopOverViewController.h"
#import "SCDataService.h"
#import "SCHeatMapViewController.h"
#import "SCPopOverNavigationViewController.h"
#import "SCPopOverOverviewViewController.h"


@interface SCDetailViewController : SCAbstractViewController <UIAlertViewDelegate, RMMapViewDelegate, UIPopoverControllerDelegate, SCPopOverOverviewViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapContainerView;

@property (strong, nonatomic) STFloor *floorPlan;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectedMode;
@property (weak, nonatomic) IBOutlet UISegmentedControl *drawingMode;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *startRoute;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (nonatomic, strong) UIPopoverController *detailViewPopover;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)startNewRouteClicked:(id)sender;
@end
