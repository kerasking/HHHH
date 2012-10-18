/*
*
*/

#ifndef NDCONSOLE_H
#define NDCONSOLE_H

#include "NDObject.h"
#include "define.h"
#include "BaseType.h"

BEGIN_ND_NAMESPACE

class NDConsole:public NDObject
{
	DECLARE_CLASS(NDConsole);

public:

	NDConsole();
	NDConsole(LPCTSTR lpszTitle, SHORT ConsoleHeight = 300, SHORT ConsoleWidth = 80);
	virtual ~NDConsole();

	void Attach(SHORT ConsoleHeight, SHORT ConsoleWidth);

protected:

	static bool ms_bIsExistent;

private:
};

END_ND_NAMESPACE
#endif