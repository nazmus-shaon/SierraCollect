
#import <UIKit/UIKit.h>
#import "STHeatmapPoint.h"

@interface STHeatmapPointView : UIView
{
    IBOutlet UILabel *valueLabel;
    STHeatmapPoint *_point;
    NSNumberFormatter *formatter;
}

@property (strong, nonatomic) STHeatmapPoint *point;

@end
