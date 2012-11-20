//
//  cocos2dExt.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "cocos2dExt.h"
#include "NDDirector.h"

// @implementation CCTexture2D(NDUI)
// 
// - (void)ndDrawInRect:(CCRect)rect
// {
// 	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
// 	
// 	GLfloat	 coordinates[] = {  0.0f,	maxT_,
// 		maxS_,	maxT_,
// 		0.0f,	0.0f,
// 		maxS_,	0.0f  };
// 	
// 	GLfloat	vertices[] = {	
// 		rect.origin.x, winSize.height - rect.size.height - rect.origin.y,
// 		rect.origin.x + rect.size.width, winSize.height - rect.size.height - rect.origin.y,
// 		rect.origin.x, winSize.height - rect.origin.y,
// 		rect.origin.x + rect.size.width, winSize.height - rect.origin.y};
// 	
// 	GLbyte colors[] = {255, 255, 255, 255, 
// 		255, 255, 255, 255, 
// 		255, 255, 255, 255, 
// 		255, 255, 255, 255};
// 	
// 	glBindTexture(GL_TEXTURE_2D, name_);
// 	glVertexPointer(2, GL_FLOAT, 0, vertices);
// 	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
// 	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
// 	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
// }
// 
// @end

