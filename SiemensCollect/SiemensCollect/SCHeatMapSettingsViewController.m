//
//  SCHeatMapSettingsViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 09.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCHeatMapSettingsViewController.h"

@interface SCHeatMapSettingsViewController () {
    NSArray *sectionsArray;
    NSArray *dataArray;
    
    NSIndexPath *selectedIndexPath;
}
@end

@implementation SCHeatMapSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)setDataForWifis:(NSArray *)_wifi forSensors:(NSArray *)_sensors forStoredHeatMaps:(NSArray *)_heatMaps {
    self.availableWifis = _wifi;
    self.availableSensors = _sensors;
    self.storedHeatMaps = _heatMaps;
    selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    sectionsArray = [NSArray arrayWithObjects:@"Sensors", @"Wifis", @"Stored Heatmaps",  nil];
    
    //EDIT NAMING OF STORED HEATMAPS
    self.storedHeatMapsNiceNaming = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy - hh:mm:ss"];
    for (NSString *str in self.storedHeatMaps) {
        NSString *editStr;
        editStr = [[str stringByReplacingOccurrencesOfString:@".png" withString:@""] stringByReplacingOccurrencesOfString:@"heatmap_" withString:@""];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[editStr substringFromIndex:([editStr length] - 17)].doubleValue];
        editStr = [[editStr substringToIndex:([editStr length] - 18)] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        [self.storedHeatMapsNiceNaming addObject:[NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:date], editStr]];
    }
    
    dataArray = [NSArray arrayWithObjects:self.availableSensors, self.availableWifis, self.storedHeatMapsNiceNaming, nil];
}

#pragma mark Application Flow

- (IBAction)closeModal:(id)sender {
    NSLog(@"close modal");
    [self.delegate dismissController:self];
}

- (IBAction)goGenerateHeatMap:(id)sender {
    NSLog(@"Go Generate HeatMap");
    if (self.availableSensors.count == 0 && self.availableWifis.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There's no Data available so we cannot create a Meatmap" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        NSArray *valueArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:_resoultionSlider.value], [NSNumber numberWithInt:[selectedIndexPath section]], [[dataArray objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row], nil];
        NSArray *keyArray = [NSArray arrayWithObjects:SCHeatMapSettingsResolution, SCHeatMapSettingsType, SCHeatMapSettingsValue, nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
        [self.delegate closedController:self withSettings:dict];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionsArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return sectionsArray[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[dataArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"heatMapTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    if (selectedIndexPath.section == indexPath.section && selectedIndexPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell.textLabel setText:[[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark UiTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {}
        case 1: {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            selectedIndexPath = indexPath;
            [tableView reloadData];
            break;
        } case 2: {
            NSLog(@"Heatmaps clicked at row: %i", indexPath.row);
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.storedHeatMapsNiceNaming objectAtIndex:indexPath.row], nil] forKeys:[NSArray arrayWithObjects:SCHeatMapSettingsValue, nil]];
            [self.delegate closedController:self withSettings:dict andReadyHeatMap:[self.storedHeatMaps objectAtIndex:indexPath.row]];
        }
        default:
            break;
    }
    
}
@end
