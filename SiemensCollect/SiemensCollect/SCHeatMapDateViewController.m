//
//  SCHeatMapDateViewController.m
//  SiemensCollect
//
//  Created by Nazmus Shaon on 21/11/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCHeatMapDateViewController.h"

@interface SCHeatMapDateViewController () {
    NSMutableDictionary *mSettings;
}
@end

@implementation SCHeatMapDateViewController

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
    
    // Initialization code
    mSettings = [NSMutableDictionary dictionaryWithDictionary:_settings];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"right_menu_bg.png"]];
    [self.view setBackgroundColor:background];
    
    float width_button = 100.0;
    float height_button = 30.0;
    
    float padding_top = 8.0;
    
    UIScrollView *dateOptionView = [[UIScrollView alloc] init];
    [dateOptionView setBackgroundColor:[UIColor clearColor]];
    
    NSInteger viewcount= _collectedDates.count;
    for(int i = 0; i< viewcount; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        [button addTarget:self
                   action:@selector(dateButtonClicked:)
         forControlEvents:UIControlEventTouchDown];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        /*NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[collectedDates objectAtIndex:i]];
         NSInteger day = [dateComponents day];
         NSInteger month = [dateComponents month];
         NSInteger year = [dateComponents year];*/
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = gregorian;
        formatter.dateFormat = @"dd MMM yy";
        
        NSString *formattedDate = [formatter stringFromDate:[_collectedDates objectAtIndex:i]];
        
        [button setTitle:formattedDate forState:UIControlStateNormal];
        button.frame = CGRectMake(0.0, i *(height_button+padding_top), width_button, height_button);
        [[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        if ([self isSameDay:(NSDate *)[_collectedDates objectAtIndex:i] otherDay:_heatmapDate]) {
            [button setBackgroundImage:[UIImage imageNamed:@"right_menu_blue_button.png"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:[UIImage imageNamed:@"right_menu_white_button.png"] forState:UIControlStateNormal];
        }
        [dateOptionView addSubview:button];
    }
    
    dateOptionView.contentSize = CGSizeMake(self.view.frame.size.width, (viewcount+1) *(height_button+padding_top));
    
    [dateOptionView setFrame:CGRectMake(0, 39,100,206)];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, dateOptionView.frame.size.width, 300)];
    
    [self.view.layer setCornerRadius:4];
    [self.view.layer setMasksToBounds:YES];
    //self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    //self.layer.borderWidth = 1.0f;
    
    [self.view addSubview:dateOptionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (IBAction)dateButtonClicked:(id)sender {
    NSDate *toDate = (NSDate *)[_collectedDates objectAtIndex:[(UIButton *)sender tag]];
    [mSettings setValue:toDate forKey:@"SCHeatMapSettingsTime"];
    [self.delegate heatmapWithSettings:mSettings];
}

@end
