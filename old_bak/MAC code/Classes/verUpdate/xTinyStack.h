/*
¼òÒ×µÄ¶ÑÕ»
*/
#ifndef _XTINYSTACK_H_
#define _XTINYSTACK_H_



typedef struct {
	int *buf;
	int size;
	int top;
	int unused;
}tinystack_t, *ptinystack_t;


bool stack_clear( ptinystack_t _Stack );
bool stack_push( ptinystack_t _Stack, int _Val );
bool stack_pop( ptinystack_t _Stack );
int stack_gettop( ptinystack_t _Stack );
bool stack_empty( ptinystack_t _Stack );

ptinystack_t stack_create( int _Size );
bool stack_release( ptinystack_t _Stack );
bool stack_resize( ptinystack_t _Stack, int _NewSize );


#endif //_XTINYSTACK_H_

