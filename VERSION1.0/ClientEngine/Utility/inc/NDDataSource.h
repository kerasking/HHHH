/***
*
*/

#ifndef NDDATASOURCE_H
#define NDDATASOURCE_H

#include "..\..\ui\inc\NDDataSource.h"

using namespace NDEngine;

namespace NDEngine
{
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

	class NDSection : public NDObject
	{
		DECLARE_CLASS(NDSection)

		NDSection();
		~NDSection();

	public:
		//		
		//		函数：SetTitle
		//		作用：设置区的标题
		//		参数：title标题
		//		返回值：无
		void SetTitle(const char* title){ m_title = title; }
		//		
		//		函数：GetTitle
		//		作用：获取分区的标题
		//		参数：无
		//		返回值：标题
		std::string GetTitle(){ return m_title; }
		//		
		//		函数：SetColumnCount
		//		作用：设置分区的列数
		//		参数：columnCount列数
		//		返回值：无
		void SetColumnCount(unsigned int columnCount);
		//		
		//		函数：GetColumnCount
		//		作用：获取分区的列数
		//		参数：无
		//		返回值：列数
		unsigned int GetColumnCount(){ return m_columnCount; }
		//		
		//		函数：SetRowHeight
		//		作用：设置每一行的高度
		//		参数：rowHeight高度
		//		返回值：无
		void SetRowHeight(unsigned int rowHeight){ m_rowHeight = rowHeight; }
		//		
		//		函数：GetRowHeight
		//		作用：获取每一行的高度
		//		参数：无
		//		返回值：高度
		unsigned int GetRowHeight(){ return m_rowHeight; }

		void UseCellHeight(bool useCellHeight){ m_useCellHeight = useCellHeight; }
		bool IsUseCellHeight(){ return m_useCellHeight; }
		//		
		//		函数：SetFocusOnCell
		//		作用：设置焦点于某一单元格
		//		参数：单元格索引
		//		返回值：无
		void SetFocusOnCell(unsigned int cellIndex){ m_focusCellIndex = cellIndex; }
		//		
		//		函数：GetFocusCellIndex
		//		作用：获取焦点所在的单元格索引
		//		参数：无
		//		返回值：单元格索引
		unsigned int GetFocusCellIndex(){ return m_focusCellIndex; }
		//		
		//		函数：AddCell
		//		作用：添加单元格
		//		参数：cell单元格对象指针
		//		返回值：无
		void AddCell(NDUINode* cell);
		//		
		//		函数：InsertCell
		//		作用：在第几个索引位置插入单元格
		//		参数：index单元格索引，cell单元格
		//		返回值：无
		void InsertCell(unsigned int index, NDUINode* cell);
		//		
		//		函数：RemoveCell
		//		作用：删除单元格
		//		参数：index单元格索引
		//		返回值：无
		void RemoveCell(unsigned int index);
		//		
		//		函数：RemoveCell
		//		作用：删除单元格
		//		参数：index单元格索引
		//		返回值：无
		void RemoveCell(NDUINode* cell);
		//		
		//		函数：Cell
		//		作用：获取单元格
		//		参数：index单元格索引
		//		返回值：单元格
		NDUINode* Cell(unsigned int index);		
		//		
		//		函数：Clear
		//		作用：清空单元格
		//		参数：无
		//		返回值：无
		void Clear();
		//		
		//		函数：Count
		//		作用：获取单元格数量
		//		参数：无
		//		返回值：单元格数量
		unsigned int Count();

	private:

		std::vector<NDUINode*> m_cells;
		std::string m_title;
		unsigned int m_columnCount, m_rowHeight, m_focusCellIndex;
		bool m_useCellHeight;
	};
}

#endif