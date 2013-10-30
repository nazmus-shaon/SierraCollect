///this class takes charge of taking as input a nsarray containing uiimages
//and outputs a uiimage containing a panorama composiing those uiimages

#import <Foundation/Foundation.h>

@interface STImageStitcher : NSObject

/*
    stitches images into a panorama
 
    @param images array of UIImages to stitch
    @return stitched panorama
 */
+ (UIImage *) panoramaFromImages:(NSArray *) images;

@end
