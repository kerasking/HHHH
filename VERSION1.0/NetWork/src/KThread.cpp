#include "KThread.h"



VThread::VThread()
{
	_bShutdown = false;
	bThreadCreated = false;
}


VThread::~VThread()
{
	
}

bool
VThread::spawn( void *( *startFunc )( void * ),
			   void *startArgs,
			   unsigned long flags,
			   unsigned long priority,
			   int stack_size)
{
    struct sched_param priorityParams;
    if ( pthread_attr_init(&myAttributes) != 0 )
		return false;
	
    switch( flags & VTHREAD_SCHED_MASK )
    {
        case VTHREAD_SCHED_FIFO:
        {
            if ( pthread_attr_setinheritsched(&myAttributes,PTHREAD_EXPLICIT_SCHED) != 0 )
				return false;
            if ( pthread_attr_setschedpolicy(&myAttributes,SCHED_FIFO) != 0 )
				return false;
        }
			break;
        case VTHREAD_SCHED_RR:
        {
            if ( pthread_attr_setinheritsched(&myAttributes,PTHREAD_EXPLICIT_SCHED) != 0 )
				return false;
            if ( pthread_attr_setschedpolicy(&myAttributes,SCHED_RR) != 0 )
				return false;
        }
			break;
        case VTHREAD_SCHED_DEFAULT:
			break;
        default:
			break;
    }
	
    // if anything expect default, set scheduling priority explicitly;
    // note that by default the priority of the parent thread is inherited
    if ( (int)priority != VTHREAD_PRIORITY_DEFAULT )
    {
        // probably should improve to use relative values
        priorityParams.sched_priority = priority;
        if ( pthread_attr_setschedparam(&myAttributes,&priorityParams) != 0 )
			return false;
    }
    // spawn the thread
	bThreadCreated = true;
    if ( pthread_create(&myId,&myAttributes,startFunc,startArgs) != 0 )
		return false;
	else
		return true;
}


int
VThread::join( void **status )
{
	if ( !bThreadCreated )
		return 0;
    int retVal = pthread_join( myId, status );
    return retVal;
}


int
VThread::getPriority() const
{
    struct sched_param priorityParams;
    assert( pthread_attr_getschedparam( &myAttributes, &priorityParams ) == 0 );
    return priorityParams.sched_priority;
}


const vthread_t
VThread::getId() const
{
    return myId;
}


const vthread_attr_t*
VThread::getAttributes() const
{
    return &myAttributes;
}

void
VThread::exit()
{
	pthread_cancel( myId );
}


const vthread_t
VThread::selfId()
{
    return pthread_self();
}

bool
VThread::isShutdown()
{
	return _bShutdown;
}

void
VThread::shutdown()
{
	_bShutdown = true;
}


void VThread::setparam( int param )
{
	_param = param;
}


int VThread::getparam()
{
	return _param;
}

////////////////////////////////////////////////////////////////////


static void*
threadWrapper( void* threadParm )
{
    assert( threadParm );
    KThread* t = static_cast< KThread* >( threadParm );
    assert( t );
    t->thread();
    return 0;
}


KThread::KThread() : _shutdown( true )
{

}


KThread::~KThread()
{

}

void
KThread::run( unsigned long priority )
{
	_shutdown = false;
    itsThread.spawn( threadWrapper, this, VTHREAD_SCHED_DEFAULT, priority );
}


void
KThread::shutdown()
{
    _shutdown = true;
}


bool
KThread::isShutdown() const
{
    return _shutdown;
}
