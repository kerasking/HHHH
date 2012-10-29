#ifndef _UPDATE_UTILITYS_H_
#define _UPDATE_UTILITYS_H_

//这里写一些公用的函数



namespace utility
{

//1. 解压指定zip文件至指定文件夹
	bool UnpackZipFile( const char* szZipFile, const char* szDstPath );

	//解析版本号 从字符型->数值型
	unsigned long ConvertVersionStrToValue( const char* pszVersion );












}










#endif //_UPDATE_UTILITYS_H_


