#ifndef TQ_TIMER_HEADER
#define TQ_TIMER_HEADER
//定时器
class ISysTimerDelegate
{
public:
	virtual int OnTimer(int TimerId, void* pParam) = 0;
};

//设置定时器并开始(返回定时器的ID)
int SetTimer(unsigned int uElapse/*毫秒*/, void* pParam, ISysTimerDelegate* pCallBack);

//删除定时器
bool KillTimer(int nTimerID/*定时器ID*/);

#endif
