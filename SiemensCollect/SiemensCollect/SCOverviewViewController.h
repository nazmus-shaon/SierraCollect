//
//  SCOverviewViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import "SCPdfPreviewCell.h"
#import "SCDetailViewController.h"
#import "SCDataService.h"
#import "MFSideMenuContainerViewController.h"

@interface SCOverviewViewController : SCAbstractViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray *storedPDFs;
}
@property (weak, nonatomic) IBOutlet UICollectionView *pdfCollectionView;
@property STBuilding *building;

@end
