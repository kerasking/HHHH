#include <errno.h>
#include <cassert>
#include "KMutex.h"


KMutex::KMutex ()
{
    int err = pthread_mutex_init( &myId, NULL );
    assert( err == 0);
}


KMutex::~KMutex ()
{
    int err = pthread_mutex_destroy( &myId );
    assert( err != EBUSY );
    assert( err == 0 );
}


void
KMutex::lock ()
{
    int err = pthread_mutex_lock( &myId );
	assert( err != EINVAL );
	assert( err != EDEADLK );
	assert( err == 0 );
}

void
KMutex::unlock ()
{
    int err = pthread_mutex_unlock( &myId );
    assert( err != EINVAL );
    assert( err != EPERM );
    assert( err == 0);
}

pthread_mutex_t*
KMutex::getId ()
{
    return &myId;
}
