//
//  NDCompare.h
//  Example
//
//  Created by jhzheng on 10-12-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NDCompare
// 等于
-(BOOL) compareEqualOtherObj:(id)otherObj;
// 小于
-(BOOL) compareSmallThanOtherObj:(id)otherObj;
@end
