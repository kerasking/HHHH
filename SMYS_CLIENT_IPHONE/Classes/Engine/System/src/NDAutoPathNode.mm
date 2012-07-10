//
//  NDAutoPath.mm
//  MapDataPool
//
//  Created by jhzheng on 10-12-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDAutoPathNode.h"

@implementation NDPathNode

@synthesize x = _x, y = _y, g = _g, h = _h, f = _f, number = _number, parent = _parent;

-(BOOL) compareEqualOtherObj:(id) otherObj
{
	return _h == [otherObj h];
}

-(BOOL) compareSmallThanOtherObj:(id) otherObj
{
	return _h < [otherObj h];
}

@end

////////////////////////////////////////////////////////

@interface NDParttionList(hidden)

- (nd_pnode_list_iter) findIterBegin:(nd_pnode_list_iter)begin To:(nd_pnode_list_iter)end ByObject:(id)obj;

@end

@implementation NDParttionList

//二分法寻找合适的插入位置
- (nd_pnode_list_iter) findIterBegin:(nd_pnode_list_iter)begin To:(nd_pnode_list_iter)end ByObject:(id)obj
{
	int nAmout = std::distance(begin, end);
	
	// 只有一个元素
	if ( nAmout == 1 ) {
		return begin;
	}
	
	// 与begin相等
	if ([(id)(*begin) compareEqualOtherObj:obj]) {
		return begin;
	}
	
	// 与end相等
	if ([(id)(*end) compareEqualOtherObj:obj]) {
		return end;
	}
	
	// 只有两个节点
	if ( nAmout == 2 ) {
		// 比begin小
		if (![(id)(*begin) compareSmallThanOtherObj:obj]) {
			return begin;
		}
		
		return end;
	}
	
	int i = nAmout/2;
	
	nd_pnode_list_iter	midIter = begin;
	
	while (i--) {
		midIter++;
	}
	
	// 与mid相等
	if ([(id)(*midIter) compareEqualOtherObj:obj]) {
		begin = midIter;
		return begin;
	}
	
	if([(id)(*midIter) compareSmallThanOtherObj:obj])
	{
		// 小于
		begin = midIter;
	}
	else
	{
		// 大于
		end = midIter;
	}
	
	return [self findIterBegin:begin To:end ByObject:obj];
}

- (BOOL)partitionInsertObject:(id)obj
{
	// 一个元素都没有
	if (ndPnodeList.empty()) {
		ndPnodeList.push_back(obj);
		return YES;
	}
	
	// 找出适合的位置
	nd_pnode_list_iter	begin = ndPnodeList.begin();
	nd_pnode_list_iter	end   = ndPnodeList.end()--;
	nd_pnode_list_iter	insert;

	insert = [self findIterBegin:begin To:end ByObject:obj];
	
	BOOL bRet = NO;
	
	if ( [(id)(*insert) compareEqualOtherObj:obj]
		|| ![(id)(*insert) compareSmallThanOtherObj:obj] ) {
		// 小等于,插入到前面
		ndPnodeList.insert(insert, obj);
		bRet = YES;
	}else{
		// 大于
		if (insert == ndPnodeList.end()--) {
			ndPnodeList.push_back(obj);
			bRet = YES;
		}else {
			insert++;
			ndPnodeList.insert(insert, obj);
			bRet = YES;
		}
		
	}
	
	return bRet;
}

- (void)pop_front
{
	if (!ndPnodeList.size()) {
		return;
	}
	ndPnodeList.pop_front();
}

- (id)front
{
	if (!ndPnodeList.size()) {
		return nil;
	}
	return (id)( ndPnodeList.front() );
}

- (void)clear
{
	ndPnodeList.clear();
}

- (id)init
{
	if ((self = [super init])) {
		ndPnodeList.clear();
	}
	return self;
}

@end