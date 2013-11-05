//
//  SCHeatMapDateOptionView.m
//  SiemensCollect
//
//  Created by Nazmus Shaon on 04/11/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCHeatMapDateOptionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SCHeatMapDateOptionView

- (id)initWithFrame:(CGRect)frame dateList:(NSMutableArray *)collectedDates selectedDate:(NSDate *)heatmapDate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"right_menu_bg.png"]];
        [self setBackgroundColor:background];
        
        float width_button = 100.0;
        float height_button = 30.0;
        
        float padding_top = 8.0;

        UIScrollView *dateOptionView = [[UIScrollView alloc] init];
        [dateOptionView setBackgroundColor:[UIColor clearColor]];
        
        NSInteger viewcount= collectedDates.count;
        for(int i = 0; i< viewcount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self
                       action:nil
             forControlEvents:UIControlEventTouchDown];
            
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            /*NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[collectedDates objectAtIndex:i]];
            NSInteger day = [dateComponents day];
            NSInteger month = [dateComponents month];
            NSInteger year = [dateComponents year];*/
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.calendar = gregorian;
            formatter.dateFormat = @"dd MMM yy";
            
            NSString *formattedDate = [formatter stringFromDate:[collectedDates objectAtIndex:i]];
            
            [button setTitle:formattedDate forState:UIControlStateNormal];
            button.frame = CGRectMake(0.0, i *(height_button+padding_top), width_button, height_button);
            [[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            if ([[collectedDates objectAtIndex:i] isEqualToDate: heatmapDate]) {
                [button setBackgroundImage:[UIImage imageNamed:@"right_menu_blue_button.png"] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                [button setBackgroundImage:[UIImage imageNamed:@"right_menu_white_button.png"] forState:UIControlStateNormal];
            }
            [dateOptionView addSubview:button];
        }
        
        dateOptionView.contentSize = CGSizeMake(self.frame.size.width, (viewcount+1) *(height_button+padding_top));
        
        [dateOptionView setFrame:CGRectMake(0, 39,100,206)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, dateOptionView.frame.size.width, 300)];

        [self.layer setCornerRadius:4];
        [self.layer setMasksToBounds:YES];
        //self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        //self.layer.borderWidth = 1.0f;
        
        [self addSubview:dateOptionView];

    }
    return self;
}

-(void)generateHeatmapOnDate {

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
