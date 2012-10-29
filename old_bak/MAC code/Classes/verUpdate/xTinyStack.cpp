#include <stdlib.h>
#include <string.h>
#include "xtinystack.h"


bool stack_clear( ptinystack_t _Stack )
{
	if(_Stack==NULL)
		return false;

	_Stack->top = -1;
	return true;
}

bool stack_push( ptinystack_t _Stack, int _Val )
{
	if(_Stack==NULL)
		return false;

	if( _Stack->top < _Stack->size )
	{
		_Stack->buf[++_Stack->top] = _Val;
		return true;
	}
	else
	{
		return false;
	}
}

bool stack_pop( ptinystack_t _Stack )
{
	if(_Stack==NULL)
		return false;

	if( _Stack->top >= 0 )
	{
		_Stack->top--;
		return true;
	}
	else
	{
		return false;
	}
}

int stack_gettop( ptinystack_t _Stack )
{
	if(_Stack==NULL)
		return 0;

	if( _Stack->top<0 )
		return 0;
	else
		return _Stack->buf[_Stack->top];
}

bool stack_empty( ptinystack_t _Stack )
{
	if(_Stack==NULL)
		return true;

	if( _Stack->top<0 )
		return true;
	else
		return false;
}

ptinystack_t stack_create( int _Size )
{
	ptinystack_t _Stack=NULL;
	if( _Size <=0)
		return NULL;

	_Stack = (ptinystack_t)malloc(sizeof(tinystack_t));
	if(_Stack==NULL)
		return NULL;

	int *pBuf = (int *)malloc(sizeof(int)*_Size);
	if(pBuf==NULL)
	{
		free(_Stack);
		return NULL;
	}

	_Stack->buf = pBuf;
	_Stack->unused = 0;
	_Stack->size = _Size;	
	_Stack->top = -1;

	return _Stack;
}

bool stack_release( ptinystack_t _Stack )
{
	if(_Stack==NULL)
		return false;

	if(_Stack->buf==NULL)
		return false;

	free(_Stack->buf);
	free(_Stack);

	return true;
}



bool stack_resize(  ptinystack_t _Stack, int _NewSize )
{
	if(_Stack==NULL)
		return false;

	if( _NewSize <= _Stack->top+1 )
		return false;

	int *pBuf = (int *)malloc(sizeof(int)*_NewSize);
	if(pBuf==NULL)
		return false;

	memcpy( pBuf, _Stack->buf, _Stack->top+1 );

	free(_Stack->buf);
	_Stack->buf = pBuf;
	_Stack->size = _NewSize;
	_Stack->top = -1;

	return true;
}
