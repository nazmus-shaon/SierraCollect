
#import <Foundation/Foundation.h>
#import "STHeatmapPoint.h"

@class STHeatmap;
@protocol STHeatmapDelegate <NSObject>
- (void)heatmap:(STHeatmap*)heatmap didGenerateImage:(UIImage*)image;
@end

@interface STHeatmap : NSObject
{
    UIImage *_heatmapImage;
    CGSize size;
    NSMutableDictionary *colors;
    BOOL busy;
}

@property (copy) NSArray *points;
@property (assign) float resolution;
@property (strong, readonly) UIImage *heatmapImage;
@property (weak) id<STHeatmapDelegate>delegate;

- (id)initWithSize:(CGSize)size;
-(void)generateHeatmapImage;

- (void)addColor:(UIColor*)color forRelativeValue:(float)relativeValue;
- (void)resetColors;

@end
