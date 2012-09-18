//
//  NDDataSource.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDDataSource.h"

namespace NDEngine
{
	
	IMPLEMENT_CLASS(NDSection, NDObject)
	
	NDSection::NDSection()
	{
		m_uiColumnCount = 1;
		m_uiRowHeight = 28;
		m_uiFocusCellIndex = (unsigned int)-1;
		m_bUseCellHeight = false;
	}
	
	NDSection::~NDSection()
	{
		this->Clear();
	}
	
	void  NDSection::SetColumnCount(unsigned int columnCount)
	{ 
		if (columnCount == 0) 
			m_uiColumnCount = 1; 
		else
			m_uiColumnCount = columnCount; 
	}
	
	void NDSection::AddCell(NDUINode* cell)
	{
		m_vCells.push_back(cell);
	}
	
	void NDSection::InsertCell(unsigned int index, NDUINode* cell)
	{
		if (index >= m_vCells.size())
		{
			m_vCells.push_back(cell);
		}
		else 
		{
			std::vector<NDUINode*>::iterator iter = m_vCells.begin();
			for (unsigned int i = 0; i < index; i++, iter++);
			m_vCells.insert(iter, cell);
		}
	}
	
	void NDSection::RemoveCell(unsigned int index)
	{
		if (index < m_vCells.size())		 
		{
			std::vector<NDUINode*>::iterator iter = m_vCells.begin();
			for (unsigned int i = 0; i < index; i++, iter++);
			NDUINode* cell = (NDUINode*)*iter;	
			if (cell->GetParent()) 
			{
				cell->RemoveFromParent(true);
			}
			else 
				delete cell;	
			m_vCells.erase(iter);
		}
	}
	
	void NDSection::RemoveCell(NDUINode* cell)
	{
		std::vector<NDUINode*>::iterator iter;
		for (iter = m_vCells.begin(); iter != m_vCells.end(); iter++)
		{
			NDUINode* srcCell = (NDUINode*)*iter;
			if (cell == srcCell) 
			{
				if (cell->GetParent()) 
				{
					cell->RemoveFromParent(true);
				}
				else 
					delete cell;
				m_vCells.erase(iter);
				break;
			}
		}
	}
	
	NDUINode* NDSection::Cell(unsigned int index)
	{
		return m_vCells.at(index);
	}
	
	void NDSection::Clear()
	{
		if (!m_vCells.empty()) 
		{
			while (m_vCells.begin() != m_vCells.end()) 
			{
				NDUINode* cell = (NDUINode*)m_vCells.back();	
				if (cell->GetParent()) 
				{
					cell->RemoveFromParent(true);
				}
				else 
					delete cell;
				m_vCells.pop_back();
			}
		}
	}
	
	unsigned int NDSection::Count()
	{
		return m_vCells.size();
	}
	
	
	////////////////////////
	
	/***
	* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	* begin
	*/
	//IMPLEMENT_CLASS(NDDataSource, NDObject)
	
	//NDDataSource::NDDataSource()
	//{
	//}
	//
	//NDDataSource::~NDDataSource()
	//{
	//	this->Clear();
	//}	

	//void NDDataSource::AddSection(NDSection* section)
	//{
	//	m_sections.push_back(section);
	//}
	//
	//void NDDataSource::InsertSection(unsigned int index, NDSection* section)
	//{
	//	if (index >= m_sections.size())
	//	{
	//		m_sections.push_back(section);
	//	}
	//	else 
	//	{
	//		std::vector<NDSection*>::iterator iter = m_sections.begin();
	//		for (unsigned int i = 0; i < index; i++, iter++);
	//		m_sections.insert(iter, section);
	//	}
	//}
	//
	//void NDDataSource::RemoveSection(unsigned int index)
	//{
	//	if (index < m_sections.size())		 
	//	{
	//		std::vector<NDSection*>::iterator iter = m_sections.begin();
	//		for (unsigned int i = 0; i < index; i++, iter++);
	//		NDSection* section = (NDSection*)*iter;			
	//		delete section;
	//		m_sections.erase(iter);
	//	}
	//}
	//
	//NDSection* NDDataSource::Section(unsigned int index)	
	//{
	//	return m_sections.at(index);
	//}
	//
	//void NDDataSource::Clear()
	//{
	//	if (!m_sections.empty()) 
	//	{
	//		while (m_sections.begin() != m_sections.end()) 
	//		{
	//			NDSection* section = (NDSection*)m_sections.back();				
	//			delete section;
	//			m_sections.pop_back();
	//		}
	//	}
	//}
	//
	//unsigned int NDDataSource::Count()
	//{
	//	return m_sections.size();
	//}
	//
	//NDDataSource* NDDataSource::Copy()
	//{
	//	NDDataSource* dataSource = new NDDataSource();
	//	
	//	dataSource->m_sections = m_sections;
	//	
	//	return dataSource;
	//}
	/***
	* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	* end
	*/
}
