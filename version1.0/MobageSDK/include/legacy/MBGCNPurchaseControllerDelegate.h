//
//  MobageDelegate.h
//  Sample
//
//  Created by nakanishi.tomoyuki on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBGCNPurchaseControllerDelegate <NSObject>

- (void) purchaseDidFinishWithSuccess:(NSDictionary *)params;

- (void) purchaseDidFailWithError:(NSDictionary *)params;

@end

