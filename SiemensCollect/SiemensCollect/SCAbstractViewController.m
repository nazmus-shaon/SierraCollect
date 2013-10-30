//
//  SCAbstractViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 24.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"

@interface SCAbstractViewController ()

@end

@implementation SCAbstractViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *reco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(globalReco:)];
    [reco setNumberOfTouchesRequired:3];
    [self.view addGestureRecognizer:reco];
    
}

//- (void)globalReco:(UITapGestureRecognizer *)_tap {
//    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
//    overlay.detailViewMode = MTDetailViewModeHistory;
//    [overlay postMessage:[NSString stringWithFormat:@"%@", [[SCAppCore shared] demoMode] ? @"Live-Mode" : @"Demo-Mode"]];
//    [[SCAppCore shared] setDemoMode:![[SCAppCore shared] demoMode]];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
