//
//  Gist.m
//  SiemensCollect
//
//  Created by RegMyUDiD on 6/13/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "Gist.h"
#import "File.h"
#import "User.h"


@implementation Gist

@dynamic createdAt;
@dynamic descriptionText;
@dynamic gistID;
@dynamic htmlURL;
@dynamic jsonURL;
@dynamic public;
@dynamic updatedAt;
@dynamic files;
@dynamic user;

- (NSString *)titleText
{
    return [self.descriptionText length] ? self.descriptionText : @"(untitled)";
}

- (NSString *)subtitleText
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MM/dd/yy '@' HH:mm a";
    });
    return [NSString stringWithFormat:@"by %@ on %@ (%d files)", self.user.login,
            [dateFormatter stringFromDate:self.createdAt], [self.files count]];
}

@end
