//
//  SCAbstractTableViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCAbstractTableViewController : UITableViewController {
    UIView  *loadingView;
    UIActivityIndicatorView *activityIndicator;
}

- (void)showLoadingScreen;
- (void)hideLoadingScreen;

@end
