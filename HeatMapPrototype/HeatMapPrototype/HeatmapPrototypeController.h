
#import <UIKit/UIKit.h>
#import "STHeatmap.h"
#import "STHeatmapPointView.h"

@interface HeatmapPrototypeController : UIViewController
<STHeatmapDelegate>
{
    IBOutlet UISlider *valueSlider;
    IBOutlet UILabel *valueLabel;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIImageView *heatmapImageView;
    IBOutlet STHeatmapPointView *pointView;
    IBOutlet UIView *overlayView;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UISlider *resolutionSlider;
    IBOutlet UIView *toolbarView;

    NSMutableArray *points;
    NSNumberFormatter *formatter;
    STHeatmap *heatmap;
}

- (IBAction)valueSliderChanged:(id)sender;
- (IBAction)erasePoints:(id)sender;
- (IBAction)generateHeatmap:(id)sender;

@end
