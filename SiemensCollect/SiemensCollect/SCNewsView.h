//
//  SCNewsView.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCNewsViewDelegate <NSObject>

- (void)didClickOnNews:(NSString *)newsString;

@end

@interface SCNewsView : UIView {
    NSString *_newsString;
}

- (id)initWithFrame:(CGRect)frame andNews:(NSString *)newsString;

@property (nonatomic, weak) NSObject <SCNewsViewDelegate> *delegate;

@end
