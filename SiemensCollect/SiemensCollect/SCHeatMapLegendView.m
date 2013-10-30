//
//  SCHeatMapLegendView.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 14.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCHeatMapLegendView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SCHeatMapLegendView

- (id)initWithFrame:(CGRect)frame andColorDict:(NSDictionary *)colorDict andValueDict:(NSDictionary *)valueDict;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"left_legend_bg.png"]];
        [self setBackgroundColor:background];

        float width_color = 25.0;
        float height_color = 15.0;
        
        float padding_top = 8.0;
        
        UIView *legendView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 300)];
        //[legendView setBackgroundColor:[UIColor blackColor]];
        [legendView setBackgroundColor:[UIColor clearColor]];
        
        NSArray *sortedKeys = [[colorDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        int count = 0;
        for (NSString *str in sortedKeys) {
            UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, count *(height_color+padding_top), width_color, height_color)];
            [view1 setBackgroundColor:[colorDict objectForKey:str]];
            [view1.layer setCornerRadius:4];
            [view1.layer setMasksToBounds:YES];
            //view1.layer.borderColor = [(UIColor *)[colorDict objectForKey:str] CGColor];
            //view1.layer.borderWidth = 1.0f;
            [legendView addSubview:view1];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + width_color,  view1.frame.origin.y , 100, height_color)];
            [valueLabel setText:[valueDict objectForKey:str]];
            [valueLabel setBackgroundColor:[UIColor clearColor]];
            [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            [legendView addSubview:valueLabel];
            
            count++;
        }
        
        [legendView setFrame:CGRectMake(10, 47,100, count *(height_color+padding_top)-10)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, legendView.frame.size.width, 300)];
        //[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, legendView.frame.size.width, legendView.frame.size.height+20)];
        
        [self.layer setCornerRadius:4];
        [self.layer setMasksToBounds:YES];
        //self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        //self.layer.borderWidth = 1.0f;
        
        [self addSubview:legendView];
    }
    return self;
}


@end
