//
//  NDAutoPath.h
//  MapDataPool
//
//  Created by jhzheng on 10-12-13.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include <Foundation/Foundation.h>
#include "NDCompare.h"
#include <list>

@interface NDPathNode : NSObject <NDCompare>
{
	uint			_x,_y;			
	int			_h;				
	int			_g;
	int			_f;
	//int		_dir;
	//int		_flag;
	NSUInteger	_number;
	NDPathNode  *_parent;
}

@property(nonatomic, assign)uint x;						//节点的x坐标
@property(nonatomic, assign)uint y;						//节点的y坐标
@property(nonatomic, assign)int	h;						//节点的估值
@property(nonatomic, assign)int	g;						//路径的长度
@property(nonatomic, assign)int f;						//g+h
//@property(nonatomic, assign)int	dir;				//方向(上下左右)
//@property(nonatomic, assign)int	flag;				//扩展搜索的标志
@property(nonatomic, assign)NSUInteger number;			//查找key
@property(nonatomic, assign)NDPathNode *parent;			//扩展搜索的标志

@end


typedef std::list<void*>			nd_pnode_list;
typedef nd_pnode_list::iterator		nd_pnode_list_iter;

// 二分存储链表(值小的的靠前)
@interface NDParttionList : NSObject
{
	// 路径点链表
	nd_pnode_list	ndPnodeList;
}
- (void)pop_front;

- (id)front;

- (BOOL)partitionInsertObject:(id)obj;

- (void)clear;

@end