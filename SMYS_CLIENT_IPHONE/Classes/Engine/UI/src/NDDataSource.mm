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
		m_columnCount = 1;
		m_rowHeight = 28;
		m_focusCellIndex = (unsigned int)-1;
		m_useCellHeight = false;
	}
	
	NDSection::~NDSection()
	{
		this->Clear();
	}
	
	void  NDSection::SetColumnCount(unsigned int columnCount)
	{ 
		if (columnCount == 0) 
			m_columnCount = 1; 
		else
			m_columnCount = columnCount; 
	}
	
	void NDSection::AddCell(NDUINode* cell)
	{
		m_cells.push_back(cell);
	}
	
	void NDSection::InsertCell(unsigned int index, NDUINode* cell)
	{
		if (index >= m_cells.size())
		{
			m_cells.push_back(cell);
		}
		else 
		{
			std::vector<NDUINode*>::iterator iter = m_cells.begin();
			for (unsigned int i = 0; i < index; i++, iter++);
			m_cells.insert(iter, cell);
		}
	}
	
	void NDSection::RemoveCell(unsigned int index)
	{
		if (index < m_cells.size())		 
		{
			std::vector<NDUINode*>::iterator iter = m_cells.begin();
			for (unsigned int i = 0; i < index; i++, iter++);
			NDUINode* cell = (NDUINode*)*iter;	
			if (cell->GetParent()) 
			{
				cell->RemoveFromParent(true);
			}
			else 
				delete cell;	
			m_cells.erase(iter);
		}
	}
	
	void NDSection::RemoveCell(NDUINode* cell)
	{
		std::vector<NDUINode*>::iterator iter;
		for (iter = m_cells.begin(); iter != m_cells.end(); iter++)
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
				m_cells.erase(iter);
				break;
			}
		}
	}
	
	NDUINode* NDSection::Cell(unsigned int index)
	{
		return m_cells.at(index);
	}
	
	void NDSection::Clear()
	{
		if (!m_cells.empty()) 
		{
			while (m_cells.begin() != m_cells.end()) 
			{
				NDUINode* cell = (NDUINode*)m_cells.back();	
				if (cell->GetParent()) 
				{
					cell->RemoveFromParent(true);
				}
				else 
					delete cell;
				m_cells.pop_back();
			}
		}
	}
	
	unsigned int NDSection::Count()
	{
		return m_cells.size();
	}
	
	
	////////////////////////
	IMPLEMENT_CLASS(NDDataSource, NDObject)
	
	NDDataSource::NDDataSource()
	{
	}
	
	NDDataSource::~NDDataSource()
	{
		this->Clear();
	}	

	void NDDataSource::AddSection(NDSection* section)
	{
		m_sections.push_back(section);
	}
	
	void NDDataSource::InsertSection(unsigned int index, NDSection* section)
	{
		if (index >= m_sections.size())
		{
			m_sections.push_back(section);
		}
		else 
		{
			std::vector<NDSection*>::iterator iter = m_sections.begin();
			for (unsigned int i = 0; i < index; i++, iter++);
			m_sections.insert(iter, section);
		}
	}
	
	void NDDataSource::RemoveSection(unsigned int index)
	{
		if (index < m_sections.size())		 
		{
			std::vector<NDSection*>::iterator iter = m_sections.begin();
			for (unsigned int i = 0; i < index; i++, iter++);
			NDSection* section = (NDSection*)*iter;			
			delete section;
			m_sections.erase(iter);
		}
	}
	
	NDSection* NDDataSource::Section(unsigned int index)	
	{
		return m_sections.at(index);
	}
	
	void NDDataSource::Clear()
	{
		if (!m_sections.empty()) 
		{
			while (m_sections.begin() != m_sections.end()) 
			{
				NDSection* section = (NDSection*)m_sections.back();				
				delete section;
				m_sections.pop_back();
			}
		}
	}
	
	unsigned int NDDataSource::Count()
	{
		return m_sections.size();
	}
	
	NDDataSource* NDDataSource::Copy()
	{
		NDDataSource* dataSource = new NDDataSource();
		
		dataSource->m_sections = m_sections;
		
		return dataSource;
	}
}
