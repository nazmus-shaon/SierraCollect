//
//  SCMenuViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 24.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "SCDataService.h"
#import "SCOverviewViewController.h"

typedef enum {
    SCMenuViewControllerCountry = 0,
    SCMenuViewControllerCity = 1,
    SCMenuViewControllerArea = 2,
    SCMenuViewControllerBuilding = 3
} SCMenuViewControllerKind;

@interface SCMenuViewController : SCAbstractViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) SCMenuViewControllerKind menuKind;

@property (strong, nonatomic) NSArray *data;

@end
