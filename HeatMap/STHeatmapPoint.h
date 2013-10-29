
#import <Foundation/Foundation.h>

@interface STHeatmapPoint : NSObject
{
    
}

@property (assign) CGPoint position;
@property (assign) float value;

+ (instancetype)pointWithPosition:(CGPoint)position value:(float)value;
- (id)initWithPosition:(CGPoint)position value:(float)value;

@end
