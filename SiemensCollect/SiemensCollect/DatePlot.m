//
//  DatePlot.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 11/14/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "DatePlot.h"

@implementation DatePlot

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        //self.title   = @"Date Plot";
        //self.section = kLinePlots;
    }

    return self;
}

-(void)generateData
{
//    NSTimeInterval oneDay = 24 * 60 * 60;
//
//    // Add some data
//    NSMutableArray *newData = [NSMutableArray array];
//    NSUInteger i;
//
//    for ( i = 0; i < 5; i++ ) {
//        NSTimeInterval x = oneDay * i;
//        id y             = [NSDecimalNumber numberWithFloat:1.2 * rand() / (float)RAND_MAX + 1.2];
//        [newData addObject:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPTScatterPlotFieldX],
//          y, [NSNumber numberWithInt:CPTScatterPlotFieldY],
//          nil]];
//    }
//    self.plotData = newData;
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    NSLog(@"=== DatePlot got intervalX: %f, intervalY: %f", _intervalX, _intervalY);
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//
//    [dateComponents setMonth:10];
//    [dateComponents setDay:29];
//    [dateComponents setYear:2009];
//    [dateComponents setHour:12];
//    [dateComponents setMinute:0];
//    [dateComponents setSecond:0];
    //NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //NSDate *refDate = [gregorian dateFromComponents:dateComponents];
    NSDate *refDate = self.startDate;
    //[dateComponents release];
    //[gregorian release];

    //NSTimeInterval oneDay = 60;//24 * 60 * 60;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    graph.plotAreaFrame.paddingLeft   += 50.0;
    graph.plotAreaFrame.paddingTop    += 10.0;
    graph.plotAreaFrame.paddingRight  += 10.0;
    graph.plotAreaFrame.paddingBottom += 140.0;
//    graph.plotAreaFrame.masksToBorder  = NO;
    graph.plotAreaFrame.borderLineStyle = nil;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;  // ============ from CurvedScatterPlot =============
//    plotSpace.delegate = self;
    
    
    // Grid line styles                     // ============ from CurvedScatterPlot =============
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    
    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake(15.0, 15.0);

    //NSTimeInterval xLow = -(self.interval);
    //float yLow;
    
    // woody // set how many x-axis data to shown
    //plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(24*60*60 * 10)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(self.intervalX * _numberOfRecordsX)];
    // woody // set where would be the o axis and how many y-axis data to show
    //plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-self.intervalY) length:CPTDecimalFromFloat(self.intervalY)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_startingPositionY) length:CPTDecimalFromFloat(self.intervalY * _numberOfRecordsY)];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromFloat(_intervalX);
    //x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy  hh:mm:ss"];
    //dateFormatter.dateStyle = kCFDateFormatterFullStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    x.labelRotation             = -(M_PI / 2);
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    //x.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    lineCap.lineStyle = x.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    x.axisLineCapMax  = lineCap;
    
    //x.title = self.xAxisTitle;
    //x.titleOffset = 30.0;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromFloat(self.intervalY);//CPTDecimalFromString(@"10");
    y.minorTicksPerInterval       = 0;
//    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(-20);//self.intervalX
    
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    
    //y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    //y.preferredNumberOfMajorTicks = 8;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    //y.labelOffset                 = 10.0;
    
    lineCap.lineStyle = y.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    y.axisLineCapMax  = lineCap;
    y.axisLineCapMin  = lineCap;
    
    //y.title       = self.yAxisTitle;
    //y.titleOffset = 35.0;
    
    //graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    //dataSourceLinePlot.identifier = @"Date Plot";
    
    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.f;
    lineStyle.lineColor              = [CPTColor blueColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    dataSourceLinePlot.identifier = [NSString stringWithFormat:@"%@ / %@", self.yAxisTitle, self.xAxisTitle];// this will be shown in Legend
    [graph addPlot:dataSourceLinePlot];
    
    // ============ from CurvedScatterPlot =============
    // Auto scale the plot space to fit the plot data
//    [plotSpace scaleToFitPlots:[graph allPlots]];
//    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
//    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
//
//    // Expand the ranges to put some space around the plot
//    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.2)];
//    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.2)];
//    plotSpace.xRange = xRange;
//    plotSpace.yRange = yRange;
//    
//    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.025)];
//    xRange.location = plotSpace.xRange.location;
//    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
//    x.visibleAxisRange = xRange;
//    y.visibleAxisRange = yRange;
//    
//    [xRange expandRangeByFactor:CPTDecimalFromDouble(3.0)];
//    [yRange expandRangeByFactor:CPTDecimalFromDouble(3.0)];
//    plotSpace.globalXRange = xRange;
//    plotSpace.globalYRange = yRange;
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    //plotSymbol.fill               = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0 green:170 blue:173 alpha:1]];
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor brownColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 1;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legend.swatchSize      = CGSizeMake(25.0, 25.0);
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, 12.0);

}

//-(void)dealloc
//{
//    [plotData release];
//    [super dealloc];
//}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [[self.plotData objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];

    return num;
}

@end
