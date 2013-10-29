
#import "STHeatmap.h"
#define STHeapmapAlpha 0.75f

@implementation STHeatmap

#pragma mark - Initializers

-(id)initWithSize:(CGSize)aSize
{
    self = [super init];
    if (self) {
        size = aSize;
        colors = [NSMutableDictionary dictionary];
        self.resolution = 5.0f;
        [self resetColors];
    }
    return self;
}

#pragma mark - Accessors

-(UIImage *)heatmapImage
{
    return _heatmapImage;
}

#pragma mark - Heatmap Colors

-(void)addColor:(UIColor *)color forRelativeValue:(float)relativeValue
{
    NSAssert(relativeValue >= 0.0f && relativeValue <= 1.0f, @"Relative value must be between 0 and 1");
    colors[@(relativeValue)] = color;
}

-(void)resetColors
{
    [colors removeAllObjects];
    [self addColor:[UIColor grayColor] forRelativeValue:0.0f];
    [self addColor:[UIColor blueColor] forRelativeValue:0.25f];
    [self addColor:[UIColor greenColor] forRelativeValue:0.5f];
    [self addColor:[UIColor yellowColor] forRelativeValue:0.75f];
    [self addColor:[UIColor redColor] forRelativeValue:1.0f];
}

#pragma mark - Generating a Heatmap

-(void)generateHeatmapImage
{
    NSLog(@"started to create heatmap");
    if(_points == nil || [_points count] <= 0 || busy)
        return;
    busy = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        float maxValue = 0.0f;
        float minValue = FLT_MAX;
        for(STHeatmapPoint *point in self.points) {
            maxValue = MAX(point.value, maxValue);
            minValue = MIN(point.value, minValue);
        }
        
        _maxValue = maxValue;
        _minValue = minValue;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIGraphicsBeginImageContext(size);
        });
        
        dispatch_queue_t queue = dispatch_queue_create("heatmap", 0);
        for(float y = 0; y < floor(size.height); y += self.resolution){
            dispatch_async(queue, ^{
                for(float x = 0; x < floor(size.width); x += self.resolution){
                    float value = [self interpolatValueForPoint:CGPointMake(x, y)];
                    CGFloat red,green,blue,alpha;
                    [self colorForRelativeValue:(value / maxValue) red:&red green:&green blue:&blue alpha:&alpha];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGContextRef ctx = UIGraphicsGetCurrentContext();
                        CGContextSetRGBFillColor(ctx, red, green, blue, alpha);
                        CGContextFillRect(ctx, CGRectMake(x, y, _resolution, _resolution));
                    });
                }
            });
        }
        dispatch_sync(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                _heatmapImage = image;
                busy = NO;
                NSLog(@"Done");
                if([_delegate respondsToSelector:@selector(heatmap:didGenerateImage:)])
                    [_delegate heatmap:self didGenerateImage:self.heatmapImage];
            });
        });
    });
}

- (void)colorForRelativeValue:(float)value red:(float*)red green:(float*)green blue:(float*)blue alpha:(float*)alpha
{
    NSArray *stops = [[colors allKeys] sortedArrayUsingSelector:@selector(compare:)];
    // Find the color stops left and right of our value
    NSNumber *leftStop = nil;
    NSNumber *rightStop = nil;
    for(NSUInteger i = 0; i < ([stops count] - 1); i++){
        leftStop = stops[i];
        rightStop = stops[i + 1];
        if([leftStop floatValue] < value && [rightStop floatValue] >= value)
            break;
    }
    // Interpolate between the two colors
    UIColor *leftColor = colors[leftStop];
    UIColor *rightColor = colors[rightStop];
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    float x = (value - [leftStop floatValue]) / ([rightStop floatValue] - [leftStop floatValue]);
    [leftColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [rightColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    *red = InterpolateLinearPercentage(r1,r2,x);
    *green = InterpolateLinearPercentage(g1,g2,x);
    *blue = InterpolateLinearPercentage(b1,b2,x);
    *alpha = STHeapmapAlpha;
}

NS_INLINE float InvertedWeightedDistance(CGPoint p1, CGPoint p2){
    float distance = hypotf(p1.x - p2.x, p1.y - p2.y);
    return (1.0f / (distance * distance * distance));
}

NS_INLINE float InterpolateLinearPercentage(float a, float b, float x){
    if(a == b)
        return a;
    else if(b > a)
        return ((b - a) * x);
    else
        return ((a - b) * (1.0f - x));
}

- (float)interpolatValueForPoint:(CGPoint)point
{
    float divisor = 0.0f;
    float value = 0.0f;
    for(STHeatmapPoint *valuePoint in _points){
        divisor += InvertedWeightedDistance(valuePoint.position, point);
    }
    for(STHeatmapPoint *valuePoint in _points){
        value += (InvertedWeightedDistance(valuePoint.position, point) * valuePoint.value) / divisor;
    }
    return value;
}

- (NSDictionary *)colors {
    return colors;
}

@end
