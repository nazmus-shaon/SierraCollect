//
//  SCOverviewViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCOverviewViewController.h"
#import "PDFPageConverter.h"

@interface SCOverviewViewController ()

@end

NSString *kCellID = @"cellID";   

@implementation SCOverviewViewController

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSLog(@"count: %i", [storedPDFs count]);
    return [storedPDFs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    //NSLog(@"%@",[[storedPDFs objectAtIndex:indexPath.row] relatedFile]);
    SCPdfPreviewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.headlineLabel.text = [NSString stringWithFormat:@"%@", [[storedPDFs objectAtIndex:indexPath.row] name]];
    //[cell.previewImage setImage:[[storedPDFs objectAtIndex:indexPath.row] getSmallPreviewImage]];
    
    // Use different library to convert pdf to image, to reduce memory leak - sakib
    NSString *fn = [[[storedPDFs objectAtIndex:indexPath.row] relatedFile] stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:fn ofType:@"pdf"];
    //file ref
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)([ NSURL fileURLWithPath:fileLocation]));
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    [cell.previewImage setImage:[PDFPageConverter convertPDFPageToImage:page withResolution:72]];
    CGPDFDocumentRelease(pdf);
    ////

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Here? %@", [storedPDFs objectAtIndex:indexPath.row]);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SCDetailViewController *cont = [storyboard instantiateViewControllerWithIdentifier:@"detailController" ];
    cont.floorPlan = [storedPDFs objectAtIndex:indexPath.row];

    [self.navigationController pushViewController:cont animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    storedPDFs = [[SCDataService shared] getFloorplansForBuilding:self.building];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
