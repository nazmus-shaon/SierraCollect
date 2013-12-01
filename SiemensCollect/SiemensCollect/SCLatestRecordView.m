//
//  SCLatestRecordView.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCLatestRecordView.h"
#import "PDFPageConverter.h"

@implementation SCLatestRecordView{
    UIImage *img;
}



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
        
        //sakib - Different approaches to try to fix the memory leak 
        /*UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height, frame.size.width, 300)];
        NSString *fn = [floorplan.relatedFile stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
        NSString *fileLocation = [[NSBundle mainBundle] pathForResource:fn ofType:@"png"];
        img = [UIImage imageWithContentsOfFile:fileLocation];
        //img = [UIImage imageWithContentsOfFile:fn];
        //img = [UIImage imageWithCGImage:img.CGImage scale:0.1 orientation:img.imageOrientation];*/
        //img = [floorplan getImageforWidth:button.frame.size.width];
        //[button setBackgroundImage:img forState:UIControlStateNormal];
        
        NSString *fn = [floorplan.relatedFile stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
        NSString *fileLocation = [[NSBundle mainBundle] pathForResource:fn ofType:@"pdf"];
        //file ref
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)([ NSURL fileURLWithPath:fileLocation]));
        CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
        img = [PDFPageConverter convertPDFPageToImage:page withResolution:72];
        //CGPDFPageRelease(page);
        CGPDFDocumentRelease(pdf);
        
        //img = [floorplan getImageforWidth:holderView.frame.size.width];
        /*UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setFrame:CGRectMake(0, titleLabel.frame.size.height, holderView.frame.size.width, 400)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [holderView addSubview:imageView];*/
        //CGImageRelease([img CGImage]); // this might fix the memeory leak, but the link no longer works, also look inside the getImageforWidth function
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(floorPlanClicked)
         forControlEvents:UIControlEventTouchDown];
        //[button setTitle:@"Show View" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, titleLabel.frame.size.height, holderView.frame.size.width, holderView.frame.size.height -125);
        [button setBackgroundImage:img forState:UIControlStateNormal];
        [holderView addSubview:button];
        
        
        UIView *singelLineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height + 49, holderView.frame.size.width, 1)];
        [singelLineBottom setBackgroundColor:[UIColor darkGrayColor]];
        [holderView addSubview:singelLineBottom];
        
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height + 50, frame.size.width, 85)];
        [infoView setBackgroundColor:[UIColor lightGrayColor]];
        [holderView addSubview:infoView];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, infoView.frame.size.width-40, 20)];
        [infoLabel setBackgroundColor:[UIColor clearColor]];
        [infoLabel setText:[NSString stringWithFormat:@"Building: %@ - %@ - %i", floorplan.building.area.city.name, floorplan.building.name, floorplan.building.number.intValue]];
        [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [infoLabel setTextColor:[UIColor whiteColor]];
        [infoLabel setTextAlignment:NSTextAlignmentCenter];
        [infoView addSubview:infoLabel];
        
        UILabel *infoLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+16, infoView.frame.size.width-40, 20)];
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
        
        UILabel *infoLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+34, infoView.frame.size.width-40, 20)];
        [infoLabel3 setBackgroundColor:[UIColor clearColor]];
        [infoLabel3 setText:[NSString stringWithFormat:@"Points: %i - Measurements: %i", floorplan.points.count, measCount]];
        [infoLabel3 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
        [infoLabel3 setTextColor:[UIColor whiteColor]];
        [infoLabel3 setTextAlignment:NSTextAlignmentCenter];
        [infoView addSubview:infoLabel3];
        
        
        //Replaced the following part with button above
        /*
        UIControl *overlayCtrl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, holderView.frame.size.width, holderView.frame.size.height)];
        [overlayCtrl addTarget:self action:@selector(floorPlanClicked) forControlEvents:UIControlEventTouchUpInside];
        [overlayCtrl setBackgroundColor:[UIColor clearColor]];
        [holderView addSubview:overlayCtrl];*/
        
        
    }
    return self;
}


- (void)floorPlanClicked {
    [self.delegate didClickOnFloorplan:plan];

}


@end
