//
//  SCAbstractTableViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractTableViewController.h"

@interface SCAbstractTableViewController ()

@end

@implementation SCAbstractTableViewController

- (void)showLoadingScreen {
    if (loadingView == nil) {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [loadingView setBackgroundColor:[UIColor darkGrayColor]];
        [loadingView setAlpha:0];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setCenter:CGPointMake((self.view.frame.size.width/2) - 80, self.view.frame.size.height/2)];
        //[activityIndicator setFrame:CGRectMake(20, (self.view.frame.size.height-activityIndicator.frame.size.height)/2, activityIndicator.frame.size.width, activityIndicator.frame.size.height)];
        
        [loadingView addSubview:activityIndicator];
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [loadingLabel setBackgroundColor:[UIColor clearColor]];
        [loadingLabel setText:@"Loading..."];
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [loadingView addSubview:loadingLabel];
    }
    
    [activityIndicator startAnimating];
    [self.view addSubview:loadingView];
    [UIView animateWithDuration:0.5 animations:^{
        [loadingView setAlpha:0.9];
    }];
}

- (void)hideLoadingScreen {
    [UIView animateWithDuration:0.5 animations:^{
        [loadingView setAlpha:0];
    } completion:^(BOOL finished) {
        [loadingView removeFromSuperview];
        [activityIndicator stopAnimating];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


@end
