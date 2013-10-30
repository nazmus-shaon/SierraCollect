//
//  SCGraphViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 04.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import "PlotItem.h"
#import "CurvedScatterPlot.h"
#import "DatePlot.h"
#import "SCGraphPickerViewController.h"

#define month (30 * 24 * 60 * 60)
#define day (24 * 60 * 60)
#define hour (60 * 60)
#define munite (60)

@interface SCGraphViewController : SCAbstractViewController<SCGraphPickerViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *sensorPoints;
@property (strong, nonatomic) NSMutableArray *graphData;

//@property (strong, nonatomic) CurvedScatterPlot *plotItem;
@property (strong, nonatomic) DatePlot *plotItem;

@property (strong, nonatomic) IBOutlet UIView *mainGraphView;

- (IBAction)closeModal:(id)sender;

@end
