//
//  MobagePageCtl.h
//  Sample
//
//  Created by pan.zaofeng on 12-5-14.
//  Copyright 2011 DeNA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MobagePageCtl : UIPageControl
{
    UIImage *imagePageStateNormal;
    UIImage *imagePageStateHighlighted;
}

- (void) resizeDots : (float) k;

@property (nonatomic, retain) UIImage *imagePageStateNormal;
@property (nonatomic, retain) UIImage *imagePageStateHighlighted;

@end