/*
Ω‚Œˆxml≈‰÷√
*/


#ifndef _PACKSINFO_H_
#define _PACKSINFO_H_



#include <string>
#include <vector>

#include "CCSAXParser.h"





typedef struct tagPackInfo {
	std::string strVersionSrc;
	std::string strVersionDst;
	std::string strFileName;
	std::string strUri;	
}t_PackInfo;


class CPacksInfo : public cocos2d::CCSAXDelegator
{
public:
	CPacksInfo();
	~CPacksInfo();
public:
	bool LoadFromXmlFile(const char* szFileName);

	std::string GetLatestVersion()
	{
		return m_strLatestVersion;
	}

	std::vector<t_PackInfo>* GetPackInfo()
	{
		return &m_VecPackInfo;
	}

	
public:
	void startElement(void *ctx, const char *name, const char **atts);
	void endElement(void *ctx, const char *name);
	void textHandler(void *ctx, const char *s, int len);

private:
	std::string m_strLatestVersion;
	std::vector<t_PackInfo> m_VecPackInfo;
};





#endif //_PACKSINFO_H_