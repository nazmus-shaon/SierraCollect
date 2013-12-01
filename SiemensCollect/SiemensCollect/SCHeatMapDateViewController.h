//
//  SCHeatMapDateViewController.h
//  SiemensCollect
//
//  Created by Nazmus Shaon on 21/11/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import <UIKit/UIKit.h>

@class SCHeatMapDateViewController;
@protocol SCHeatMapDateViewControllerDelegate <NSObject>

- (void)heatmapWithSettings:(NSDictionary *)settings;

@end

@interface SCHeatMapDateViewController : SCAbstractViewController 

@property (strong, nonatomic) NSMutableArray *collectedDates;
@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) NSDate *heatmapDate;
@property (weak) id<SCHeatMapDateViewControllerDelegate>delegate;

@end
