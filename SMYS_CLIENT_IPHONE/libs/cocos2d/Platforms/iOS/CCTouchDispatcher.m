/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED


#import "CCTouchDispatcher.h"
#import "CCTouchHandler.h"

@implementation CCTouchDispatcher

@synthesize dispatchEvents;

static CCTouchDispatcher *sharedDispatcher = nil;

+(CCTouchDispatcher*) sharedDispatcher
{
	@synchronized(self) {
		if (sharedDispatcher == nil)
			sharedDispatcher = [[self alloc] init]; // assignment not done here
	}
	return sharedDispatcher;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		NSAssert(sharedDispatcher == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super allocWithZone:zone];
	}
	return nil; // on subsequent allocation attempts return nil
}

-(id) init
{
	if((self = [super init])) {
	
		dispatchEvents = YES;
		targetedHandlers = [[NSMutableArray alloc] initWithCapacity:8];
		standardHandlers = [[NSMutableArray alloc] initWithCapacity:4];
		
		handlersToAdd = [[NSMutableArray alloc] initWithCapacity:8];
		handlersToRemove = [[NSMutableArray alloc] initWithCapacity:8];
		
		toRemove = NO;
		toAdd = NO;
		toQuit = NO;
		locked = NO;

		handlerHelperData[kCCTouchBegan] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesBegan:withEvent:),@selector(ccTouchBegan:withEvent:),kCCTouchSelectorBeganBit};
		handlerHelperData[kCCTouchMoved] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesMoved:withEvent:),@selector(ccTouchMoved:withEvent:),kCCTouchSelectorMovedBit};
		handlerHelperData[kCCTouchEnded] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesEnded:withEvent:),@selector(ccTouchEnded:withEvent:),kCCTouchSelectorEndedBit};
		handlerHelperData[kCCTouchCancelled] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesCancelled:withEvent:),@selector(ccTouchCancelled:withEvent:),kCCTouchSelectorCancelledBit};
		//add by jhzheng 2012.4.13
		handlerHelperData[KCCTouchDoubleClick] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesDoubleClick:withEvent:),@selector(ccTouchDoubleClick:withEvent:),kCCTouchSelectorDoubleClickBit};
		_touchDownParam		= [[NSMutableArray alloc] initWithCapacity:7];
		_touchUpParam		= [[NSMutableArray alloc] initWithCapacity:7];
		[_touchDownParam addObject:@"touchesBegan"];
		[_touchUpParam addObject:@"touchesEnded"];
		_curPos = CGPointZero;
		_prePos = CGPointZero;
		_hadTapDown = NO;
	}
	
	return self;
}

-(void) dealloc
{
	[targetedHandlers release];
	[standardHandlers release];
	[handlersToAdd release];
	[handlersToRemove release];
	//add by jhzheng 2012.4.13
	[_touchDownParam release];
	[_touchUpParam release];
	[super dealloc];
}

//
// handlers management
//

#pragma mark TouchDispatcher - Add Hanlder

-(void) forceAddHandler:(CCTouchHandler*)handler array:(NSMutableArray*)array
{
	NSUInteger i = 0;
	
	for( CCTouchHandler *h in array ) {
		if( h.priority < handler.priority )
			i++;
		
		NSAssert( h.delegate != handler.delegate, @"Delegate already added to touch dispatcher.");
	}
	[array insertObject:handler atIndex:i];		
}

-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority
{
	CCTouchHandler *handler = [CCStandardTouchHandler handlerWithDelegate:delegate priority:priority];
	if( ! locked ) {
		[self forceAddHandler:handler array:standardHandlers];
	} else {
		[handlersToAdd addObject:handler];
		toAdd = YES;
	}
}

-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
{
	CCTouchHandler *handler = [CCTargetedTouchHandler handlerWithDelegate:delegate priority:priority swallowsTouches:swallowsTouches];
	if( ! locked ) {
		[self forceAddHandler:handler array:targetedHandlers];
	} else {
		[handlersToAdd addObject:handler];
		toAdd = YES;
	}
}

#pragma mark TouchDispatcher - removeDelegate

-(void) forceRemoveDelegate:(id)delegate
{
	// XXX: remove it from both handlers ???
	
	for( CCTouchHandler *handler in targetedHandlers ) {
		if( handler.delegate == delegate ) {
			[targetedHandlers removeObject:handler];
			break;
		}
	}
	
	for( CCTouchHandler *handler in standardHandlers ) {
		if( handler.delegate == delegate ) {
			[standardHandlers removeObject:handler];
			break;
		}
	}	
}

-(void) removeDelegate:(id) delegate
{
	if( delegate == nil )
		return;
	
	if( ! locked ) {
		[self forceRemoveDelegate:delegate];
	} else {
			// avoid invalid,released hander when toRemove, toAdd dealing in func("-(void) touches:(NSSet*)touches withEvent:(UIEvent*)event withTouchType:(unsigned int)idx;") 
		// add by jhzheng 2011.7.5
		for( CCTouchHandler *handler in handlersToAdd ) 
		{
			if (handler.delegate == delegate) 
			{
				[handlersToAdd removeObject:handler];
				return;
			}
		}
		

		[handlersToRemove addObject:delegate];
		toRemove = YES;
	}
}

#pragma mark TouchDispatcher  - removeAllDelegates

-(void) forceRemoveAllDelegates
{
	[standardHandlers removeAllObjects];
	[targetedHandlers removeAllObjects];
}
-(void) removeAllDelegates
{
	if( ! locked )
		[self forceRemoveAllDelegates];
	else
		toQuit = YES;
}

#pragma mark Changing priority of added handlers

-(CCTouchHandler*) findHandler:(id)delegate
{
	for( CCTouchHandler *handler in targetedHandlers ) {
		if( handler.delegate == delegate ) {
            return handler;
		}
	}
	
	for( CCTouchHandler *handler in standardHandlers ) {
		if( handler.delegate == delegate ) {
            return handler;
        }
	}
    return nil;
}

NSComparisonResult sortByPriority(id first, id second, void *context)
{
    if (((CCTouchHandler*)first).priority < ((CCTouchHandler*)second).priority)
        return NSOrderedAscending;
    else if (((CCTouchHandler*)first).priority > ((CCTouchHandler*)second).priority)
        return NSOrderedDescending;
    else 
        return NSOrderedSame;
}

-(void) rearrangeHandlers:(NSMutableArray*)array
{
    [array sortUsingFunction:sortByPriority context:nil];
}

-(void) setPriority:(int) priority forDelegate:(id) delegate
{
	NSAssert(delegate != nil, @"Got nil touch delegate!");
	
	CCTouchHandler *handler = nil;
    handler = [self findHandler:delegate];
    
    NSAssert(handler != nil, @"Delegate not found!");    
    
    handler.priority = priority;
    
    [self rearrangeHandlers:targetedHandlers];
    [self rearrangeHandlers:standardHandlers];
}

//
// dispatch events
//
-(void) touches:(NSSet*)touches withEvent:(UIEvent*)event withTouchType:(unsigned int)idx
{
	NSAssert(idx < kCCTouchMax, @"Invalid idx value");

	id mutableTouches;
	locked = YES;
	
	// optimization to prevent a mutable copy when it is not necessary
	unsigned int targetedHandlersCount = [targetedHandlers count];
	unsigned int standardHandlersCount = [standardHandlers count];	
	BOOL needsMutableSet = (targetedHandlersCount && standardHandlersCount);
	
	mutableTouches = (needsMutableSet ? [touches mutableCopy] : touches);

	struct ccTouchHandlerHelperData helper = handlerHelperData[idx];
	//
	// process the target handlers 1st
	//
	if( targetedHandlersCount > 0 ) {
		for( UITouch *touch in touches ) {
			for(CCTargetedTouchHandler *handler in targetedHandlers) {
				
				BOOL claimed = NO;
				if( idx == kCCTouchBegan ) {
					claimed = [handler.delegate ccTouchBegan:touch withEvent:event];
					if( claimed )
						[handler.claimedTouches addObject:touch];
				}
				// add by jhzheng 2012.4.13
				else if( idx == KCCTouchDoubleClick ) {
					claimed = [handler.delegate ccTouchDoubleClick:touch withEvent:event];
				}
				
				// else (moved, ended, cancelled)
				else if( [handler.claimedTouches containsObject:touch] ) {
					claimed = YES;
					if( handler.enabledSelectors & helper.type )
						[handler.delegate performSelector:helper.touchSel withObject:touch withObject:event];
					
					if( helper.type & (kCCTouchSelectorCancelledBit | kCCTouchSelectorEndedBit) )
						[handler.claimedTouches removeObject:touch];
				}
					
				if( claimed && handler.swallowsTouches ) {
					if( needsMutableSet )
						[mutableTouches removeObject:touch];
					break;
				}
			}
		}
	}
	
	//
	// process standard handlers 2nd
	//
	if( standardHandlersCount > 0 && [mutableTouches count]>0 ) {
		for( CCTouchHandler *handler in standardHandlers ) {
			if( handler.enabledSelectors & helper.type )
				[handler.delegate performSelector:helper.touchesSel withObject:mutableTouches withObject:event];
		}
	}
	if( needsMutableSet )
		[mutableTouches release];
	
	//
	// Optimization. To prevent a [handlers copy] which is expensive
	// the add/removes/quit is done after the iterations
	//
	locked = NO;
	if( toRemove ) {
		toRemove = NO;
		for( id delegate in handlersToRemove )
			[self forceRemoveDelegate:delegate];
		[handlersToRemove removeAllObjects];
	}
	if( toAdd ) {
		toAdd = NO;
		for( CCTouchHandler *handler in handlersToAdd ) {
			Class targetedClass = [CCTargetedTouchHandler class];
			if( [handler isKindOfClass:targetedClass] )
				[self forceAddHandler:handler array:targetedHandlers];
			else
				[self forceAddHandler:handler array:standardHandlers];
		}
		[handlersToAdd removeAllObjects];
	}
	if( toQuit ) {
		toQuit = NO;
		[self forceRemoveAllDelegates];
	}
}

/* comment by jhzheng 2012.4.13
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchBegan];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents ) 
		[self touches:touches withEvent:event withTouchType:kCCTouchMoved];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchCancelled];
}

*/

// add by jhzheng 2012.4.13
- (void)singleTapTown:(NSArray *)param
{
	NSArray* ary = param;
	NSString* cmd = [ary objectAtIndex:0];
	if ([cmd isEqual:@"touchesBegan"]) 
	{
		_curPos.x	= [(NSNumber*)[ary objectAtIndex:3] floatValue];
		_curPos.y	= [(NSNumber*)[ary objectAtIndex:4] floatValue];
		_prePos.x	= [(NSNumber*)[ary objectAtIndex:5] floatValue];
		_prePos.y	= [(NSNumber*)[ary objectAtIndex:6] floatValue];
		
		if( dispatchEvents )
		{
			[self touches:(NSSet *)[ary objectAtIndex:1] 
				withEvent:(UIEvent *)[ary objectAtIndex:2] 
			withTouchType:kCCTouchBegan];
			
			_hadTapDown = YES;
		}
	}
}

- (void)singleTapUp:(NSArray *)param
{
	NSArray* ary = param;
	NSString* cmd = [ary objectAtIndex:0];
	if ([cmd isEqual:@"touchesEnded"]) 
	{
		_curPos.x	= [(NSNumber*)[ary objectAtIndex:3] floatValue];
		_curPos.y	= [(NSNumber*)[ary objectAtIndex:4] floatValue];
		_prePos.x	= [(NSNumber*)[ary objectAtIndex:5] floatValue];
		_prePos.y	= [(NSNumber*)[ary objectAtIndex:6] floatValue];
		
		if( dispatchEvents )
			[self touches:(NSSet *)[ary objectAtIndex:1] 
				withEvent:(UIEvent *)[ary objectAtIndex:2] 
			withTouchType:kCCTouchEnded];
	}
}

- (void)singleTapMove:(NSArray *)param
{
	NSArray* ary = param;
	NSString* cmd = [ary objectAtIndex:0];
	if ([cmd isEqual:@"touchesMoved"]) 
	{
		_curPos.x	= [(NSNumber*)[ary objectAtIndex:3] floatValue];
		_curPos.y	= [(NSNumber*)[ary objectAtIndex:4] floatValue];
		_prePos.x	= [(NSNumber*)[ary objectAtIndex:5] floatValue];
		_prePos.y	= [(NSNumber*)[ary objectAtIndex:6] floatValue];
		
		if( dispatchEvents )
			[self touches:(NSSet *)[ary objectAtIndex:1] 
				withEvent:(UIEvent *)[ary objectAtIndex:2] 
			withTouchType:kCCTouchMoved];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch			= [touches anyObject];
	NSUInteger tapCount		= [touch tapCount];
	
	CGPoint curPos		= [touch locationInView:touch.view];
	CGPoint prePos		= [touch previousLocationInView:touch.view];
	
	switch (tapCount) {
		case 1:
		{
			_hadTapDown = NO;
			if ([_touchDownParam count] == 1)
			{
				[_touchDownParam addObject:touches];
				[_touchDownParam addObject:event];
				[_touchDownParam addObject:[NSNumber numberWithFloat:curPos.x]];
				[_touchDownParam addObject:[NSNumber numberWithFloat:curPos.y]];
				[_touchDownParam addObject:[NSNumber numberWithFloat:prePos.x]];
				[_touchDownParam addObject:[NSNumber numberWithFloat:prePos.y]];
			}
			else
			{
				[_touchDownParam replaceObjectAtIndex:1 withObject:touches];
				[_touchDownParam replaceObjectAtIndex:2 withObject:event];
				[_touchDownParam replaceObjectAtIndex:3 withObject:[NSNumber numberWithFloat:curPos.x]];
				[_touchDownParam replaceObjectAtIndex:4 withObject:[NSNumber numberWithFloat:curPos.y]];
				[_touchDownParam replaceObjectAtIndex:5 withObject:[NSNumber numberWithFloat:prePos.x]];
				[_touchDownParam replaceObjectAtIndex:6 withObject:[NSNumber numberWithFloat:prePos.y]];
			}
			[self performSelector:@selector(singleTapTown:)
			withObject:_touchDownParam afterDelay:.1];
		}
			break;
		case 2:
			_curPos = curPos;
			_prePos = prePos;
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(singleTapTown:)
													   object:_touchDownParam];
			break;
		default:
			break;
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSMutableArray* touchMoveParam	= [[NSMutableArray alloc] initWithCapacity:3];
	[touchMoveParam addObject:@"touchesMoved"];
	[touchMoveParam addObject:touches];
	[touchMoveParam addObject:event];
	UITouch* touch		= (UITouch*)[touches anyObject];
	CGPoint curPos		= [touch locationInView:touch.view];
	CGPoint prePos		= [touch previousLocationInView:touch.view];
	[touchMoveParam addObject:[NSNumber numberWithFloat:curPos.x]];
	[touchMoveParam addObject:[NSNumber numberWithFloat:curPos.y]];
	[touchMoveParam addObject:[NSNumber numberWithFloat:prePos.x]];
	[touchMoveParam addObject:[NSNumber numberWithFloat:prePos.y]];
	
	if (_hadTapDown)
	{
		[self singleTapMove:touchMoveParam];
	}
	else
	{
		[self performSelector:@selector(singleTapMove:)
				   withObject:touchMoveParam afterDelay:.1];
	}
			   
			   
	[touchMoveParam release];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch			= [touches anyObject];
	NSUInteger tapCount		= [touch tapCount];
	
	CGPoint curPos		= [touch locationInView:touch.view];
	CGPoint prePos		= [touch previousLocationInView:touch.view];
	
	switch (tapCount) {
		case 0:
		case 1:
		{
			if ([_touchUpParam count] == 1)
			{
				[_touchUpParam addObject:touches];
				[_touchUpParam addObject:event];
				[_touchUpParam addObject:[NSNumber numberWithFloat:curPos.x]];
				[_touchUpParam addObject:[NSNumber numberWithFloat:curPos.y]];
				[_touchUpParam addObject:[NSNumber numberWithFloat:prePos.x]];
				[_touchUpParam addObject:[NSNumber numberWithFloat:prePos.y]];
			}
			else
			{
				[_touchUpParam replaceObjectAtIndex:1 withObject:touches];
				[_touchUpParam replaceObjectAtIndex:2 withObject:event];
				[_touchUpParam replaceObjectAtIndex:3 withObject:[NSNumber numberWithFloat:curPos.x]];
				[_touchUpParam replaceObjectAtIndex:4 withObject:[NSNumber numberWithFloat:curPos.y]];
				[_touchUpParam replaceObjectAtIndex:5 withObject:[NSNumber numberWithFloat:prePos.x]];
				[_touchUpParam replaceObjectAtIndex:6 withObject:[NSNumber numberWithFloat:prePos.y]];
			}
			[self performSelector:@selector(singleTapUp:)
					   withObject:_touchUpParam afterDelay:.1];
		}
			break;
		case 2:
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(singleTapUp:)
													   object:_touchUpParam];
			_curPos = curPos;
			_prePos = prePos;
			
			if( dispatchEvents )
				[self touches:touches 
					withEvent:event
				withTouchType:KCCTouchDoubleClick];
		}
			break;
		default:
			break;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchCancelled];
}

// add by jhzheng 2012.4.13
-(CGPoint)GetCurPos
{
	return _curPos;
}

-(CGPoint)GetPrePos
{
	return _prePos;
}

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
