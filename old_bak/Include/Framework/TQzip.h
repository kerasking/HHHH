#pragma once

/*
封装的框架自定义的资源打包格式
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/

#ifndef __TQZip__HEAD__FILE__
#define __TQZip__HEAD__FILE__

//本接口为资源打包回调
class ITQZipEvent
{
public:
	enum ERROR_CODE{
		ERRCODE_NONE=0,//正常

		ERRCODE_FILE_NOTEXIST,//文件不存在
		ERRCODE_FILE_ERRCREAT,//文件创建失败
		ERRCODE_FILE_ERRSAVE,//文件保存错误
		ERRCODE_FILE_ZEROSIZE,//0大小的文件
		ERRCODE_FUN_WRONGPARAM,//错误参数
		ERRCODE_MEMORY_INSUMEM,//Insufficient memory 内存分配不足
		ERRCODE_FORMAT_ERRFORMAT,//错误格式
		ERRCODE_OPERATION_STOPOP,//主动终止操作

		ERRCODE_UNKNOW,//未知错误

	};
public:
	//函数：打包过程的回调
	//参数：bOpContinue 是否终止打包操作
	//参数：nFileNum 要打包的总文件数
	//参数：nFileIndex 要打包的当前文件索引
	//参数：pszFileName 文件名，绝对路径
	virtual void OnCompressEvent(bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName){};

	//函数：解包过程的回调
	//参数：bOpContinue 是否终止解包操作
	//参数：nFileNum 要解包的总文件数
	//参数：nFileIndex 要解包的当前文件索引
	//参数：pszFileName 文件名，绝对路径
	virtual void OnUnCompressEvent(bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName){};

	//函数：操作错误的回调
	//参数：emErrCode 错误编码
	//参数：pszErrMsg 错误提示
	virtual void OnTQZipError(ERROR_CODE emErrCode,const char* pszErrMsg){};
	~ITQZipEvent(){};
};

class CTQZip
{
public:
	//函数：资源打包函数 注：输出的资源包为自定义的.TQZip格式
	//参数：pszSrcDir 要打包的资源目录
	//参数：pszDestDir 打包到
	//参数：pszFileName 打包后的资源名不含后缀
	//参数：pszNCFilter 此参数传入的文件后缀过滤（格式 .jpg|.exe|），被过滤的文件将不进行压缩直接打包
	//参数：ITQZipEvent 压缩过程回调
	//返回值：true 压缩成功 false 压缩失败
	static bool Compress(const char*pszSrcDir,const char*pszDestDir,const char*pszFileName,const char* pszNCFilter,ITQZipEvent *pTQZipEvent,bool bInUIThread = true);

	//函数：资源包解压函数 注：资源包为自定义的.TQZip格式
	//参数：pszSrcFile 资源包文件
	//参数：pszDestDir 解压目录
	//参数：ITQZipEvent 压缩过程回调
	//返回值：true 解压成功 false 解压失败
	static bool UnCompress(const char*pszSrcFile,const char*pszDestDir,ITQZipEvent *pTQZipEvent,bool bInUIThread = true);

};

#endif