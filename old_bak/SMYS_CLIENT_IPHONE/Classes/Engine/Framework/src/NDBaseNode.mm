//
//  NDBaseNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDBaseNode.h"
#import "NDNode.h"
#import "NDDirector.h"
#import "NDUITableLayer.h"


@implementation NDBaseNode

@synthesize ndNode = _ndNode;

- (void)draw
{
	if (_ndNode->DrawEnabled()) 
	{
		NDDirector::DefaultDirector()->ResumeViewRect(_ndNode);
		_ndNode->draw();
	}	
}

@end
