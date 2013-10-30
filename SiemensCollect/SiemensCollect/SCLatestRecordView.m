//
//  SCLatestRecordView.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCLatestRecordView.h"

@implementation SCLatestRecordView



- (id)initWithFrame:(CGRect)frame andFloorplan:(STFloor *)floorplan {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];

    if (self) {
        
        UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, frame.size.height-20)];
        [holderView setBackgroundColor:[UIColor clearColor]];
        [holderView.layer setCornerRadius:8];
        [holderView.layer setMasksToBounds:YES];
        holderView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        holderView.layer.borderWidth = 1.0f;
        [self addSubview:holderView];
        
        plan = floorplan;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, holderView.frame.size.width, 50)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:[NSString stringWithFormat:@"Floorplan: %@", floorplan.name]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor lightGrayColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22]];
        [holderView addSubview:titleLabel];
        
        UIView *singelLine = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height, holderView.frame.size.width, 1)];
        [singelLine setBackgroundColor:[UIColor darkGrayColor]];
        [holderView addSubview:singelLine];
        
        
        //320
        
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height, frame.size.width, 300)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[floorplan getImageforWidth:holderView.frame.size.width]];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setFrame:CGRectMake(0, titleLabel.frame.size.height, imageView.frame.size.width, imageView.frame.size.height)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [holderView addSubview:imageView];
        
        UIView *singelLineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height + 49, holderView.frame.size.width, 1)];
        [singelLineBottom setBackgroundColor:[UIColor darkGrayColor]];
        [holderView addSubview:singelLineBottom];
        
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height + 50, frame.size.width, 85)];
        [infoView setBackgroundColor:[UIColor lightGrayColor]];
        [holderView addSubview:infoView];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, infoView.frame.size.width-40, 20)];
        [infoLabel setBackgroundColor:[UIColor clearColor]];
        [infoLabel setText:[NSString stringWithFormat:@"Building: %@ - %@ - %i", floorplan.building.city.name, floorplan.building.name, floorplan.building.number.intValue]];
        [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [infoLabel setTextColor:[UIColor whiteColor]];
        [infoLabel setTextAlignment:NSTextAlignmentCenter];
        [infoView addSubview:infoLabel];
        
        UILabel *infoLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+20, infoView.frame.size.width-40, 20)];
        [infoLabel2 setBackgroundColor:[UIColor clearColor]];
        [infoLabel2 setText:[NSString stringWithFormat:@"Floornumber: %i - Groundfloor: %@", floorplan.floorNr.intValue, floorplan.isGroundFloor.boolValue ? @"Yes" : @"No"]];
        [infoLabel2 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [infoLabel2 setTextColor:[UIColor whiteColor]];
        [infoLabel2 setTextAlignment:NSTextAlignmentCenter];
        [infoView addSubview:infoLabel2];
        
        
        //count measurements:
        int measCount = 0;
        for (STPoint *point in floorplan.points) {
            measCount += point.sensorPoints.count;
        }
        
        UILabel *infoLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+40, infoView.frame.size.width-40, 20)];
        [infoLabel3 setBackgroundColor:[UIColor clearColor]];
        [infoLabel3 setText:[NSString stringWithFormat:@"Points: %i - Measurements: %i", floorplan.points.count, measCount]];
        [infoLabel3 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [infoLabel3 setTextColor:[UIColor whiteColor]];
        [infoLabel3 setTextAlignment:NSTextAlignmentCenter];
        [infoView addSubview:infoLabel3];
        
        
        
        UIControl *overlayCtrl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, holderView.frame.size.width, holderView.frame.size.height)];
        [overlayCtrl addTarget:self action:@selector(floorPlanClicked) forControlEvents:UIControlEventTouchUpInside];
        [overlayCtrl setBackgroundColor:[UIColor clearColor]];
        [holderView addSubview:overlayCtrl];
        
    }
    return self;
}


- (void)floorPlanClicked {
    [self.delegate didClickOnFloorplan:plan];
}


@end
