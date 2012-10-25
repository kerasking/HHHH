//
//  NDMapData.m
//  MapData
//
//  Created by jhzheng on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDMapData.h"
#import "NDTile.h"
#import "JavaMethod.h"
#import "NDPath.h"
#import "CCTextureCache.h"
#import "CCTexture2D.h"
#import "NDAnimationGroup.h"
#import "NDAnimationGroupPool.h"
#include "cpLog.h"
#include "CCConfiguration.h"
#import "CCTextureCacheExt.h"
#include "cpLog.h"
#include "WorldMapScene.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "define.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"
#import "NDWorldMapData.h"
#include "NDUtility.h"
//#include "SMUpdate.h"

/*
@implementation MapTexturePool

MapTexturePool *MapTexturePool_defaultPool = nil;

+ (MapTexturePool *)defaultPool
{
	if (!MapTexturePool_defaultPool)
		MapTexturePool_defaultPool = [[MapTexturePool alloc] init];
	
	return MapTexturePool_defaultPool;
}

+ (void)purgeDefaultPool
{
	[MapTexturePool_defaultPool release];
	MapTexturePool_defaultPool = nil;
}

+(id)alloc
{
	NDAsssert(MapTexturePool_defaultPool == nil);
	return [super alloc];
}


-(id) init
{
	if( (self=[super init]) ) {
		m_dict = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	}
	
	return self;
}

-(void) dealloc
{
	MapTexturePool_defaultPool = nil;
	[m_dict release];
	[super dealloc];
}

-(CCTexture2D*) addImage:(NSString *)path keepData:(BOOL)keep
{
	NDAsssert(path != nil);
	
	CCTexture2D * tex = nil;
	
	// MUTEX:
	// Needed since addImageAsync calls this method from a different thread
	
	tex = [m_dict objectForKey: path];	
	
	if (!tex) 
	{
        UIImage* image = NDPicture::GetUIImageFromFile([path UTF8String]);
		//UIImage *image = [ [UIImage alloc] initWithContentsOfFile: path ];
		tex = [ [CCTexture2D alloc] initWithImage:image keepData:keep];
		//[image release];
		
		if (tex) 
		{
			[m_dict setObject:tex forKey:path];
		}
		[tex release];
	}
	
	
	return tex;
}

@end

*/

#define IMAGE_PATH										\
			[NSString stringWithUTF8String:				\
			NDEngine::NDPath::GetImagePath().c_str()]

#define MAP_RES_PATH                        \
                      [NSString stringWithUTF8String:				\
                      NDEngine::NDPath::GetMapResPath().c_str()]

#define SWITCH_NAME_SIZE (12)

@implementation NDMapSwitch

@synthesize x = _x, y = _y, mapIndex = _mapIndex, passIndex = _passIndex, nameDesMap = _nameDesMap, descDesMap = _descDesMap;

- (void)SetLabel:(NDMapData*)mapdata; 
{
	if (mapdata == nil) 
	{
		return;
	}
	std::string name = NDCString("notopen"), des = "";
	int destMapId = [[NDWorldMapData SharedData] getDestMapIdWithSourceMapId:NDMapMgrObj.m_iMapDocID passwayIndex:_passIndex];
	if (destMapId > 0) 
	{
		PlaceNode *placeNode = [[NDWorldMapData SharedData] getPlaceNodeWithMapId:destMapId];
		if (placeNode) 
		{
			name = [placeNode.name UTF8String];
			des  = [placeNode.description UTF8String];
			
			int idx = des.find("（", 0);
			if (idx == -1) 
			{
				idx = des.find(NDCString("lianjiquyu"));
				if (idx != -1) 
				{
					des.erase(idx, des.size() - idx);
				}
			}
			else 
			{
				des.erase(idx, des.size() - idx);
			}
		}
		else 
		{
			name = NDCString("minyuecun");
			des  = NDCString("xinshou");
		}
		
		int tw = getStringSize(name.c_str(), 15).width;
		int tx = _x*mapdata.unitSize + 10 - tw / 2;			
		int ty = _y*mapdata.unitSize- 52;
		
		if (!des.empty() && des != "") {				
			int tx2 = _x*mapdata.unitSize  + 10 - (getStringSize(des.c_str(), 15).width / 2);
			int ty2 = _y*mapdata.unitSize - 52;//ty;
			//T.drawString2(g, introduce, tx2, ty2, 0xFFF5B4,0xC75900, 0);//后文字 0xFFF5B4, 0xC75900
			[self SetLableByType:1
							   X:tx2
							   Y:ty2
							Text:des.c_str()
						  Color1:INTCOLORTOCCC4(0xFFF5B4)
						  Color2:INTCOLORTOCCC4(0xC75900)
					  ParentSize:CGSizeMake([mapdata columns]*mapdata.unitSize, [mapdata rows]*mapdata.unitSize)
			 ];
			ty -= 20;
		}
		//T.drawString2(g, name, tx, ty, 0xFFFF00,0x2F4F4F,0);//0x2F4F4F
		[self SetLableByType:0
						   X:tx
						   Y:ty
						Text:name.c_str()
					  Color1:INTCOLORTOCCC4(0xFFFF00)
					  Color2:INTCOLORTOCCC4(0x2F4F4F)
				  ParentSize:CGSizeMake([mapdata columns]*mapdata.unitSize, [mapdata rows]*mapdata.unitSize)
		 ];
	}
}

- (void)SetLabelNew:(NDMapData *)mapdata
{
	float fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor();
	if (mapdata == nil) 
	{
		return;
	}
	
	std::string name = NDCString("notopen"), des = "";
	
	if (_descDesMap)
		des = [_descDesMap UTF8String];
	
	if (_nameDesMap) 
		name = [_nameDesMap UTF8String];

	int tw = getStringSize(name.c_str(), 15).width;
	int tx = _x*mapdata.unitSize + DISPLAY_POS_X_OFFSET - tw / 2;			
	int ty = _y*mapdata.unitSize + DISPLAY_POS_Y_OFFSET - 62 * fScaleFactor;
	
	if (!des.empty() && des != "") {				
		int tx2 = _x*mapdata.unitSize  + 10 * fScaleFactor - (getStringSize(des.c_str(), 15).width / 2);
		int ty2 = _y*mapdata.unitSize - 52 * fScaleFactor;//ty;
		//T.drawString2(g, introduce, tx2, ty2, 0xFFF5B4,0xC75900, 0);//后文字 0xFFF5B4, 0xC75900
		[self SetLableByType:1
						   X:tx2
						   Y:ty2
						Text:des.c_str()
					  Color1:INTCOLORTOCCC4(0xFFF5B4)
					  Color2:INTCOLORTOCCC4(0xC75900)
				  ParentSize:CGSizeMake([mapdata columns]*mapdata.unitSize, [mapdata rows]*mapdata.unitSize)
		 ];
		ty -= 20 /* fScaleFactor*/;
	}
	//T.drawString2(g, name, tx, ty, 0xFFFF00,0x2F4F4F,0);//0x2F4F4F
	[self SetLableByType:0
					   X:tx
					   Y:ty
					Text:name.c_str()
				  Color1:INTCOLORTOCCC4(0xFFFF00)
				  Color2:INTCOLORTOCCC4(0x2F4F4F)
			  ParentSize:CGSizeMake([mapdata columns]*mapdata.unitSize, [mapdata rows]*mapdata.unitSize)
	 ];
	
}

- (void)SetLableByType:(int)eLableType 
					 X:(int)x 
					 Y:(int)y 
				  Text:(const char*) text 
				Color1:(ccColor4B)color1 
				Color2:(ccColor4B)color2 
			ParentSize:(CGSize)sizeParent
{
	if (!text) 
	{
		return;
	}
	
	float fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor();
	
	NDUILabel *lable[2]; memset(lable, 0, sizeof(lable));
	if (eLableType == 0) 
	{
		if (!_lbName[0]) 
		{
			_lbName[0] = new NDUILabel;
			_lbName[0]->Initialization();
		}
		
		if (!_lbName[1]) 
		{
			_lbName[1] = new NDUILabel;
			_lbName[1]->Initialization();
		}
		
		lable[0] = _lbName[0];
		lable[1] = _lbName[1];
	}
	else if (eLableType == 1) 
	{
		if (!_lbDes[0]) 
		{
			_lbDes[0] = new NDUILabel;
			_lbDes[0]->Initialization();
		}
		
		if (!_lbDes[1]) 
		{
			_lbDes[1] = new NDUILabel;
			_lbDes[1]->Initialization();
		}
		
		lable[0] = _lbDes[0];
		lable[1] = _lbDes[1];
	}
	
	if (!lable[0] || !lable[1]) 
	{
		return;
	}
	
	lable[0]->SetText(text);
	lable[1]->SetText(text);
	
	lable[0]->SetFontColor(color1);
	lable[1]->SetFontColor(color2);
	
	lable[0]->SetFontSize(SWITCH_NAME_SIZE);
	lable[1]->SetFontSize(SWITCH_NAME_SIZE);
	
	CGSize sizewin  = NDDirector::DefaultDirector()->GetWinSize();
    CGSize textSize     = getStringSize(lable[0]->GetText().c_str(), lable[0]->GetFontSize());
	lable[1]->SetFrameRect(CGRectMake(x+1, y+sizewin.height+1-sizeParent.height, sizewin.width, 20 * fScaleFactor));
	lable[0]->SetFrameRect(CGRectMake(x, y+sizewin.height-sizeParent.height, sizewin.width, 20 * fScaleFactor));
}

- (void)draw
{
	if (_lbName[1]) {
		_lbName[1]->draw();
	}
	if (_lbName[0]) {
		_lbName[0]->draw();
	}
	
	if (_lbDes[1]) {
		_lbDes[1]->draw();
	}
	if (_lbDes[0]) {
		_lbDes[0]->draw();
	}
}

-(id)init
{
	if( (self=[super init]) ) 
	{
		memset(_lbName, 0, sizeof(_lbName));
		memset(_lbDes, 0, sizeof(_lbDes));
	}
	
	return self;
}

-(void)dealloc
{
	if (_lbName[0]) 
	{
		delete _lbName[0];
	}
	
	if (_lbName[1]) 
	{
		delete _lbName[1];
	}
	
	if (_lbDes[0]) 
	{
		delete _lbDes[0];
	}
	
	if (_lbDes[1]) 
	{
		delete _lbDes[1];
	}
	
	[_nameDesMap release];
	
	[_descDesMap release];
	
	[super dealloc];
}

@end

@implementation NDSceneTile

@synthesize orderID = _orderID;

@end

@implementation NDMapMonsterRange

@synthesize typeId = _typeId, column = _column, row = _row, boss = _boss;

@end

@interface NDMapData(hidden)
- (void)decode:(NSInputStream *)stream;
@end

@implementation NDMapData

@synthesize name = _name, file=_file,layerCount = _layerCount, columns = _columns, rows = _rows, aniGroupParams = _aniGroupParams,unitSize=_unitSize,mapTiles = _mapTiles, obstacles = _obstacles, sceneTiles = _sceneTiles,bgTiles=_bgTiles, switchs = _switchs, animationGroups = _animationGroups, /*roadBlockX =_roadBlockX,roadBlockY =_roadBlockY,*/needdownloadimgs =_needdownloadimgs, bReload = _bReload;


/*通过地图文件(不包含路径)加载地图数据
 参数:mapFile-地图文件名
 */
- (id)initWithFile:(NSString *)mapFile
{
    printf("OpenMapFile[%s]", [mapFile UTF8String]);
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
    _file = mapFile;
	//_roadBlockY=-1;
	//_roadBlockX=-1;
    _bReload=false;
	return self;
}

- (void)dealloc
{
	self.name = nil;	
	[_bgTiles release];
	[_mapTiles release];
	[_obstacles release];
	[_sceneTiles release];
	[_switchs release];
	[_animationGroups release];
	[_aniGroupParams release];
    [_needdownloadimgs release];
	//[[MapTexturePool defaultPool] release];
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
    _unitSize=_unitSize*0.5f*SCREEN_SCALE;
	int TileWidth		= _unitSize;
	int TileHeight	= _unitSize;
	//------------------->层数
	_layerCount = [stream readByte];
	//<-------------------列数
	_columns = [stream readByte];
	//------------------->行数
	_rows = [stream readByte];
	//<-------------------使用到的图块资源
    _bReload = false;
    _needdownloadimgs = [[NSMutableArray alloc] init];
	NSMutableArray	*_tileImages = [[NSMutableArray alloc] init];
	int tileImageCount = ([stream readByte] << 8) + [stream readByte];	
	for (int i = 0; i < tileImageCount; i++) 
	{
		int idx = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@/t%d.png", IMAGE_PATH,idx];//MAP_RES_PATH, idx];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) 
		{
			[_tileImages addObject:imageName];
		}
		else 
		{
            NSString *downimageName = [NSString stringWithFormat:@"t%d.png", idx];
            [_needdownloadimgs addObject:downimageName];
            _bReload = true;
			//return;
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
                if (imageIndex >= [_tileImages count]){
                    continue;
                }
				
				if([_tileImages count]>0)
				{
				NSString *imageName		= [_tileImages objectAtIndex:imageIndex];
				if (!imageName) {
					continue;
				}
                    
                /*HJQ MOD START*/
                NDTile* tile = [[NDTile alloc] init];
                tile.texture= NDPicturePool::DefaultPool()->AddTexture([imageName UTF8String]);
                    //[[CCTextureCache sharedTextureCache] addImage:imageName keepData:true]; 
				int PicParts	= tile.texture.pixelsWide * tile.texture.maxS / TileWidth;
				tile.cutRect	= CGRectMake(TileWidth*(tileIndex%PicParts), TileHeight*(tileIndex/PicParts), TileWidth, TileHeight);
				tile.drawRect	= CGRectMake(TileWidth*c, TileHeight*r, TileWidth, TileHeight);
				tile.reverse	= reverse;				
				[_mapTiles addObject:tile];
				[tile release];                    
                /*HJQ MOD END*/
				}
			}
	//<-------------------通行
	_obstacles = [[NSMutableArray alloc] init];
	for (uint i = 0; i < _columns*_rows; i++)
	{
		[_obstacles addObject:[NSNumber numberWithBool:YES]];
	}
	
	int notPassCount = ([stream readByte] << 8) + [stream readByte];	
	for (int i = 0; i < notPassCount; i++) 
	{		
		int	rowIndex	= [stream readByte];
		int columnIndex	= [stream readByte];
        int nIndex = rowIndex*_columns+columnIndex;
        if(nIndex < _columns*_rows)
        {
            [_obstacles replaceObjectAtIndex:(rowIndex*_columns+columnIndex) withObject:[NSNumber numberWithBool:NO]];
        }
        else
        {
            NDLog(@"notPassCount");
        }
        
	}
	//------------------->切屏
	_switchs = [[NSMutableArray alloc] init];
	int switchsCount = [stream readByte];
	for (int i = 0; i < switchsCount; i++) 
	{
		//NDMapSwitch *mapSwitch = [[NDMapSwitch alloc] init];
		
		/*mapSwitch.x = */[stream readByte]; //切屏点x
		/*mapSwitch.y = */[stream readByte]; //切屏点y
		/*mapSwitch.mapIndex = */[stream readByte]; //目标地图
		/*mapSwitch.passIndex = */[stream readByte]; //目标点
		/*[mapSwitch SetLabel:self];*/
		
		/*[_switchs addObject:mapSwitch];*/
		/*[mapSwitch release];*/
	}
	//<---------------------使用到的背景资源
		NSMutableArray	*_bgImages = [[NSMutableArray alloc] init];
	NSMutableArray	*_bgOrders = [[NSMutableArray alloc] init];
	int bgImageCount = ([stream readByte] << 8) + [stream readByte];
	for (int i = 0; i < bgImageCount; i++) 
	{
		int idx = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@/b%d.png", IMAGE_PATH,idx];// MAP_RES_PATH, idx];
printf("ImageName[%s]",[imageName UTF8String]);
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) 
		{
			[_bgImages addObject:imageName];
		}
		else 
		{
            NSString *downimageName = [NSString stringWithFormat:@"b%d.png",idx];
            [_needdownloadimgs addObject:downimageName];
            _bReload = true;
			NDLog(@"背景资源%@没有找到!!!需要下载！", downimageName);
			//[_bgImages addObject:imageName];
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
		
        if (resourceIndex >= [_bgImages count]){
            continue;
        }
		NSString *imageName		= [_bgImages objectAtIndex:resourceIndex];
		if (!imageName) {
			continue;
		}
		
   /*HJQ  MODIFY START*/
		NDSceneTile	*tile = [[NDSceneTile alloc] init];
		tile.orderID	= [[_bgOrders objectAtIndex:resourceIndex] intValue] + y;
		tile.texture	= NDPicturePool::DefaultPool()->AddTexture([imageName UTF8String]);
        //tile.texture = [[CCTextureCache sharedTextureCache] addImage:imageName];
        /*HJQ MOD*/
        //tile.texture =[[MapTexturePool defaultPool] addImage:imageName keepData:true];
		int picWidth	= tile.texture.pixelsWide * tile.texture.maxS; 
		int picHeight	= tile.texture.pixelsHigh * tile.texture.maxT;
		
		tile.mapSize	= CGSizeMake(self.columns*TileWidth, self.rows*TileHeight);
		tile.cutRect	= CGRectMake(0, 0, picWidth, picHeight);
		tile.drawRect	= CGRectMake(x*MAP_SCALE, y*MAP_SCALE, picWidth*MAP_SCALE, picHeight*MAP_SCALE);
		tile.reverse	= reverse;	
		
		[tile make];
		
		[_bgTiles addObject:tile];
		[tile release];
        //delete ptile_pic;
    /*HJQ  MODIFY END*/
	}
	//<-------------------使用到的布景资源
	NSMutableArray	*_sceneImages = [[NSMutableArray alloc] init];
	NSMutableArray	*_sceneOrders = [[NSMutableArray alloc] init];
	int sceneImageCount = ([stream readByte] << 8) + [stream readByte];
	for (int i = 0; i < sceneImageCount; i++) 
	{
		int idx = ([stream readByte] << 8) + [stream readByte];
		NSString *imageName = [NSString stringWithFormat:@"%@/s%d.png", IMAGE_PATH,idx];//MAP_RES_PATH, idx];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imageName]) 
		{
			[_sceneImages addObject:imageName];
		}
		else 
		{
            NSString *downimageName = [NSString stringWithFormat:@"s%d.png", idx];
            [_needdownloadimgs addObject:downimageName];
            _bReload = true;
			NDLog(@"布景资源%@没有找到!!!", imageName);
			//[_sceneImages addObject:imageName];;
		}
		
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
		
        if (resourceIndex >= [_sceneImages count]){
            continue;
        }
		NSString *imageName		= [_sceneImages objectAtIndex:resourceIndex];
		if (!imageName) {
			continue;
		}
		
		NDSceneTile	*tile = [[NDSceneTile alloc] init];
		tile.orderID	= [[_sceneOrders objectAtIndex:resourceIndex] intValue] + y;
        tile.texture = NDPicturePool::DefaultPool()->AddTexture([imageName UTF8String]);
		/*HJQ MOD*/
        //tile.texture = [[CCTextureCache sharedTextureCache] addImage:imageName];
        //tile.texture = [[MapTexturePool defaultPool] addImage:imageName keepData:true];
		int picWidth	= tile.texture.pixelsWide * tile.texture.maxS; 
		int picHeight	= tile.texture.pixelsHigh * tile.texture.maxT;
		
		tile.mapSize	= CGSizeMake(self.columns*TileWidth, self.rows*TileHeight);
		tile.cutRect	= CGRectMake(0, 0, picWidth, picHeight);
		tile.drawRect	= CGRectMake(x*MAP_SCALE, y*MAP_SCALE, picWidth*MAP_SCALE, picHeight*MAP_SCALE);
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
		[dict setObject:[NSNumber numberWithInt:_columns * _unitSize] forKey:@"mapSizeW"];
		[dict setObject:[NSNumber numberWithInt:_rows * _unitSize] forKey:@"mapSizeH"];
		int aniOrder = y + (short)(([stream readByte] << 8) + [stream readByte]);	//排序重心
		[dict setObject:[NSNumber numberWithInt:aniOrder] forKey:@"orderId"];
		
		[_aniGroupParams addObject:dict];
		[dict release];	
	}
	//------------------->刷怪区
	NSMutableArray	*_monsterRanges = [[NSMutableArray alloc] init];
	int monsterRangeCount = [stream readByte];
	for (int i = 0; i < monsterRangeCount; i++) 
	{
		NDMapMonsterRange *monsterRange = [[NDMapMonsterRange alloc] init];
		
		monsterRange.typeId = [stream readInt];
		monsterRange.column = [stream readByte];
		monsterRange.row = [stream readByte];
		monsterRange.boss = [stream readByte] != 0;
		
		[_monsterRanges addObject:monsterRange];
		[monsterRange release];
	}
	
	[_tileImages release];
	[_sceneImages release];
	[_sceneOrders release];
	[_monsterRanges release];
	[_bgImages release];
	[_bgOrders release];
    printf("downloadImage count[%d]", [_needdownloadimgs count]);
}
-(void) reload
{
    if (_bReload) {
        [self initWithFile:_file];
    }
}

/*判断某个位置是否可走
 参数:row-某行,column-某列
 返回值:YES/NO
 */
- (BOOL) canPassByRow:(uint) row andColumn:(uint) column
{
	if ( column >= self.columns || row >= self.rows ) {
		return NO;
	}
	if(row == NDMapMgrObj.roadBlockY)
	{
		return NO;
	}
	if(column == NDMapMgrObj.roadBlockX)
	{
		return NO;
	}
	return [[_obstacles objectAtIndex:(row*self.columns+column)] boolValue];
}


- (NDSceneTile *)getBackGroundTile:(uint)index
{
	
	
	
	if (index>=[_bgTiles count]) 
	{
		return nil;
	}else
	{	
		return [_bgTiles objectAtIndex:index];
	}

}

- (void) moveBackGround:(int)x moveY:(int)y
{
	
	if(x ==0)
		return;
	for(int i= 0; i< [_bgTiles count]; i++)
	{
		NDSceneTile* pTile = [self getBackGroundTile:i];
		if(pTile)
		{
			CGRect rect = pTile.drawRect;
			rect.origin.x -= -x/3;
			pTile.drawRect = rect;
			[pTile make];
			
		}
	}	
	
}


//- (NDTile *)getTileAtRow:(uint)row column:(uint)column
- (CustomCCTexture2D *)getTileAtRow:(uint)row column:(uint)column
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
	if (index>=[_mapTiles count]) 
	{
		return nil;
	}else
	{
	return [_mapTiles objectAtIndex:index];
	}
}

- (void)addObstacleCell:(uint)row andColumn:(uint)column
{
	if (row >= _rows || row < 0) 
	{
		return;
	}
	if (column >= _columns || column < 0) 
	{
		return;
	}
	
	[_obstacles replaceObjectAtIndex:(row*_columns+column) withObject:[NSNumber numberWithBool:NO]];
}

- (void)removeObstacleCell:(uint)row andColumn:(uint)column
{
	if (row >= _rows || row < 0) 
	{
		return;
	}
	if (column >= _columns || column < 0) 
	{
		return;
	}
	
	[_obstacles replaceObjectAtIndex:(row*_columns+column) withObject:[NSNumber numberWithBool:YES]];
}

- (void)addMapSwitch:(uint)x			// 切屏点 x
				   Y:(uint)y			// 切屏点 y
			   Index:(uint)index		// 切屏点索引
			DesMapID:(uint)mapid		// 目标地图id
		  DesMapName:(NSString*)name	// 目标地图名称
		  DesMapDesc:(NSString*)desc	// 目标地图描述
{
	NDMapSwitch *mapSwitch = [[NDMapSwitch alloc] init];
	
	mapSwitch.x = x; //切屏点x
	mapSwitch.y = y; //切屏点y
	mapSwitch.mapIndex = mapid; //目标地图
	mapSwitch.passIndex = index; //目标点
	mapSwitch.nameDesMap = name;
	mapSwitch.descDesMap = desc;
	[mapSwitch SetLabelNew:self];
	
	[_switchs addObject:mapSwitch];
	[mapSwitch release];
}

@end

