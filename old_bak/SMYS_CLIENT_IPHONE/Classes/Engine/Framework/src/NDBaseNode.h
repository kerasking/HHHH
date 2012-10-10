//
//  NDBaseNode.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "NDNode.h"

using namespace NDEngine;

@interface NDBaseNode : CCNode 
{
	NDNode* _ndNode;
}
@property (nonatomic, assign)NDNode* ndNode;

@end
