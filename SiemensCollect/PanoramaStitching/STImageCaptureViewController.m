//
//  STImageCaptureViewController.m
//  Panorama
//
//  Created by Christian Flasche on 24.06.13.
//  Copyright (c) 2013 Natalia Zarawska. All rights reserved.
//

#import "STImageCaptureViewController.h"
#import "STImageStitcher.h"
#import "STKeyPointIndicator.h"
#import "SCAppDelegate.h"
#import "UIImage+Rotating.h"

#define MAX_KEYPOINTS 992
#define GOOD_KEYPOINTS 850
#define STILL_UNACCEPTABLE_KEYPOINTS 700
#define MIN_KEYPOINTS_REQUIRED 600
#define IMAGE_CAPTURING_INTERVAL 3
#define SHOW_QUALITY_FEEDBACK YES

NSString *const STImageCaptureViewControllerImage = @"image";
NSString *const STImageCaptureViewControllerPitch = @"pitch";
NSString *const STImageCaptureViewControllerRoll = @"roll";
NSString *const STImageCaptureViewControllerYaw = @"yaw";
NSString *const STImageCaptureViewControllerImageType = @"type";

NSString * const kSTPanoramaImageType = @"PANORAMA";
NSString * const kSTSingleImageType = @"SINGLE_IMAGE";

@interface STImageCaptureViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takePictureButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rotateButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIProgressView *keypointProgressView;

@property (nonatomic, strong) NSMutableArray *capturedImages; // of NSDictionary
@property (nonatomic, strong) NSDictionary *imageDictionary;

@end

@implementation STImageCaptureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.capturedImages = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.image) {
        [self showImage];
    } else if (![self.activityIndicator isAnimating]) {
        [self showImagePicker];
    }
}

- (void)showImage
{
    self.imageView.image = self.image;
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.width);
    self.scrollView.delegate = self;
}


#pragma mark - Toolbar actions (view mode)
- (IBAction)takeNewPicture:(id)sender {
    [self showImagePicker];
}

- (IBAction)useCurrentImage:(id)sender {
    // return to previous view
    [self.delegate imageChosen:self.imageDictionary];
}

- (void)showImagePicker
{
    if (self.capturedImages.count > 0) {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    /* We set up our own camera controls to implement customized behavior */
    imagePickerController.showsCameraControls = NO;
        
    /*
      Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
    */
    [[NSBundle mainBundle] loadNibNamed:@"STCameraOverlayView" owner:self options:nil];
    
//    [self.keypointString setText:@""]; // feedback text should be empty at the beginning
    [self setProgressForKeypoints:0];

    self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
    imagePickerController.cameraOverlayView = self.overlayView;
    self.overlayView = nil;
    
    CMMotionManager *mManager = [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];
    
    // start collecting device motion data
    // if (!self.motionManager.deviceMotionActive) {
    [mManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    // }
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)rotatePanorama:(id)sender {
    self.image = [self.image rotateInDegrees:180];
    [self showImage];
}


#pragma mark - Toolbar actions (capture mode)

-(void)setProgressForKeypoints:(int)keypoints
{
    float progress = (float)keypoints / (float)MAX_KEYPOINTS;
    [self.keypointProgressView setProgress:progress];
    if (keypoints < STILL_UNACCEPTABLE_KEYPOINTS) {
        [self.keypointProgressView setProgressTintColor:[UIColor redColor]];
    } else {
        if (keypoints < GOOD_KEYPOINTS)
            [self.keypointProgressView setProgressTintColor:[UIColor yellowColor]];
        else
            [self.keypointProgressView setProgressTintColor:[UIColor greenColor]];
    }
}

- (IBAction)done:(id)sender
{
    [self finishCaptureMode];
}

- (IBAction)takePhoto:(id)sender
{
    [self.keypointProgressView setProgress:0];
    [self.imagePickerController takePicture];
}

- (void)finishCaptureMode {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.capturedImages.count > 0) {
        
        if (self.capturedImages.count == 1) {
            NSMutableDictionary *imageDictionary = [[self.capturedImages lastObject] mutableCopy];
            [imageDictionary setObject:kSTSingleImageType forKey:STImageCaptureViewControllerImageType];
            self.image = ((NSDictionary *)[self.capturedImages lastObject])[STImageCaptureViewControllerImage];
            self.imageDictionary = imageDictionary;
            
            // To be ready to start again, clear the captured images array.
            [self.capturedImages removeAllObjects];
        } else {
            // [NSThread detachNewThreadSelector:@selector(stitchPanorama) toTarget:self withObject:nil];
            [self stitchPanorama];
        }
    }
    self.imagePickerController = nil;
}

- (void)stitchPanorama
{
    // images are stored in dictionaries. We don't need the additional data of the single images like pitch, roll and yaw in the panorama (makes no sense)
    
    NSMutableDictionary *imageDictionary = [(NSDictionary *)[self.capturedImages lastObject] mutableCopy];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.capturedImages) {
        [images addObject:dict[STImageCaptureViewControllerImage]];
    }

    NSLog(@"Stitching images...");
    [self.activityIndicator startAnimating];
    
    dispatch_queue_t panoramaQueue = dispatch_queue_create("de.tum.panoramaqueue", NULL);

    dispatch_async(panoramaQueue, ^{
        self.image = [STImageStitcher panoramaFromImages:images];
        NSLog(@"Stitching finished.");
        [imageDictionary setObject:self.image forKey:STImageCaptureViewControllerImage];
        [imageDictionary setObject:kSTPanoramaImageType forKey:STImageCaptureViewControllerImageType];
        self.imageDictionary = imageDictionary;
        //update ui elements
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self showImage];
            
            // To be ready to start again, clear the captured images array.
            [self.capturedImages removeAllObjects];
        });
    });
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Picture captured.");
    
    NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [imageDictionary setObject:image forKey:STImageCaptureViewControllerImage];
    
    CMMotionManager *mManager = [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] sharedMotionManager];
    NSNumber *pitch, *roll, *yaw;
    
    if (mManager.deviceMotionAvailable) {
        CMDeviceMotion *deviceMotion = mManager.deviceMotion;
        
        pitch = @(deviceMotion.attitude.pitch);
        roll = @(deviceMotion.attitude.roll);
        yaw = @(deviceMotion.attitude.yaw);
        
        [imageDictionary setObject:pitch forKey:STImageCaptureViewControllerPitch];
        [imageDictionary setObject:roll forKey:STImageCaptureViewControllerRoll];
        [imageDictionary setObject:yaw forKey:STImageCaptureViewControllerYaw];
        
        NSLog(@"Device motion data: [pitch: %@; roll: %@; yaw: %@]", pitch, roll, yaw);
    }
    
    if (SHOW_QUALITY_FEEDBACK) {
        int keyPointCount = [STKeyPointIndicator numberOfKeypointsInImage:image];
        NSLog(@"%d keypoints found.", keyPointCount);
    
    
        // Showing feedback of keypoint amount
//        [self.keypointString setText:[NSString stringWithFormat:@"%d keypoints", keyPointCount]];
//        if (keyPointCount < MIN_KEYPOINTS_REQUIRED) {
//            [self.keypointString setTextColor:[UIColor redColor]];
//        } else {
//            [self.keypointString setTextColor:[UIColor greenColor]];
//            [self.capturedImages addObject:imageDictionary];
//        }

        [self setProgressForKeypoints:keyPointCount];
        if (keyPointCount > MIN_KEYPOINTS_REQUIRED) {
            [self.capturedImages addObject:imageDictionary];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
