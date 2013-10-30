//extension to uiimage so that it is possible
//to convert from and to UIImage

#import <UIKit/UIKit.h>

@interface UIImage (STOpenCV)

/*
 builds a UIImage out of a cv::Mat
 
 @param cvMat reference to the cvMat to convert
 @return the UIImage resulting from the conversion of the cv::Mat
 */
-(id)initWithCVMat:(const cv::Mat&)cvMat;

/*
 converts the UIImage to a grayscale cv::Mat
 
 @return the grayscale cv::Mat
 */
-(cv::Mat) toGrayScaleCVMat;

/*
 converts the UIImage to a BGRA cv::Mat
 
 @return the BGRA cv::Mat
 */
-(cv::Mat) toBGRACVMat;

/*
 converts the UIImage to a RGB cv::Mat
 
 @return the RGB cv::Mat
 */
-(cv::Mat) toRGBCVMat;

/*
 highlights the keypoints on the image
 
 @return an UIImage with the keypoints highlighted
 */
-(UIImage *)showKeypoints;

/*
 counts the keypoints in the image
 
 @return the number of keypoints in the image
 */
-(int)numberOfKeypoints;

@end
