//
//  SCLatestRecordView.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol SCLatestRecordViewDelegate <NSObject>

- (void)didClickOnFloorplan:(STFloor *)floorplan;

@end

@interface SCLatestRecordView : UIView {
    STFloor *plan;
}

- (id)initWithFrame:(CGRect)frame andFloorplan:(STFloor *)floorplan;

@property (nonatomic, weak) NSObject <SCLatestRecordViewDelegate> *delegate;

@end
