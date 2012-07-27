/***
*
*/

#ifndef NDDATASOURCE_H
#define NDDATASOURCE_H

#include "..\..\ui\inc\NDDataSource.h"

using namespace NDEngine;

class NDDataSource
{
public:
	NDDataSource();
	virtual ~NDDataSource();

//		函数：AddSection
//		作用：添加分区
//		参数：section分区对象指针
//		返回值：无
	void AddSection(NDSection* section);
//		
//		函数：InsertSection
//		作用：在某一分区索引插入分区
//		参数：index分区索引
//		返回值：无
	void InsertSection(unsigned int index, NDSection* section);
//		
//		函数：RemoveSection
//		作用：删除分区
//		参数：index分区索引
//		返回值：无
	void RemoveSection(unsigned int index);
//		
//		函数：Section
//		作用：获取分区对象指针
//		参数：index分区索引
//		返回值：分区
	NDSection* Section(unsigned int index);		
//		
//		函数：Clear
//		作用：清空分区
//		参数：无
//		返回值：无
	void Clear();
//		
//		函数：Count
//		作用：获取分区的数目
//		参数：无
//		返回值：分区数目
	unsigned int Count();
//		
//		函数：Copy
//		作用：深度拷贝数据集
//		参数：无
//		返回值：数据集
	NDDataSource* Copy();		

protected:
private:
};

#endif