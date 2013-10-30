//
//  SCNewsView.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 28.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCNewsView.h"

@implementation SCNewsView

- (id)initWithFrame:(CGRect)frame andNews:(NSString *)newsString
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _newsString = newsString;
        
        UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [back setBackgroundColor:[UIColor clearColor]];
        [self addSubview:back];
        
        UILabel *newsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, frame.size.width-40, frame.size.height-40)];
        [newsLabel setTextAlignment:NSTextAlignmentCenter];
        [newsLabel setBackgroundColor:[UIColor lightGrayColor]];
        [newsLabel setText:newsString];
        [back addSubview:newsLabel];
    
        
        UIControl *newsControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [newsControl addTarget:self action:@selector(showNews) forControlEvents:UIControlEventTouchUpInside];
        [newsControl setBackgroundColor:[UIColor clearColor]];
        [self addSubview:newsControl];
    }
    return self;
}

- (void)showNews {
    NSLog(@"ShowNews");
    [self.delegate didClickOnNews:_newsString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
