/*
*
*/

#ifndef GAMELAUNCHER_H
#define GAMELAUNCHER_H

#include "NDGameApplication.h"

using namespace NDEngine;

class GameLauncher
{
public:

	GameLauncher();
	virtual ~GameLauncher();

	virtual bool BeginGame();

protected:

	NDGameApplication* m_pkGameApp;

private:
};

#endif