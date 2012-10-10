#ifndef __KT_VCONDITION_H
#define __KT_VCONDITION_H

#include "KThread.h"
#include "KMutex.h"

/** Defines a simple conditional variable class which
 ** allows threads to block until shared data changes state.
 ** A KCondition must always be associated with a
 ** KMutex to avoid the race condition where a thread prepares to
 ** wait on a condition variable and another thread signals the
 ** condition just before the first thread actually waits on it. */
class KCondition
{
public:
	
/** Create an KCondition object initialized with operating system
	** dependant defaults (if any). */
	KCondition ();
	
	/** Delete a KCondition object */
	virtual ~KCondition ();
	
	/**
	** Block on the condition. Will return after the relativeTime, 
	** specified in millseconds, has passed. If set to -1, the default,
	** it will wait indefinately. Uses the specified mutex to synchronize 
	** access to the condition. Returns 0, if successful, or an errorcode. */
	int wait (KMutex* mutex, int relativeTimeInMillis = -1);
	
	
	/**
	** Block on the condition. Will return after the relativeTime, 
	** specified in microseconds, has passed. If set to -1, the default,
	** it will wait indefinately. Uses the specified mutex to synchronize 
	** access to the condition. Returns 0, if successful, or an errorcode. */
	int uwait (KMutex* mutex, int relativeTimeInMicros = -1);
	
	
	/**
	** Signal one waiting thread.
	** Returns 0, if successful, or an errorcode.
	*/
	int signal ();
	
	
	/**
	** Signal all waiting threads.
	** Returns 0, if successful, or an errorcode.
	*/
	int broadcast();
	
	
	/**
	** Returns the operating system dependent unique id of the condition.
	*/
	const vcondition_t*
        getId () const;
	
private:
	/// prevent assignment
	void operator= (const KCondition &);
	/// prevent copy constructor
	KCondition (const KCondition &);
	
	mutable vcondition_t myId;

};

void vusleep(unsigned long usec);

void vsleep( unsigned long msec );

void vsleeplong( unsigned long msec );


#endif
