//
//  SCHeatMapViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 02.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import "STHeatmap.h"
#import "STHeatmapPoint.h"
#import <MessageUI/MessageUI.h>
#import "SCHeatMapSettingsViewController.h"
#import "SCWebDAVService.h"
#import "SCHeatMapLegendView.h"
#import "SCHeatMapDateOptionView.h"

@interface SCHeatMapViewController : SCAbstractViewController <STHeatmapDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, SCHeatMapSettingsViewControllerDelegate> {
    STHeatmap *heatmap;
    
    NSMutableArray *heatpoints;

    UIImageView *mapImageView;
    UIImageView *heatMapImageView;

    IBOutlet UIView *loadingView;
    IBOutlet UIActivityIndicatorView *loadingActivity;
    IBOutlet UILabel *loadingLabel;
    
    UIImage *generatedHeatImage;
    
    MFMailComposeViewController *mailCont;
    
    NSDictionary *infoDict;
    
    BOOL newGeneratedHeatMap;
    
    SCHeatMapLegendView *heatMapLegend;
    SCHeatMapDateOptionView *heatMapDateOption;
}

- (IBAction)exportHeatMap:(id)sender;
- (IBAction)goToSettings:(id)sender;
- (IBAction)saveHeatMap:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *exportBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@property (strong, nonatomic) STFloor *floorPlan;
//@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
