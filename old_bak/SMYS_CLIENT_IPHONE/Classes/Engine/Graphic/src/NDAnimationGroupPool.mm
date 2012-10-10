//
//  NDAnimationGroupPool.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDAnimationGroupPool.h"
#import "NDPath.h"
#import "JavaMethod.h"

using namespace NDEngine;

@implementation NDAnimationGroupPool

static NDAnimationGroupPool *NDAnimationGroupPool_DefaultPool = nil;
+ (NDAnimationGroupPool *)defaultPool
{
	if (!NDAnimationGroupPool_DefaultPool)
		NDAnimationGroupPool_DefaultPool = [[NDAnimationGroupPool alloc] init];
	
	return NDAnimationGroupPool_DefaultPool;
}

+ (void)purgeDefaultPool
{
	[NDAnimationGroupPool_DefaultPool release];
	NDAnimationGroupPool_DefaultPool = nil;
}

- (id)init
{
	NSAssert(NDAnimationGroupPool_DefaultPool == nil, @"must use static method defaultPool() to get the instance.");
	if ((self = [super init])) 
	{
		m_animationGroups = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[m_animationGroups release];
	NDAnimationGroupPool_DefaultPool = nil;
	[super dealloc];
}

- (NDAnimationGroup *)addObjectWithSpr:(NSString *)sprFile
{
	NDAnimationGroup *group = nil;
	
	group = [m_animationGroups objectForKey:sprFile];
	if (!group) 
	{
		group = [[NDAnimationGroup alloc] initWithSprFile:sprFile];
		if (group) 
		{
			[m_animationGroups setObject:group forKey:sprFile];
			//[group release];
		}		
	}
	else 
	{
		[group retain];
	}

	return group;
}

- (NDAnimationGroup *)addObjectWithModelId:(int)ModelId
{	
	NSString *animationPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];
	NSString *sprFile = [NSString stringWithFormat:@"%@model_%d.spr", animationPath, ModelId];
	return [self addObjectWithSpr:sprFile];
}

- (NDAnimationGroup *)addObjectWithSceneAnimationId:(int)SceneAnimationId
{	
	NSString *animationPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];
	NSString *sprFile = [NSString stringWithFormat:@"%@scene_ani_%d.spr", animationPath, SceneAnimationId];
	return [self addObjectWithSpr:sprFile];
}

- (void)removeObjectWithSpr:(NSString *)sprFile
{
	[m_animationGroups removeObjectForKey:sprFile];
}

- (void)removeObjectWithSceneAnimationId:(int)SceneAnimationId
{
	NSString *animationPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];
	NSString *sprFile = [NSString stringWithFormat:@"%@scene_ani_%d.spr", animationPath, SceneAnimationId];
	[self removeObjectWithSpr:sprFile];
}

- (void)Recyle
{
	if (nil == m_animationGroups)
	{
		return;
	}
	
	NSArray * allKeys = [m_animationGroups allKeys];
	
	if (nil == allKeys)
	{
		return;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray *recyle = [[NSMutableArray alloc] init];
	
	for (NSUInteger i = 0; i < [allKeys count]; i++) 
	{
		NSString* key	= [allKeys objectAtIndex:i];
		if (nil == key)
		{
			continue;
		}
		
		NDAnimationGroup *anigroup = [m_animationGroups objectForKey:key];
		if (nil == anigroup)
		{
			continue;
		}
		
		if (1 >= [anigroup retainCount])
		{
			[recyle addObject:key];
		}
	}
	
	if (0 < [recyle count])
	{
		[m_animationGroups removeObjectsForKeys:recyle];
	}
	
	[recyle release];
	[pool release];
}

@end
