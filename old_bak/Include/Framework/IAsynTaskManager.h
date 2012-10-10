#if !defined ASYNTASK_MANAGER_H__
#define ASYNTASK_MANAGER_H__

typedef unsigned int CRITICAL_SECTION_ID;
typedef unsigned int THREAD_ID;
typedef int (*FnTheadFunc)(void* param);



class IAsynTaskManager 
{
public:
	
	static IAsynTaskManager& sharedInstance();
	virtual CRITICAL_SECTION_ID newCriticalSection() = 0;
	
	virtual bool delCriticalSection(CRITICAL_SECTION_ID cid) = 0;
	
	virtual bool enterCriticalSection(CRITICAL_SECTION_ID cid) = 0;
	
	virtual bool leaveCriticalSection(CRITICAL_SECTION_ID cid) = 0;
	
public:
	
	virtual bool createThread(FnTheadFunc threadFunc, void* param, THREAD_ID& tid) = 0;
	
	virtual bool terminateThread(THREAD_ID tid)= 0;
	
	virtual bool stopThread(THREAD_ID tid) = 0;
	
	virtual bool resumeThread(THREAD_ID tid) = 0;

};
//将被取消，统一用sharedInstance接口。
IAsynTaskManager& GetAsynTaskManager();

class CAutoCriticalSection
{
public:
	CAutoCriticalSection(CRITICAL_SECTION_ID idCS){ m_idCS = idCS; GetAsynTaskManager().enterCriticalSection(idCS);};
	~CAutoCriticalSection(){GetAsynTaskManager().leaveCriticalSection(m_idCS);};
private:
	CRITICAL_SECTION_ID m_idCS;
};

#endif

   
