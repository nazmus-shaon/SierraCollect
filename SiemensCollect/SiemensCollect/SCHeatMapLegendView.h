//
//  SCHeatMapLegendView.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 14.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHeatMapLegendView : UIView

- (id)initWithFrame:(CGRect)frame andColorDict:(NSDictionary *)colorDict andValueDict:(NSDictionary *)valueDict;

@end
