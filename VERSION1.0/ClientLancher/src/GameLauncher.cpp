#include "GameLauncher.h"

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
	m_pkGameApp = new NDGameApplication;

	return true;
}