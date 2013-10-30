//
//  SCSettingsViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 23.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCSettingsViewController.h"

@interface SCSettingsViewController ()

@end

@implementation SCSettingsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeModalView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
