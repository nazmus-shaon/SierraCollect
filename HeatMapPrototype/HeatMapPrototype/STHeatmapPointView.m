
#import "STHeatmapPointView.h"

@implementation STHeatmapPointView

-(void)setPoint:(STHeatmapPoint *)point
{
    if(formatter == nil){
        formatter = [[NSNumberFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.maximumFractionDigits = 1;
    }
    _point = point;
    valueLabel.text = [formatter stringFromNumber:@(point.value)];
}

-(STHeatmapPoint *)point
{
    return _point;
}

@end
