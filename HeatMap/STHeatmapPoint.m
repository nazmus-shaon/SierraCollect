
#import "STHeatmapPoint.h"

@implementation STHeatmapPoint

+(instancetype)pointWithPosition:(CGPoint)position value:(float)value
{
    return [[STHeatmapPoint alloc] initWithPosition:position value:value];
}

-(id)initWithPosition:(CGPoint)position value:(float)value
{
    self = [super init];
    if (self) {
        self.position = position;
        self.value = value;
    }
    return self;
}

@end
