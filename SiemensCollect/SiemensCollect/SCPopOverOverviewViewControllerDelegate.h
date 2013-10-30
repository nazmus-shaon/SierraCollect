//
//  SCPopOverOverviewViewControllerDelegate.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 07.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#ifndef SiemensCollect_SCPopOverOverviewViewControllerDelegate_h
#define SiemensCollect_SCPopOverOverviewViewControllerDelegate_h

@protocol SCPopOverOverviewViewControllerDelegate <NSObject>

- (void)deleteCheckPointClicked;
- (void)startSubRouteClicked;
- (void)mergeRouteClicked;

@end

#endif
