#ifndef	AUTO_LINK_H
#define	AUTO_LINK_H

////////////////////////////////////////////////////////////////
template<typename T>
class	CAutoLink
{
public:
	CAutoLink()										{ Init(); }
	~CAutoLink()									{ Break(); }
	CAutoLink(const CAutoLink<T>& link)				{ Init(); Insert(&const_cast<CAutoLink<T>&>(link)); }
	//explicit CAutoLink(T* ptr)								{ Init(); Insert(&ptr->QueryLink(CAutoLink<T>())); }
	CAutoLink&	operator=(const CAutoLink<T>& link)	{ Break(); Insert(&const_cast<CAutoLink<T>&>(link)); return *this; }
	CAutoLink&	operator=(T* ptr)					;
	void	Init(T* pOwner)							{ NDAsssert(!IsValid()); m_pOwner=pOwner; }
	void	Clear()									{ Break(); }
	bool operator==( CAutoLink &objRight ) const { return m_pOwner == objRight.m_pOwner ; }
	
public: // const
	operator T*()			const					{ return m_pOwner;	}
	T*		Pointer()		const					{ return m_pOwner;	}
	T*		operator->()	const					{ return m_pOwner;  }
	//POINT_NO_RELEASE<T>*		operator->()	const					{ ASSERT(IsValid()); return static_cast<POINT_NO_RELEASE<T>* >(m_pOwner); }
	bool	IsValid()		const					{ return m_pOwner != NULL; }

public: // modify

protected:
	void	Init();
	void	Insert(CAutoLink<T>* pPrev);		// insert to next, only for !IsMaster
	void	Erase();							// erase from list, only for !IsMaster
	void	Break();
	bool	IsMaster()		const					{ return IsValid() && m_pPrev == NULL; }

protected:
	T*				m_pOwner;
	CAutoLink<T>*	m_pPrev;
	CAutoLink<T>*	m_pNext;
};

////////////////////////////////////////////////////////////////
template<typename T>
inline void CAutoLink<T>::Init()						// Init all
{
	m_pOwner	= NULL;
	m_pPrev		= NULL;
	m_pNext		= NULL;
}

////////////////////////////////////////////////////////////////
template<typename T>
void CAutoLink<T>::Break()
{
	if(IsMaster())		// master
	{
		CAutoLink<T>* pNext = m_pNext;
		int	nCount=0;
		while(pNext)
		{
			CAutoLink<T>* pCurr = pNext;
			pNext	= pNext->m_pNext;			// ++
			
			NDAsssert(pCurr->IsValid());
			if(pCurr)
				pCurr->Init();

			if (nCount > 100)
				break;
			//DEAD_LOOP_BREAK(nCount, 100)
		}

		Init();
	}
	else
	{
		Erase();
	}
}

////////////////////////////////////////////////////////////////
template<typename T>
void CAutoLink<T>::Insert(CAutoLink<T>* pPrev)		// insert to next
{
	//CHECK(pPrev);
	if (!pPrev) return;
	//CHECK(pPrev != this);
	if (pPrev == this) return;
	//CHECK(!IsMaster());
	if (IsMaster()) return;
	Erase();

	this->m_pOwner			= pPrev->m_pOwner;
	if(IsValid())
	{
		this->m_pPrev			= pPrev;
		this->m_pNext			= pPrev->m_pNext;
		if(pPrev->m_pNext)
			pPrev->m_pNext->m_pPrev	= this;
		pPrev->m_pNext			= this;
	}
}

////////////////////////////////////////////////////////////////
template<typename T>
void CAutoLink<T>::Erase()						// erase from list
{
	if(IsValid())
	{
		//CHECK(!IsMaster());
		if (IsMaster()) return;

		m_pPrev->m_pNext	= this->m_pNext;
		if(m_pNext)
			m_pNext->m_pPrev	= this->m_pPrev;

		Init();
	}
}
template<typename T>
CAutoLink<T>&	CAutoLink<T>::operator=(T* ptr)					
{ 
	Break(); 
	if( NULL== ptr ) 
	{
		return *this ;
	}
	
	Insert(&ptr->QueryLink(/*CAutoLink<T>()*/));
	return *this; 
}

#endif // AUTO_LINK_H
