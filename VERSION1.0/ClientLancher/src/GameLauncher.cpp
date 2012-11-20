#include "GameLauncher.h"
#include "globaldef.h"
#include "NDDebugOpt.h"

GameLauncher::GameLauncher()
{
	m_pkGameApp = 0;
}

GameLauncher::~GameLauncher()
{
	SAFE_DELETE(m_pkGameApp);
}

bool GameLauncher::BeginGame()
{
	NDLog("Entry BeginGame()");
	m_pkGameApp = new NDGameApplication;
	NDLog("m_pkGameApp value = %d",(int)m_pkGameApp);

	return true;
}