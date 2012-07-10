#ifndef _COBJECT_HH__
#define _COBJECT_HH__

class CObject
{
public:
	//	unsigned int		m_uID;
protected:
	// count of refrence
	unsigned int		m_uReference;
	// is the object autoreleased
	//bool		m_bManaged;		
public:
	CObject(void)
	{
		//static unsigned int uObjectCount = 0;
		//	m_uID = ++uObjectCount;
		// when the object is created, the refrence count of it is 1
		m_uReference = 1;
	}

	virtual ~CObject(void)
	{

	}

	//释放(减少引用计数)
	void Release(void)
	{
		//CCAssert(m_uReference > 0, "reference count should greater than 0");
		--m_uReference;

		if (m_uReference == 0)
		{
			delete this;
		}
	}

	//保持(增加引用计数)
	void Retain(void)
	{
		//CCAssert(m_uReference > 0, "reference count should greater than 0");
		++m_uReference;
	}

	bool IsSingleRefrence(void)
	{
		return m_uReference == 1;
	}

	unsigned int RetainCount(void)
	{
		return m_uReference;
	}

	// protected:
	//CObject* Create(void);
};
#endif //_COBJECT_HH__
