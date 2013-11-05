//
//  SCHeatMapDateOptionView.h
//  SiemensCollect
//
//  Created by Nazmus Shaon on 04/11/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHeatMapDateOptionView : UIView

- (id)initWithFrame:(CGRect)frame dateList:(NSMutableArray *)collectedDates selectedDate:(NSDate *)heatmapDate;

@end
