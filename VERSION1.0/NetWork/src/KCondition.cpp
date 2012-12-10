#include <cassert>
#include "KCondition.h"
#include "KTimeVal.h"
#include "KMutex.h"



KCondition::KCondition ()
{
    // note, pthread implementation ignores the attribute variable,
    // so it is set explicitly to NULL in the call to pthread_cond_init()
    int errorcode = pthread_cond_init( &myId, NULL );
    assert(!errorcode);
}


KCondition::~KCondition ()
{
    pthread_cond_destroy( &myId );
	
}


int
KCondition::wait( KMutex* mutex, int relativeTimeInMs )
{
    int utime = relativeTimeInMs < 1
                    ? relativeTimeInMs
                    : relativeTimeInMs * 1000;
    return ( uwait( mutex, utime ) );
}

int
KCondition::uwait( KMutex* mutex, int relativeTimeInUs )
{
    // SunOS 5.6 (according to the man page for pthread_cond_timedwait)
    // can have a maximum value for the seconds portion of the abstime
    // of the current time + 100,000,000. The nsec can have a maximum
    // value of 1,000,000,000. You get EINVAL otherwise.
    //
    // Note that the relative time is in milliseconds, meaning
    // that even if we use MAXINT (assuming 32 bit ints), then
    // we get a number well below MAXINT (by a couple orders of
    // magnitude) for the seconds portion. The slightly challenging
    // part is making sure the nsec is less than 1,000,000,000.
    //
    if ( relativeTimeInUs < 0 )
    {
        return ( pthread_cond_wait( &myId, mutex->getId() ) );
    }

    KTimeVal expiresTV;
    expiresTV.now();
    
    KTimeVal     relativeTime;
    relativeTime.tv_sec = 0;
    relativeTime.tv_usec = relativeTimeInUs;

    expiresTV += relativeTime;

    timespec	expiresTS;

    expiresTS.tv_sec = expiresTV.tv_sec;
    expiresTS.tv_nsec = expiresTV.tv_usec*1000;

    assert( expiresTV.tv_usec < 1000000000L );
    return ( pthread_cond_timedwait( &myId, mutex->getId(), &expiresTS ) );
}


int
KCondition::signal ()
{
    return pthread_cond_signal( &myId );
}


int
KCondition::broadcast()
{
    return pthread_cond_broadcast( &myId );
}

const vcondition_t*
KCondition::getId () const
{
    return &myId;
}

void vusleep( unsigned long usec )
{
    KMutex      mutex;
    KCondition  cond;   
    mutex.lock();
    cond.uwait( &mutex, usec );
    mutex.unlock();
}

void vsleep( unsigned long msec )
{
	KMutex      mutex;
    KCondition  cond;
    mutex.lock();
    cond.uwait( &mutex, msec*1000 );
    mutex.unlock();
}

void vsleeplong( unsigned long msec )
{
	unsigned long iSec = msec;
	const int sleepGap = 5000;
	while( iSec > 0 )
	{
		if ( (int)msec > sleepGap )
			vsleep( sleepGap );
		else
			vsleep( iSec );
		iSec -= sleepGap;
	}
}
