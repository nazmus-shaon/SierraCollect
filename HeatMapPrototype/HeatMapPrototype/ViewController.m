
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.maximumFractionDigits = 1;
    points = [NSMutableArray array];
    [self valueSliderChanged:self];
    heatmap = [[STHeatmap alloc] initWithSize:backgroundImageView.image.size];
}

- (IBAction)erasePoints:(id)sender
{
    
}

- (IBAction)generateHeatmap:(id)sender
{
    heatmap.points = points;
}

-(void)valueSliderChanged:(id)sender
{
    valueLabel.text = [formatter stringFromNumber:@(valueSlider.value)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInView:heatmapImageView];
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

- (void)viewDidUnload
{
    pointView = nil;
    [super viewDidUnload];
}
@end
