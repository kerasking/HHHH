#include "..\inc\NDDataSource.h"

NDDataSource::NDDataSource(){}
NDDataSource::~NDDataSource(){}
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