//
//  SCGraphPickerViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 10.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"

@class SCGraphPickerViewController;
@protocol SCGraphPickerViewControllerDelegate <NSObject>

- (void)pickedSensor:(NSNumber *)sensorID;

@end

@interface SCGraphPickerViewController : SCAbstractViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *sensorPickerView;

@property (weak) id<SCGraphPickerViewControllerDelegate>delegate;

@end
