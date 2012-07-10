#ifndef __KT_INIFILE_H
#define __KT_INIFILE_H

const int LINEBUFFLEN = 2046;

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <list>
#include <vector>
#include <string.h>
#include <algorithm>
#include "KData.h"
#include "KFile.h"


class KIniItem
{
public:
	KIniItem( const KIniItem& item )
	{
		m_strName = item.m_strName;
		m_strValue = item.m_strValue;
		m_strMemo = item.m_strMemo;
	}

	KIniItem( const KData& strName, const KData& strValue, const KData& strMemo="" )
	{
		m_strName = strName;
		m_strValue = strValue;
		m_strMemo = strMemo;
	}

	KIniItem( const KData& strName )
	{
		m_strName = strName;
	}

	virtual ~KIniItem()
	{
	}

public:	
	friend bool operator==( const KIniItem& item1, const KIniItem& item2 )
	{
		return ( item1.m_strName == item2.m_strName );
	}

	friend bool operator==( const KIniItem& item, const KData& dtName )
	{
		return ( item.m_strName == dtName );
	}

	friend bool operator!=( const KIniItem& item, const KData& dtName )
	{
		return ( item.m_strName != dtName );
	}

public:
	KData m_strName;
	KData m_strValue;
	KData m_strMemo;
};

typedef vector<KIniItem> ITEMS;
typedef vector<KIniItem>::iterator ITEMS_ITER;
class KIniField
{
public:
	KIniField(){};

	KIniField( const KIniField& field )
	{
		m_strName = field.m_strName;
		m_ItemList = field.m_ItemList;
	}

	KIniField( KData& strName )
	{
		m_strName = strName;
	}

	virtual ~KIniField()
	{
	}

	void addItem( const KIniItem& item )
	{
		m_ItemList.push_back( item );
	}

	friend bool operator==( const KIniField& field1, const KIniField& field2 )
	{
		return ( field1.m_strName == field2.m_strName );
	}

	friend bool operator==( const KIniField& field1, const char* strName )
	{
		return ( field1.m_strName == strName );
	}

	friend bool operator!=( const KIniField& field1, const char* strName )
	{
		return ( field1.m_strName != strName );
	}

public:
	KData	m_strName;
	list< KData > m_dtMemoList;
	ITEMS	m_ItemList;
};


typedef vector<KIniField*> FIELDS;
typedef vector<KIniField*>::iterator FIELDS_ITER;
class KIniFile  
{
public:
	KData	getItemStr( unsigned int fieldIndex, const KData& itemName  );
	KData	getItemStr( const KData& fieldName, const KData& itemName  );

	KData	getItemStr( unsigned int fieldIndex, unsigned int itemIndex );
	KData	getItemStr( const KData& fieldName, unsigned int itemIndex );

	void	setItemStr( const KData& fieldName, const KData& itemName, const KData& itemVal );
	void	setItemInt( const KData& fieldName, const KData& itemName, int val );

	KData	getItemName( unsigned int fieldIndex, unsigned int itemIndex );
	KData	getItemName( const KData&, unsigned int itemIndex );

	int		getItemInt( const KData& fieldName, const KData& itemName );
	int		getItemInt( unsigned int fieldIndex, const KData& itemName );

	int		getItemIndex( const KData& fieldName, const KData& itemName );

	KData	getFieldName( unsigned int fieldIndex );
	int		getFieldIndex( const KData& fieldName );
	KIniField* getFieldPtr( const KData& fieldName );

	bool	hasItem( const KData& fieldName, const KData& itemName );

	void	removeField( const KData& fieldName );

	unsigned int getItemNum( unsigned int fieldIndex );
	unsigned int getItemNum( const KData& fieldName );

	unsigned int getAllItemNum();

	bool	hasField();

	int		getFieldNum();
	bool	openIniFile( const KData& fileName, bool bOverWrite=false, bool bCreate=false );
	void	openIniData( KData& dtFileKData );
	bool	saveIniFile();
	void	close();

	KIniFile();
	KIniFile( const KData& fileName, bool bOverwrite = false, bool bCreate=false );

	virtual ~KIniFile();

private:
	bool	parseFile();

private:
	char		linebuf[LINEBUFFLEN];
	KData		m_dtFileName;
	FIELDS		m_listField;
	KFile		file;
};

#endif
