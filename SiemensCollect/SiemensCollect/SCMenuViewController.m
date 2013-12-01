//
//  SCMenuViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 24.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCMenuViewController.h"

@interface SCMenuViewController ()

@end

@implementation SCMenuViewController




- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    if (_menuKind == SCMenuViewControllerCountry) {
        header = @"Countries";
    } else if (_menuKind == SCMenuViewControllerCity) {
        header = @"Cities";
    } else if (_menuKind == SCMenuViewControllerArea) {
        header = @"Areas";
    } else if (_menuKind == SCMenuViewControllerBuilding) {
        header = @"Buildings"; 
    }
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[_data objectAtIndex:indexPath.row] name]];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_menuKind == SCMenuViewControllerCountry) {
        SCMenuViewController *demo = [self.storyboard instantiateViewControllerWithIdentifier:@"lefterMenuCont"];
        demo.title = [[_data objectAtIndex:indexPath.row] name];
        [demo setData:[[SCDataService shared] getCitiesForCountry:[_data objectAtIndex:indexPath.row]]];
        [demo setMenuKind:SCMenuViewControllerCity];
        [self.navigationController pushViewController:demo animated:YES];
        
    } else if (_menuKind == SCMenuViewControllerCity) {
        SCMenuViewController *demo = [self.storyboard instantiateViewControllerWithIdentifier:@"lefterMenuCont"];
        demo.title = [[_data objectAtIndex:indexPath.row] name];
        [demo setData:[[SCDataService shared] getAreasForCity:[_data objectAtIndex:indexPath.row]]];
        [demo setMenuKind:SCMenuViewControllerArea];
        [self.navigationController pushViewController:demo animated:YES];
        
    } else if (_menuKind == SCMenuViewControllerArea) {
        SCMenuViewController *demo = [self.storyboard instantiateViewControllerWithIdentifier:@"lefterMenuCont"];
        demo.title = [[_data objectAtIndex:indexPath.row] name];
        [demo setData:[[SCDataService shared] getBuildingsForArea:[_data objectAtIndex:indexPath.row]]];
        [demo setMenuKind:SCMenuViewControllerBuilding];
        [self.navigationController pushViewController:demo animated:YES];
        
    } else if (_menuKind == SCMenuViewControllerBuilding) {
        SCOverviewViewController *overviewController = [self.storyboard instantiateViewControllerWithIdentifier:@"overviewController"];
        overviewController.building = [_data objectAtIndex:indexPath.row];
        overviewController.title = [NSString stringWithFormat:@"Floorplans in %@",[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        [navigationController pushViewController:overviewController animated:YES];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
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

@end
