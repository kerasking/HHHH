#include "NDDataSource.h"
#include "ObjectTracker.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDSection,NDObject);

	NDDataSource::NDDataSource() {}
	NDDataSource::~NDDataSource() {} 
	void NDDataSource::AddSection( NDSection* section ){}
	void NDDataSource::InsertSection( unsigned int index, NDSection* section ){}
	void NDDataSource::RemoveSection( unsigned int index ){}
	void NDDataSource::Clear(){}

	unsigned int NDDataSource::Count()
	{
		return 0;
	}

	NDDataSource* NDDataSource::Copy()
	{
		return 0;
	}

	NDSection* NDDataSource::Section( unsigned int index )
	{
		return 0;
	}

	NDSection::NDSection(){ INC_NDOBJ_RTCLS }
	NDSection::~NDSection(){ DEC_NDOBJ_RTCLS }
	void NDSection::Clear(){}
	void NDSection::AddCell( NDUINode* cell ){}
	void NDSection::InsertCell( unsigned int index, NDUINode* cell ){}
	void NDSection::RemoveCell( unsigned int index ){}
	void NDSection::RemoveCell( NDUINode* cell ){}

	NDUINode* NDSection::Cell( unsigned int index )
	{
		return 0;
	}

	unsigned int NDSection::Count()
	{
		return 0;
	}
}