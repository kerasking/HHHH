//
//  NDWorldMapData.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-5-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDWorldMapData.h"
#import "JavaMethod.h"
#import "NDPath.h"
#import "CCTextureCache.h"
#import "NDAnimationGroupPool.h"

@implementation PlaceNode

@synthesize placeId = _placeId, texture = _texture,  x = _x, y = _y, lDir = _lDir, rDir = _rDir, tDir = _tDir, bDir = _bDir, name = _name,description = _description;

- (void)dealloc
{
	[_name release];
	[_description release];
	[_texture release];
	[super dealloc];
}

@end

#define IMAGE_PATH	[NSString stringWithUTF8String:NDEngine::NDPath::GetImagePath().c_str()]

const int TileWidth		= 16;
const int TileHeight	= 16;

std::vector<PassWay> m_passWayInfos;

@implementation NDWorldMapData

@synthesize name = _name, layerCount = _layerCount, columns = _columns, rows = _rows, mapSize = _mapSize, placeNodes = _placeNodes,
mapTiles = _mapTiles, sceneTiles = _sceneTiles, bgTiles=_bgTiles,animationGroups = _animationGroups, aniGroupParams = _aniGroupParams;

NDWorldMapData *NDWorldMapData_SharedData = nil;
+ (id)SharedData
{
	if (NDWorldMapData_SharedData == nil)
	{
		NSString *mapFile = [NSString stringWithUTF8String:NDPath::GetMapPath().append("map_99999.map").c_str()];
		NDWorldMapData_SharedData = [[NDWorldMapData alloc] initWithFile:mapFile];
		
		if (m_passWayInfos.empty()) 
		{
			m_passWayInfos.push_back(PassWay(21001,0,23002));
			m_passWayInfos.push_back(PassWay(21001,1,23001));
			m_passWayInfos.push_back(PassWay(21002,2,23003));
			m_passWayInfos.push_back(PassWay(21002,1,23005));
			m_passWayInfos.push_back(PassWay(21002,0,23006));
			m_passWayInfos.push_back(PassWay(21003,0,23013));
			m_passWayInfos.push_back(PassWay(21003,1,23014));
			m_passWayInfos.push_back(PassWay(21003,2,23011));
			m_passWayInfos.push_back(PassWay(21005,0,23001));
			m_passWayInfos.push_back(PassWay(21006,0,23011));
			m_passWayInfos.push_back(PassWay(21006,1,23012));
			m_passWayInfos.push_back(PassWay(21006,2,23009));
			m_passWayInfos.push_back(PassWay(21007,0,23017));
			m_passWayInfos.push_back(PassWay(21007,1,23018));
			m_passWayInfos.push_back(PassWay(22001,0,23022));
			m_passWayInfos.push_back(PassWay(22003,0,23024));
			m_passWayInfos.push_back(PassWay(22004,0,23023));
			m_passWayInfos.push_back(PassWay(23001,0,21001));
			m_passWayInfos.push_back(PassWay(23001,1,21005));
			m_passWayInfos.push_back(PassWay(23002,0,23004));
			m_passWayInfos.push_back(PassWay(23002,1,21001));
			m_passWayInfos.push_back(PassWay(23003,1,23004));
			m_passWayInfos.push_back(PassWay(23003,0,21002));
			m_passWayInfos.push_back(PassWay(23004,0,23003));
			m_passWayInfos.push_back(PassWay(23004,1,23002));
			m_passWayInfos.push_back(PassWay(23005,0,21002));
			m_passWayInfos.push_back(PassWay(23005,1,23007));
			m_passWayInfos.push_back(PassWay(23006,0,21002));
			m_passWayInfos.push_back(PassWay(23007,0,23005));
			m_passWayInfos.push_back(PassWay(23007,1,23008));
			m_passWayInfos.push_back(PassWay(23008,0,23009));
			m_passWayInfos.push_back(PassWay(23008,1,23007));
			m_passWayInfos.push_back(PassWay(23009,0,21006));
			m_passWayInfos.push_back(PassWay(23009,1,23008));
			m_passWayInfos.push_back(PassWay(23009,2,23010));
			m_passWayInfos.push_back(PassWay(23010,0,23009));
			m_passWayInfos.push_back(PassWay(23010,1,23025));
			m_passWayInfos.push_back(PassWay(23011,0,21003));
			m_passWayInfos.push_back(PassWay(23011,1,21006));
			m_passWayInfos.push_back(PassWay(23012,0,21006));
			m_passWayInfos.push_back(PassWay(23013,0,23022));
			m_passWayInfos.push_back(PassWay(23013,1,23023));
			m_passWayInfos.push_back(PassWay(23013,2,23024));
			m_passWayInfos.push_back(PassWay(23013,3,21003));
			m_passWayInfos.push_back(PassWay(23014,0,23015));
			m_passWayInfos.push_back(PassWay(23014,1,21003));
			m_passWayInfos.push_back(PassWay(23014,2,23016));
			m_passWayInfos.push_back(PassWay(23015,0,23014));
			m_passWayInfos.push_back(PassWay(23016,0,23014));
			m_passWayInfos.push_back(PassWay(23016,1,23017));
			m_passWayInfos.push_back(PassWay(23017,0,23016));
			m_passWayInfos.push_back(PassWay(23017,1,21007));
			m_passWayInfos.push_back(PassWay(23018,0,21007));
			m_passWayInfos.push_back(PassWay(23018,1,23025));
			m_passWayInfos.push_back(PassWay(23022,0,22001));
			m_passWayInfos.push_back(PassWay(23022,1,23013));
			m_passWayInfos.push_back(PassWay(23023,0,22004));
			m_passWayInfos.push_back(PassWay(23023,1,23013));
			m_passWayInfos.push_back(PassWay(23024,0,23013));
			m_passWayInfos.push_back(PassWay(23024,1,22003));
			m_passWayInfos.push_back(PassWay(23025,0,23018));
			m_passWayInfos.push_back(PassWay(23025,1,23010));
		}		
	}
	return NDWorldMapData_SharedData;
}
/*通过地图文件(不包含路径)加载地图数据
 参数:mapFile-地图文件名
 */
- (id)initWithFile:(NSString *)mapFile
{
	if ((self = [super init])) 
	{		
		NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:mapFile];
		if (!stream) 
		{
			[self release];
			return nil;
		}
		[stream open];
		[self decode:stream];
		[stream close];
	}
	return self;
}

- (void)dealloc
{
	self.name = nil;	
	
	[_mapTiles release];
	[_sceneTiles release];
	[_animationGroups release];
	[_aniGroupParams release];
	[super dealloc];
}
/*  地图文件解析
 参数:地图文件流
 */

- (void)decode:(NSInputStream *)stream
{		
	//<-------------------地图名
	self.name = [stream readUTF8String];//[self readUTF8String:stream];
	//<-------------------单元格尺寸
	_unitSize=[stream readByte];
	int TileWidth		= _unitSize;
	int TileHeight	= _unitSize;
	//------------------->层数
	_layerCount = [stream readByte];
	//<-------------------列数
	_columns = [stream readByte];
	//------------------->行数
	_rows = [stream readByte];
	_mapSize = CGSizeMake(_columns << 5, _rows << 5);
	//<-------------------使用到的图块资源
	NSMutableArray	*_tileImages = [[NSMutableArray alloc] init];
	int tileImageCount = ([stream readByte] << 8) + [stream readByte];	
	for (int i = 0; i < tileImageCount; i++) 
	{
		int idx = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@t%d.png", IMAGE_PATH, idx];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) 
		{
			[_tileImages addObject:imageName];
		}
		else 
		{
			return;
		}
	}
	
	//------------------->瓦片	
	_mapTiles = [[NSMutableArray alloc] init];
	for ( int lay = 0; lay < _layerCount; lay++) 
		for (uint r = 0; r < _rows; r++) 
			for (uint c = 0; c < _columns; c++)
			{					
				int imageIndex		= [stream readByte] - 1;	//资源下标
				if (imageIndex == -1) 
					imageIndex = 0;
				int	tileIndex		= [stream readByte];		//图块下标
				BOOL reverse		= [stream readByte] == 1;	//翻转
				
				if (imageIndex == -1)
				{
					imageIndex = 0;
					//continue;
				}
				if([_tileImages count]>0)
				{
				NSString *imageName		= [_tileImages objectAtIndex:imageIndex];
				if (!imageName) {
					return;
				}
				
				NDTile *tile = [[NDTile alloc] init];
				tile.mapSize    = _mapSize;
				tile.texture	= [[CCTextureCache sharedTextureCache] addImage:imageName];
				int PicParts	= tile.texture.pixelsWide * tile.texture.maxS / TileWidth;
				tile.cutRect	= CGRectMake(TileWidth*(tileIndex%PicParts),
											 TileHeight*(tileIndex/PicParts), 
											 TileWidth, 
											 TileHeight);
				tile.drawRect	= CGRectMake(TileWidth*c,
											 TileHeight*r, 
											 TileWidth, 
											 TileHeight);
				tile.reverse	= reverse;
				[tile make];
				[_mapTiles addObject:tile];
				[tile release];		
				}
			}
	//<---------------------使用到的背景资源
	NSMutableArray	*_bgImages = [[NSMutableArray alloc] init];
	NSMutableArray	*_bgOrders = [[NSMutableArray alloc] init];
	int bgImageCount = ([stream readByte] << 8) + [stream readByte];
	for (int i = 0; i < bgImageCount; i++) 
	{
		int idx = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@b%d.png", IMAGE_PATH, idx];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) 
		{
			[_bgImages addObject:imageName];
		}
		else 
		{
			NDLog(@"背景资源%@没有找到!!!", imageName);
			[_bgImages addObject:imageName];
		}
		
		int v = ([stream readByte] << 8) + [stream readByte];
		[_bgOrders addObject:[NSNumber numberWithShort:(short)v]];
	}
	//---------------------->背景
	_bgTiles = [[NSMutableArray alloc] init];
	int bgCount = ([stream readByte] << 8) + [stream readByte];
	for (int i = 0; i < bgCount; i++) 
	{		
		int resourceIndex	= [stream readByte];										//资源下标
		int	x				= (short)(([stream readByte] << 8) + [stream readByte]);	//x坐标
		int y				= (short)(([stream readByte] << 8) + [stream readByte]);	//y坐标
		BOOL reverse		= [stream readByte] > 0;									//翻转
		
		NSString *imageName		= [_bgImages objectAtIndex:resourceIndex];
		if (!imageName) {
			continue;
		}
		
		NDSceneTile	*tile = [[NDSceneTile alloc] init];
		tile.orderID	= [[_bgOrders objectAtIndex:resourceIndex] intValue] + y;
		tile.texture	= [[CCTextureCache sharedTextureCache] addImage:imageName];
		int picWidth	= tile.texture.pixelsWide * tile.texture.maxS; 
		int picHeight	= tile.texture.pixelsHigh * tile.texture.maxT;
		
		tile.mapSize	= CGSizeMake(self.columns*TileWidth, self.rows*TileHeight);
		tile.cutRect	= CGRectMake(0, 0, picWidth, picHeight);
		tile.drawRect	= CGRectMake(x, y, picWidth, picHeight);
		tile.reverse	= reverse;	
		
		[tile make];
		
		[_bgTiles addObject:tile];
		[tile release];
	}
	//<-------------------使用到的布景资源
	NSMutableArray	*_sceneImages = [[NSMutableArray alloc] init];
	NSMutableArray	*_sceneOrders = [[NSMutableArray alloc] init];
	int sceneImageCount = ([stream readByte] << 8) + [stream readByte];	
	for (int i = 0; i < sceneImageCount; i++) 
	{
		int idx = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@s%d.png", IMAGE_PATH, idx];
		[_sceneImages addObject:imageName];
		
		int v = ([stream readByte] << 8) + [stream readByte];
		[_sceneOrders addObject:[NSNumber numberWithShort:(short)v]];
	}
	//------------------->布景
	_sceneTiles = [[NSMutableArray alloc] init];
	int sceneCount = ([stream readByte] << 8) + [stream readByte];
	for (int i = 0; i < sceneCount; i++) 
	{		
		int resourceIndex	= [stream readByte];										//资源下标
		int	x				= (short)(([stream readByte] << 8) + [stream readByte]);	//x坐标
		int y				= (short)(([stream readByte] << 8) + [stream readByte]);	//y坐标
		BOOL reverse		= [stream readByte] > 0;									//翻转
		
		NSString *imageName		= [_sceneImages objectAtIndex:resourceIndex];
		if (!imageName) {
			continue;
		}
		
		NDSceneTile	*tile = [[NDSceneTile alloc] init];
		tile.orderID	= [[_sceneOrders objectAtIndex:resourceIndex] intValue] + y;
		tile.texture	= [[CCTextureCache sharedTextureCache] addImage:imageName];
		int picWidth	= tile.texture.pixelsWide * tile.texture.maxS; 
		int picHeight	= tile.texture.pixelsHigh * tile.texture.maxT;
		
		tile.mapSize	= CGSizeMake(self.columns*TileWidth, self.rows*TileHeight);
		tile.cutRect	= CGRectMake(0, 0, picWidth, picHeight);
		tile.drawRect	= CGRectMake(x, y, picWidth, picHeight);
		tile.reverse	= reverse;	
		
		[tile make];
		
		[_sceneTiles addObject:tile];
		[tile release];
	}
	//<-------------------动画
	_animationGroups = [[NSMutableArray alloc] init];
	_aniGroupParams  = [[NSMutableArray alloc] init];
	int aniGroupCount = ([stream readByte] << 8) + [stream readByte];
	for (int i = 0; i < aniGroupCount; i++) 
	{			
		int identifer = ([stream readByte] << 8) + [stream readByte];				//动画id
		NDAnimationGroup *aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSceneAnimationId:identifer];//[[NDAnimationGroup alloc] initWithSceneAnimationId:identifer];//
		[_animationGroups addObject:aniGroup];
		[aniGroup release];
		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		
		[dict setObject:[NSNumber numberWithBool:NO] forKey:@"reverse"];
		int x = (short)(([stream readByte] << 8) + [stream readByte]);		//x坐标
		int y = (short)(([stream readByte] << 8) + [stream readByte]);		//y坐标
		[dict setObject:[NSNumber numberWithInt:x] forKey:@"positionX"];
		[dict setObject:[NSNumber numberWithInt:y] forKey:@"positionY"];		
		[dict setObject:[NSNumber numberWithInt:_columns * 16] forKey:@"mapSizeW"];
		[dict setObject:[NSNumber numberWithInt:_rows * 16] forKey:@"mapSizeH"];
		int aniOrder = y + (short)(([stream readByte] << 8) + [stream readByte]);	//排序重心
		[dict setObject:[NSNumber numberWithInt:aniOrder] forKey:@"orderId"];
		
		[_aniGroupParams addObject:dict];
		[dict release];	
	}
	//------------------->节点
	_placeNodes = [[NSMutableArray alloc] init];
	int nodeCount = [stream readByte];
	for (int i = 0; i < nodeCount; i++) 
	{
		PlaceNode *node = [[PlaceNode alloc] init];
		
		node.placeId = ([stream readByte] << 8) + [stream readByte];
		int imageIndex = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@o%d.png", IMAGE_PATH, imageIndex];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) 
		{
			node.texture = [[CCTextureCache sharedTextureCache] addImage:imageName];
		}		
		node.x = ([stream readByte] << 8) + [stream readByte];
		node.y = ([stream readByte] << 8) + [stream readByte];
		node.lDir = ([stream readByte] << 8) + [stream readByte];
		node.rDir = ([stream readByte] << 8) + [stream readByte];
		node.tDir = ([stream readByte] << 8) + [stream readByte];
		node.bDir = ([stream readByte] << 8) + [stream readByte];
		node.name = [stream readUTF8String];
		node.description = [stream readUTF8String];
		
		[_placeNodes addObject:node];
		[node release];
	}
	
	[_tileImages release];
	[_sceneImages release];
	[_sceneOrders release];
	
}

- (NDTile *)getTileAtRow:(uint)row column:(uint)column
{
	if (row >= _rows) 
	{
		return nil;
	}
	if (column >= _columns) 
	{
		return nil;
	}
	
	int index =	row * _columns + column;
	
	return [_mapTiles objectAtIndex:index];
}

- (int)getDestMapIdWithSourceMapId:(int)mapId passwayIndex:(int)passwayIndex
{		
	for (std::vector<PassWay>::iterator it = m_passWayInfos.begin(); it != m_passWayInfos.end(); it++)
	{
		PassWay& pw = *it;
		if (pw.fromMapID == mapId && pw.fromPassIndex == passwayIndex) 
		{
			return pw.desMapID;
		}
	}
	
	return 0;
}

- (PlaceNode *)getPlaceNodeWithMapId:(int)mapId
{
	PlaceNode *result = nil;
	for (NSUInteger i = 0; i < [_placeNodes count]; i++) 
	{
		PlaceNode *node = [_placeNodes objectAtIndex:i];
		if (node.placeId == mapId) 
		{
			result = node;
			break;
		}
	}
	return result;
}


@end

