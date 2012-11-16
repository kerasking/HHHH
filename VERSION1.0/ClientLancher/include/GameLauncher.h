/*
*
*/

#ifndef GAMELAUNCHER_H
#define GAMELAUNCHER_H

using namespace NDEngine;

class GameLauncher
{
public:

	GameLauncher();
	virtual ~GameLauncher();

	virtual bool BeginGame();

protected:

private:
};

#endif