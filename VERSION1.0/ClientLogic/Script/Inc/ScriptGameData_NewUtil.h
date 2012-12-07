/*
 *  ScriptGameData_NewUtil.h
 *  DragonDrive
 *
 *  Created by zhangwq on 12-12-7.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *	
 *	说明：	新的数据库机制
 *
 *			这些类不是容器，而且工具类，用来更方便访问数据库
 *			更重要的是：确保接口兼容，否则LUA脚本需要大范围重写~
 */
 
#pragma once

#include "ScriptGameData_New.h"

#define NS_NDGAMEDATAUTIL_BGN	namespace NDGameDataUtil {
#define NS_NDGAMEDATAUTIL_END	}

NS_NDGAMEDATAUTIL_BGN


/////////////////////////////////////////////////////////////////////////////////////////

//公用
struct Util
{
#if 1 //get table,record,field...
	//取表集组
	static NDTableSetGroup* getTableSetGroup( const DATATYPE_MAJOR majorType )
	{
		// fast
		return NDGameData::Instance().getAt( majorType );
	}

	//取表集（id can be player id, npc id...）
	static NDTableSet* getTableSet( const DATATYPE_MAJOR majorType, const ID id )
	{
		// fast
		NDTableSet* pTableSet = NULL;
		NDTableSetGroup* pTableSetGroup = getTableSetGroup( majorType );
		if (pTableSetGroup)
		{
			if (majorType == eMJR_DataBase) //INI
			{
				pTableSet = pTableSetGroup->getSingle( true );
			}
			else
			{
				pTableSet = pTableSetGroup->getById( id, true ); //autoAlloc
			}
		}
		assert(pTableSet);
		return pTableSet;
	}

	//取表集（INI专用）
	static NDTableSetIni* getTableSet_ini()
	{
		NDTableSetIni* pTableSetIni = NULL;
		NDTableSet* pTableSet = getTableSet( eMJR_DataBase, 0 );
		if (pTableSet)
		{
			pTableSetIni = pTableSet->castIni();
		}
		assert(pTableSetIni);
		return pTableSetIni;
	}

	//取表
	static NDTable* getTable( const NDTablePtr& tablePtr )
	{
		// normal
		if (tablePtr.majorType == eMJR_DataBase)
		{
			NDTableSetIni* pTableSetIni = getTableSet_ini();
			if (pTableSetIni)
			{
				return pTableSetIni->getAt_INI( tablePtr.id );
			}
		}
		else
		{
			NDTableSet* pTableSet = getTableSet( tablePtr.majorType, tablePtr.id );
			if (pTableSet)
			{
				return pTableSet->getAt( tablePtr.minorType );
			}
		}
		return NULL;
	}

	//取记录
	static NDRecord* getRecord( const NDTablePtr& tablePtr, const ID idRecord )
	{
		// slow
		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			return pTable->getById( idRecord );
		}
		return NULL;
	}

	//取字段
	static NDField* getField( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr )
	{
		//very slow !
		NDRecord* pRecord = getRecord( tablePtr, cellPtr.idRecord );
		if (pRecord)
		{
			return pRecord->getAt( cellPtr.fieldIndex );
		}
		return NULL;
	}
#endif 

#if 2 //getter
	//get number
	static double getDataN( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr )
	{
		//very slow !
		NDField* pField = NDGameDataUtil::Util::getField( tablePtr, cellPtr );
		if (pField)
		{
			return pField->getDouble();
		}
		return 0.0;
	}

	//get float
	static float getDataF( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr )
	{
		//very slow !
		NDField* pField = NDGameDataUtil::Util::getField( tablePtr, cellPtr );
		if (pField)
		{
			return pField->getFloat();
		}
		return 0.0f;
	}

	//get string
	static const string& getDataS( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr )
	{
		//very slow !
		NDField* pField = NDGameDataUtil::Util::getField( tablePtr, cellPtr );
		if (pField)
		{
			return pField->getStr();
		}
		return "";
	}

	//get long long
	static unsigned long long getDataULL( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr )
	{
		//very slow
		NDField* pField = getField( tablePtr, cellPtr );
		if (pField)
		{
			pField->getBigInt();
		}
		return 0L;
	}
#endif 

#if 3 //setter
	//set number
	static bool setDataN( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr,
							const double number )
	{
		//very slow !
		NDField* pField = NDGameDataUtil::Util::getField( tablePtr, cellPtr );
		if (pField)
		{
			pField->setDouble( number );
			return true;
		}
		return false;
	}

	//set float
	static bool setDataF( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr,
							const float fValue )
	{
		//very slow !
		NDField* pField = NDGameDataUtil::Util::getField( tablePtr, cellPtr );
		if (pField)
		{
			pField->setFloat( fValue );
			return true;
		}
		return false;
	}

	//set string
	static bool setDataS( const NDTablePtr& tablePtr, const NDCellPtr& cellPtr,
							const char* str )
	{
		//very slow !
		NDField* pField = NDGameDataUtil::Util::getField( tablePtr, cellPtr );
		if (pField)
		{
			pField->setString( str );
			return true;
		}
		return false;
	}
#endif

#if 4 //del
	//del record
	static bool delRecordById( const NDTablePtr& tablePtr, const ID idRecord )
	{
		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			pTable->delById( idRecord );
		}
		return true;
	}

	//del table
	static bool delTable( const NDTablePtr& tablePtr )
	{
		NDTableSet* pTableSet = getTableSet( tablePtr.majorType, tablePtr.id );
		if (pTableSet)
		{
			pTableSet->delAt( tablePtr.minorType );
			return true;
		}
		return false;
	}

	//del tableset
	static bool delTableSet( const DATATYPE_MAJOR majorType, const ID id )
	{
		NDTableSetGroup* pTableSetGroup = getTableSetGroup( majorType );
		if (pTableSetGroup)
		{
			return pTableSetGroup->delById( id );
		}
		return false;
	}

	//del tablesetGroup
	static bool delTableSetGroup( const DATATYPE_MAJOR majorType )
	{
		return NDGameData::Instance().delAt( majorType );
	}

	//del all game data.
	static void destroyAll()
	{
		NDGameData::Instance().destroy();
	}
#endif

#if 5 //for role id
	//获取id列表
	static bool getDataIdList( const NDTablePtr& tablePtr, vector<ID>& out_idList )
	{
		out_idList.clear();

		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			return pTable->getIdList( out_idList );
		}
		return false;
	}
#endif 

#if 6
	//获取角色id列表
	static bool getRoleDataIdList( const NDTablePtr& tablePtr, 
		const ID idRole, const int idListIndex,
		vector<ID>& out_idList )
	{
		out_idList.clear();

		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			if (tablePtr.majorType == eMJR_DataBase) //ini
			{
				//not used: idRole & idListIndex
				return pTable->getIdList( out_idList );
			}
			else
			{
				return pTable->extra.getIdList( idRole, idListIndex, out_idList );
			}
		}
		return false;
	}

	//添加角色id到列表中
	static bool addRoleDataId( const NDTablePtr& tablePtr, 
		const ID idRole, const int idListIndex,
		const ID addId )
	{
		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			return pTable->extra.addId( idRole, idListIndex, addId );
		}
		return false;
	}

	//删除角色id（从列表中）
	static bool delRoleDataId( const NDTablePtr& tablePtr, 
		const ID idRole, const int idListIndex,
		const ID delId )
	{
		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			return pTable->extra.delId( idRole, idListIndex, delId );
		}
		return false;
	}

	//删除角色id列表
	static bool delRoleDataIdList( const NDTablePtr& tablePtr, 
		const ID idRole, const int idListIndex )
	{
		NDTable* pTable = getTable( tablePtr );
		if (pTable)
		{
			return pTable->extra.delIdList( idRole, idListIndex );
		}
		return false;
	}
#endif
};

NS_NDGAMEDATAUTIL_END
