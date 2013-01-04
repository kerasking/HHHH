//
//  TopMenuBar.h
//  smart_gomoku
//
//  Created by Charlene Jiang on 11/10/11.
//  Copyright 2011 Mighty Craft Co. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Enumeration of all available TopMenuBar positions.
 * @note All 4 positions are valid for TopMenuBar positions.
 * @note GreeWidgetPositionTopLeft is the default TopMenuBar position if user do not set it.
 */
typedef enum {
    /**
     * Positions the TopMenuBar at the top of the screen vertically, all the way to the left
     */
    MBGMenuBarPositionTopLeft,
    
    /**
     * Positions the TopMenuBar at the bottom of the screen vertically, all the way to the right
     */
    MBGMenuBarPositionTopRight,
    
    /**
     * Positions the TopMenuBar at the bottom of the screen vertically, all the way to the left
     */
    MBGMenuBarPositionBottomLeft,
    
    /**
     * Positions the TopMenuBar at the bottom of the screen vertically, all the way to the right
     */
    MBGMenuBarPositionBottomRight,

} MBGMenuBarPosition;


/**
 * The TopMenuBar class provides a way to show in-game community
 */

@interface TopMenuBar : UIView
{

}

+ (TopMenuBar *)shareInstance;

/**
 * This TopMenuBar's position can be adjusted to any of the 4 valid positions
 * @see MBGMenuBarPosition
 */
- (void)updatePosition:(MBGMenuBarPosition)aPosition;
/**
 * This TopMenuBar's can be hidden if the vaule hidden set to YES, if set to NO, it will show again.
 */
- (void)setHidden:(BOOL)hidden; //set hidden for the top menu

/**
 * show TopMenuBar in a view, user need provided the view controller of this view. if this method was not called, the TopMenuBar will default show in MBGPlatform.rootViewController 
 */
- (void)showTopMenuBarInViewController:(UIViewController *)viewController;

@end
