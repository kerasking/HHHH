#include "KIniFile.h"

KIniFile::KIniFile()
{

}

KIniFile::KIniFile( const KData &fileName, bool bOverwrite, bool bCreate )
{
	openIniFile( fileName, bOverwrite, bCreate );
}

KIniFile::~KIniFile()
{
	close();
}


bool KIniFile::openIniFile( const KData& fileName, bool bOverWrite, bool bCreate )
{
	FIELDS_ITER fieldIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
		delete *fieldIter;
	m_listField.clear();
	file.closeFile();
	if ( bOverWrite )
	{
		if ( !file.setFile(fileName,KFile::KFILE_READWRITE) )
		{
			return false;
		}
	}
	else
	{	
		if ( KFile::isFileExist(fileName) )
		{
			if ( !file.setFile(fileName, KFile::KFILE_READ) )
			{
				return false;
			}
		}
		else
		{
			if ( bCreate )
			{
				if ( !file.setFile(fileName,KFile::KFILE_READWRITE) )
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
	}
	m_dtFileName = fileName;
	if ( !parseFile() )
	{
		file.closeFile();
		return false;
	}
	file.closeFile();
	return true;
}


bool KIniFile::parseFile()
{
	char * pFileKData = new char[ file.getFileLen()+1 ];
	pFileKData[file.getFileLen()] = '\n';
	if ( file.getAllFileData( pFileKData ) == -1 )
	{
		delete[] pFileKData;
		return false;
	}
	KData dtFileKData = pFileKData;
	openIniData( dtFileKData );
	delete[] pFileKData;
	return true;
}


void KIniFile::openIniData( KData& dtFileKData )
{
	KData dtLine;
	KData dtItemL;
	list< KData > memoList;
	KIniField* pField = NULL;
	while( dtFileKData.match( "\n", &dtLine, true ) != NOT_FOUND )
	{
		dtLine.removeSpaces();
		dtLine.removeTab();
		dtLine.removeCRLF();
		
		if ( dtLine[(unsigned int)0] == '/' && dtLine[(unsigned int)1] == '/' )
		{
			memoList.push_back( dtLine );
			continue;
		}
		
		int zs = dtLine.find( ";" );
		if ( zs != -1 )
			dtLine = dtLine.substr( 0, zs );
		
		if ( dtLine[(unsigned int)0] == '[' )
		{
			int if2 = dtLine.findlast( "]" );
			if ( if2 != -1 )
			{
				KData dtField = dtLine.substr( 1, if2-1 );
				dtField.removeSpaces();
				dtField.removeTab();

				pField = new KIniField;
				pField->m_strName = dtField;
				pField->m_dtMemoList = memoList;
				memoList.clear();
				m_listField.push_back( pField );
				continue;
			}
		}

		KData dtMemo;
		if ( dtLine.find("//") != -1 )
		{
			dtMemo = dtLine;
			dtMemo.match( "//", &dtLine, true );
		}
		
		if ( NOT_FOUND == dtLine.match( '=', &dtItemL, true ) )
		{
			dtLine.removeSpaces();
			dtLine.removeTab();
			if ( !dtLine.isEmpty() && pField!=NULL )
			{
				pField->addItem( KIniItem( dtLine, "", dtMemo ) );
			}
		}
		else
		{
			if ( pField != NULL )
			{
				dtItemL.removeSpaces();
				dtItemL.removeTab();
				dtLine.removeSpaces();
				dtLine.removeTab();
				pField->addItem( KIniItem( dtItemL, dtLine, dtMemo ) );
			}
		}
	}
}


int KIniFile::getFieldNum()
{
	return (int)m_listField.size();
}

unsigned int KIniFile::getItemNum( const KData& fieldName )
{
	FIELDS_ITER fieldIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName, fieldName) )
			break;
	}
	if( fieldIter != m_listField.end() )
	{
		return (*fieldIter)->m_ItemList.size();
	}
	else
	{
		return 0;
	}
}


unsigned int KIniFile::getItemNum( unsigned int fieldIndex )
{
	if ( fieldIndex >= m_listField.size() )
		return 0;
	return m_listField[fieldIndex]->m_ItemList.size();
}


KData KIniFile::getFieldName( unsigned int fieldIndex )
{
	if ( fieldIndex >= m_listField.size() )
		return KData();
	return m_listField[fieldIndex]->m_strName;
}


int	KIniFile::getFieldIndex( const KData& fieldName )
{
	int index = -1;
	int i = 0;
	for ( FIELDS_ITER iter=m_listField.begin(); iter!=m_listField.end(); iter++ )
	{
		if ( isEqualNoCase((*iter)->m_strName,fieldName) )
		{
			index = i;
			break;
		}
		i++;
	}
	return index;
}


KIniField* KIniFile::getFieldPtr( const KData& fieldName )
{
	int i = 0;
	for ( FIELDS_ITER iter=m_listField.begin(); iter!=m_listField.end(); iter++ )
	{
		if ( isEqualNoCase((*iter)->m_strName,fieldName) )
		{
			return (*iter);
		}
		i++;
	}
	return NULL;
}


void KIniFile::removeField( const KData& fieldName )
{
	for ( FIELDS_ITER iter=m_listField.begin(); iter!=m_listField.end(); iter++ )
	{
		if ( isEqualNoCase((*iter)->m_strName,fieldName) )
		{
			delete (*iter);
			m_listField.erase( iter );
			return;
		}
	}	
}


KData KIniFile::getItemName( const KData& fieldName, unsigned int itemIndex )
{
	FIELDS_ITER fieldIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName,fieldName) )
			break;
	}
	if ( fieldIter == m_listField.end() )
	{
		return KData();
	}
	else
	{
		if ( itemIndex >= (*fieldIter)->m_ItemList.size() )
			return KData();
		return (*fieldIter)->m_ItemList[itemIndex].m_strName;
	}
}


void KIniFile::setItemStr( const KData& fieldName, const KData& itemName, const KData& itemVal )
{
	ITEMS_ITER itemIter;
	FIELDS_ITER fieldIter;
	KIniItem item( itemName, itemVal );
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName,fieldName) )
			break;
	}
	if ( fieldIter == m_listField.end() )
	{
		KIniField* pField = new KIniField;
		pField->m_strName = fieldName;
		pField->addItem( item );
		m_listField.push_back( pField );
	}
	else
	{
		for ( itemIter=(*fieldIter)->m_ItemList.begin(); itemIter!=(*fieldIter)->m_ItemList.end(); itemIter++ )
		{
			if ( isEqualNoCase(itemIter->m_strName,itemName) )
				break;
		}
		if ( itemIter == (*fieldIter)->m_ItemList.end() )
		{
			(*fieldIter)->addItem( item );
		}
		else
		{
			itemIter->m_strValue = itemVal;
		}
	}
}


void KIniFile::setItemInt( const KData& fieldName, const KData& itemName, int val )
{
	setItemStr( fieldName, itemName, KData(val) );
}


int KIniFile::getItemInt( const KData& fieldName, const KData& itemName )
{
	return atoi( getItemStr(fieldName,itemName) );
}


KData KIniFile::getItemName( unsigned int fieldIndex, unsigned int itemIndex )
{
	if ( fieldIndex >= m_listField.size() )
	{
		return KData();
	}
	if ( itemIndex >= m_listField[fieldIndex]->m_ItemList.size() )
		return KData();
	ITEMS_ITER itemIter = m_listField[fieldIndex]->m_ItemList.begin();
	for ( unsigned int i=0; i<itemIndex; i++ )
	{
		itemIter++;
	}
	return itemIter->m_strName;
}


KData KIniFile::getItemStr( const KData& fieldName, const KData& itemName )
{
	FIELDS_ITER fieldIter;
	ITEMS_ITER	itemIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName,fieldName) )
			break;
	}
	if ( fieldIter == m_listField.end() )
	{
		return KData();
	}
	else
	{
		for ( itemIter=(*fieldIter)->m_ItemList.begin(); itemIter!=(*fieldIter)->m_ItemList.end(); itemIter++ )
		{
			if ( isEqualNoCase(itemIter->m_strName,itemName) )
				break;
		}
		if( itemIter == (*fieldIter)->m_ItemList.end() )
		{
			return KData();
		}
		else
		{
			return itemIter->m_strValue;
		}
	}
}


KData KIniFile::getItemStr( unsigned int fieldIndex, const KData& itemName )
{
	ITEMS_ITER	itemIter;
	if ( fieldIndex >= m_listField.size() )
	{
		return KData();
	}
	KIniField* pField = &( *m_listField[fieldIndex] );
	for ( itemIter=pField->m_ItemList.begin(); itemIter!=pField->m_ItemList.end(); itemIter++ )
	{
		if ( isEqualNoCase(itemIter->m_strName,itemName) )
			break;
	}
	if ( itemIter == pField->m_ItemList.end() )
	{
		return KData();
	}
	else
	{
		return itemIter->m_strValue;
	}
}

KData KIniFile::getItemStr( unsigned int fieldIndex, unsigned int itemIndex )
{
	if ( fieldIndex >= m_listField.size() || itemIndex>=m_listField[fieldIndex]->m_ItemList.size() )
	{
		return KData();
	}
	return m_listField[fieldIndex]->m_ItemList[itemIndex].m_strValue;
}


KData KIniFile::getItemStr( const KData& fieldName, unsigned int itemIndex )
{
	FIELDS_ITER fieldIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName,fieldName) )
			break;
	}
	if ( fieldIter == m_listField.end() )
	{
		return KData();
	}
	else
	{
		if ( itemIndex > (*fieldIter)->m_ItemList.size() )
		{
			return KData("");
		}
		return (*fieldIter)->m_ItemList[itemIndex].m_strValue;
	}	
}


bool KIniFile::hasItem( const KData& fieldName, const KData& itemName )
{
	FIELDS_ITER fieldIter;
	ITEMS_ITER	itemIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName,fieldName) )
			break;
	}
	if ( fieldIter == m_listField.end() )
	{
		return false;
	}
	
	for ( itemIter=(*fieldIter)->m_ItemList.begin(); itemIter!=(*fieldIter)->m_ItemList.end(); itemIter++ )
	{
		if ( isEqualNoCase(itemIter->m_strName,itemName) )
			break;
	}
	if ( itemIter == (*fieldIter)->m_ItemList.end() )
	{
		return false;
	}
	return true;
}

int KIniFile::getItemInt( unsigned int fieldIndex, const KData& itemName )
{
	return atoi( getItemStr( fieldIndex, itemName ) );
}


int KIniFile::getItemIndex( const KData& fieldName, const KData& itemName )
{
	FIELDS_ITER fieldIter;
	ITEMS_ITER	itemIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		if ( isEqualNoCase((*fieldIter)->m_strName,fieldName) )
			break;
	}
	if ( fieldIter == m_listField.end() )
		return -1;
	int index = 0;
	for ( itemIter=(*fieldIter)->m_ItemList.begin(); itemIter!=(*fieldIter)->m_ItemList.end(); itemIter++ )
	{
		if ( isEqualNoCase(itemIter->m_strName,itemName) )
			break;
		index++;
	}
	if ( itemIter == (*fieldIter)->m_ItemList.end() )
		return -1;
	else
		return index;
}


bool KIniFile::saveIniFile()
{
	KData dtEq = "=";
	if ( m_dtFileName.isEmpty() )
		return false;
	if ( !file.setFile( m_dtFileName, KFile::KFILE_READWRITE ) )
		return false;
	FIELDS_ITER fieldIter;
	ITEMS_ITER itemIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		file.write( (unsigned char*)"[", 1 ); 
		file.write( (*fieldIter)->m_strName );
		file.write( (unsigned char*)"]", 1 );
		file.write( "\r\n" );
		for ( itemIter = (*fieldIter)->m_ItemList.begin(); itemIter!=(*fieldIter)->m_ItemList.end(); itemIter++ )
		{
			file.write( itemIter->m_strName );
			file.write( dtEq );
			file.write( itemIter->m_strValue );
			file.write( "\r\n" );
		}
		file.write( "\r\n" );
	}
	file.closeFile();
	return true;
}


void KIniFile::close()
{
	m_dtFileName.erase();
	FIELDS_ITER fieldIter;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
		delete *fieldIter;
	m_listField.clear();

}

unsigned  KIniFile::getAllItemNum()
{
	FIELDS_ITER fieldIter;
	unsigned int num = 0;
	for ( fieldIter=m_listField.begin(); fieldIter!=m_listField.end(); fieldIter++ )
	{
		num += (*fieldIter)->m_ItemList.size();
	}
	return num;
}
