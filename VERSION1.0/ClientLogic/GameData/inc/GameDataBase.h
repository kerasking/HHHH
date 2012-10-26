/*
 *  ScriptDataBase.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */
#if 0

#ifndef _SCRIPT_DATA_BASE_H_
#define _SCRIPT_DATA_BASE_H_

#include "globaldef.h"

#define ScriptDBObj	NDEngine::ScriptDB::GetSingleton()

namespace NDEngine {
	

	class ScriptDB : public TSingleton<ScriptDB>
	{
		public:
			//void Load();
			bool LoadTable(const char* inifilename, const char* indexfilename);
			unsigned int GetKey(const char* inifilename);
			int GetN(const char* inifilename, int nId, int nIndex);
			std::string GetS(const char* inifilename, int nId, int nIndex);
			void LogOut(const char* inifilename, int nId);
			bool GetIdList(const char* inifilename,ID_VEC& idlist);
		private:
			typedef std::map<std::string, unsigned int>		MAP_STR_INT;
			typedef MAP_STR_INT::iterator					MAP_STR_INT_IT;
			typedef MAP_STR_INT::value_type					MAP_STR_INT_VT;
			
			unsigned int				m_uiIdGenerator;
			MAP_STR_INT					m_mapData;
		
		private:
			unsigned int GenerateKey();
		public:
			ScriptDB();
			~ScriptDB();
	};
}

#endif // _SCRIPT_DATA_BASE_H_
#endif