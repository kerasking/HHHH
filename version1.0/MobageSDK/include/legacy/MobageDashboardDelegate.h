//
//  MobageDashboardDelegate.h
//  MyNativeTest
//
//  Created by panzaofeng on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MobageDashboardDelegate <NSObject>
@optional
-(void) onMBGCNCommunityLaunched;

-(void) onMBGCNCommunityDismiss;

-(void) onMBGCNCommunityNNgCommand:(NSURL *)url;

-(void) onMBGCNCommunityError:(NSError *)error;

-(void) onMBGCNCommunityPageLoad;

-(BOOL) onMBGCNCommunityShouldStartLoad:(NSURL *)url;
@end