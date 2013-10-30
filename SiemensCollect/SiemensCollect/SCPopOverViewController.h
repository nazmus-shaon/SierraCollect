//
//  SCPopOverViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 13.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "STImageCaptureViewController.h"
#import "STImageCaptureDelegate.h"
#import "SCWebDAVService.h"

//#define USING_GIST

@class SBJsonStreamParser;
@class SBJsonStreamParserAdapter;

@interface SCPopOverViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, STImageCaptureDelegate>
{    
    SBJsonStreamParser *parser;
    SBJsonStreamParserAdapter *adapter;
    
    NSMutableArray *wifiSensorArray;
    NSMutableArray *otherSensorArray;
    
    STImageCaptureViewController *imageCont;
}

@property (weak, nonatomic) IBOutlet UIView *headerView;

- (IBAction)photoButtonClicked:(id)sender;
//- (IBAction)deletePoint:(id)sender;
- (IBAction)refetchData:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) RKManagedObjectStore *managedObjectStore;
@property (strong, nonatomic) RKObjectManager *objectManager;

//@property (strong, nonatomic) STPoint *point;
@property (strong, nonatomic) STSensorPoint *sensorPoint;

@property (strong, nonatomic) IBOutlet UIScrollView *pictureScrollView;


@end

