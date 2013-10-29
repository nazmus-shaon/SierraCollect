
#import "HeatmapPrototypeController.h"

@interface HeatmapPrototypeController ()

@end

@implementation HeatmapPrototypeController

- (void)viewDidLoad
{
    [super viewDidLoad];

    formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.maximumFractionDigits = 1;
    points = [NSMutableArray array];
    [self valueSliderChanged:self];
    heatmap = [[STHeatmap alloc] initWithSize:backgroundImageView.image.size];
    overlayView.hidden = YES;
}

- (IBAction)erasePoints:(id)sender
{
    [points removeAllObjects];
    for(UIView *view in [self.view.subviews copy]){
        if([view isKindOfClass:[STHeatmapPointView class]])
            [view removeFromSuperview];
    }
}

- (IBAction)generateHeatmap:(id)sender
{
    heatmap.points = points;
    heatmap.delegate = self;
    heatmap.resolution = floor(20.0f - resolutionSlider.value);
    overlayView.hidden = NO;
    [spinner startAnimating];
    [heatmap generateHeatmapImage];
}

-(void)valueSliderChanged:(id)sender
{
    valueLabel.text = [formatter stringFromNumber:@(valueSlider.value)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(overlayView.hidden){
        for(UITouch *touch in touches){
            CGPoint location = [touch locationInView:heatmapImageView];
            if(!CGRectContainsPoint(toolbarView.frame, location)){
                STHeatmapPoint *point = [STHeatmapPoint pointWithPosition:location value:valueSlider.value];
                [points addObject:point];
                [[NSBundle mainBundle] loadNibNamed:@"STHeatmapPointView" owner:self options:nil];
                pointView.translatesAutoresizingMaskIntoConstraints = NO;
                pointView.point = point;
                [self.view addSubview:pointView];
                CGRect frame = pointView.frame;
                frame.origin = CGPointMake(point.position.x - (frame.size.width / 2), point.position.y - frame.size.height);
                pointView.frame = frame;
            }
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidUnload
{
    pointView = nil;
    [super viewDidUnload];
}

-(void)heatmap:(STHeatmap *)heatmap didGenerateImage:(UIImage *)image
{
    overlayView.hidden = YES;
    heatmapImageView.image = image;
}
@end
