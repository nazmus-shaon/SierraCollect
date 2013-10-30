//
//  DatePlot.h
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface DatePlot : PlotItem<CPTPlotSpaceDelegate,
                               CPTPlotDataSource,
                               CPTScatterPlotDelegate>
{
//    @private
//    NSArray *plotData;
}

@property (nonatomic, strong) NSArray *plotData;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) NSTimeInterval intervalX;
@property (nonatomic) float intervalY;
@property (nonatomic) int numberOfRecordsX;
@property (nonatomic) int numberOfRecordsY;

@property (nonatomic) NSString *xAxisTitle;
@property (nonatomic) NSString *yAxisTitle;
@property (nonatomic) int startingPositionY;

@property (nonatomic) float numberOfRecords;

@end
