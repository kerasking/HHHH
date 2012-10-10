#ifndef __KT_MUTEX_H
#define __KT_MUTEX_H

#include "pthread.h"

class KMutex
{
public:

	KMutex ();
	
	~KMutex ();
	
	void lock ();
	
	void unlock ();
	
	pthread_mutex_t* getId ();
	
private:

	pthread_mutex_t myId;

};

#endif
