//
//  NDMapDataPool.h
//  MapData
//
//  Created by jhzheng on 11-1-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef __CIRCLE_BUFFER_H_520A8DC3_71AC_4263_A247_7608021C01AB__ 
#define __CIRCLE_BUFFER_H_520A8DC3_71AC_4263_A247_7608021C01AB__

#include <vector>

#define min(a,b) (a>b?b:a)

typedef unsigned int An_UInt32;

template<class T, An_UInt32 MAX_LEN = 1024, An_UInt32 EXTRA_LEN = 128>
class CRingBuffer
{
public:
	CRingBuffer()
	{
		Reset();
		ResetSize( MAX_LEN + EXTRA_LEN );
	}
	
	~CRingBuffer()
	{
		Reset();
	}
	
	void Reset()
	{
		m_nReadPos	= 0;
		m_nWritePos	= 0;
	}
	
	void ResetSize( An_UInt32 nSize )
	{
		m_RingBuffer.resize(nSize);
	}
	
	// 最多读个数
	An_UInt32 GetMaxReadSize()
	{
		An_UInt32 nReadSize	= 0;
		
		An_UInt32 nTempReadPos	= m_nReadPos;
		An_UInt32 nTempWritePos	= m_nWritePos;
		
		if (nTempReadPos == nTempWritePos)
			nReadSize	= 0;
		if (nTempReadPos < nTempWritePos)
			nReadSize	= nTempWritePos - nTempReadPos;
		if (nTempReadPos > nTempWritePos)
			nReadSize	= MAX_LEN + nTempWritePos - nTempReadPos;
		
		return nReadSize;
	}
	
	// 最多写个数
	An_UInt32 GetMaxWriteSize()
	{
		An_UInt32 nWriteSize	= 0;
		
		An_UInt32 nTempReadPos	= m_nReadPos;
		An_UInt32 nTempWritePos	= m_nWritePos;
		
		if (nTempReadPos == nTempWritePos)
			nWriteSize	= MAX_LEN;
		if (nTempReadPos < nTempWritePos)
			nWriteSize	= MAX_LEN - (nTempWritePos - nTempReadPos);
		if (nTempReadPos > nTempWritePos)
			nWriteSize	= nTempReadPos - nTempWritePos;
		
		if (nWriteSize > 1)
			nWriteSize	= nWriteSize - 1;
		else
			nWriteSize = 0;
		
		return nWriteSize;
	}
	
	// 取读指针
	void	GetReadPtr(T*& pPtr, An_UInt32& nMaxReadSize)
	{
		An_UInt32 nReadSize	= 0;
		
		An_UInt32 nTempReadPos	= m_nReadPos;
		An_UInt32 nTempWritePos	= m_nWritePos;
		
		if (nTempReadPos == nTempWritePos)
			nReadSize	= 0;
		if (nTempReadPos < nTempWritePos)
			nReadSize	= nTempWritePos - nTempReadPos;
		if (nTempReadPos > nTempWritePos)
			nReadSize	= MAX_LEN + nTempWritePos - nTempReadPos;
		
		nMaxReadSize	= min(nReadSize, EXTRA_LEN);
		
		An_UInt32	nCopyDataCount	= 0;
		
		T*	pReadPtr	= GetHeadPtr() + nTempReadPos;
		
		if ((nTempReadPos > nTempWritePos) 
			&& (nTempReadPos + nMaxReadSize > MAX_LEN)
			&& (nCopyDataCount = nTempReadPos + nMaxReadSize - MAX_LEN) < EXTRA_LEN)
		{
			SafeCopy( GetHeadPtr() + MAX_LEN, GetHeadPtr() , nCopyDataCount);
		}
		
		pPtr	= pReadPtr;
	}
	
	// 取写指针
	void	GetWritePtr(T*& pPtr, An_UInt32& nMaxWriteSize)
	{
		/*
		 An_UInt32	nTempReadPos	= m_nReadPos;
		 An_UInt32	nTempWritePos	= m_nWritePos;
		 
		 if ((nTempWritePos + 1) % MAX_LEN == nTempReadPos)	// 队列满
		 {
		 nMaxWriteSize	= 0;
		 pPtr	= NULL;
		 return;
		 }
		 
		 if (nTempWritePos > nTempReadPos)
		 nMaxWriteSize	= MAX_LEN - nTempWritePos;
		 else if (nTempWritePos < nTempReadPos)
		 nMaxWriteSize	= nTempReadPos - nTempWritePos;
		 else
		 nMaxWriteSize	= MAX_LEN - nTempWritePos;
		 
		 */
		
		An_UInt32 nWriteSize	= 0;
		
		An_UInt32 nTempReadPos	= m_nReadPos;
		An_UInt32 nTempWritePos	= m_nWritePos;
		
		if (nTempReadPos == nTempWritePos)
			nWriteSize	= MAX_LEN;
		if (nTempReadPos < nTempWritePos)
			nWriteSize	= MAX_LEN - (nTempWritePos - nTempReadPos);
		if (nTempReadPos > nTempWritePos)
			nWriteSize	= nTempReadPos - nTempWritePos;
		
		if (nWriteSize > 1)
			nMaxWriteSize	= nWriteSize - 1;
		else
			nMaxWriteSize = 0;
		
		pPtr	= GetHeadPtr() + nTempWritePos;
	}
	
	// 添加数据	
	bool	PushData( const T* pData, An_UInt32 nLength = 1)
	{
		if (pData == NULL || nLength > GetMaxWriteSize())
		{
			return false;
		}
		
		An_UInt32 nTempWritePos	= m_nWritePos;
		
		if ((nTempWritePos + nLength) <= MAX_LEN)
		{
			SafeCopy( GetHeadPtr() + nTempWritePos, pData, nLength);
			
			An_UInt32 size	= (nTempWritePos + nLength) % MAX_LEN;
			m_nWritePos = size;
		}
		else
		{
			An_UInt32 size1 = MAX_LEN - nTempWritePos;
			An_UInt32 size2 = nLength - size1;
			
			SafeCopy( GetHeadPtr()+nTempWritePos, pData, size1 );
			SafeCopy( GetHeadPtr(), pData+size1, size2 );
			
			m_nWritePos = size2;
		}
		
		return true;
	}
	
	// 取出并删除数据
	bool	PopData(T* pData, An_UInt32 nLength = 1)
	{
		if (pData == NULL || nLength > GetMaxReadSize())		//不够读
		{
			return false;
		}
		
		An_UInt32	nTempReadPos	= m_nReadPos;
		
		if ((nTempReadPos + nLength) <= MAX_LEN)
		{
			SafeCopy(pData, GetHeadPtr()+nTempReadPos, nLength);
			
			An_UInt32 size	= (nTempReadPos + nLength) % MAX_LEN;
			m_nReadPos = size;
		}
		else
		{
			An_UInt32 size1 = MAX_LEN - nTempReadPos;
			An_UInt32 size2 = nLength - size1;
			
			SafeCopy(pData, GetHeadPtr()+nTempReadPos, size1 );
			SafeCopy(pData+size1, GetHeadPtr(), size2 );
			
			m_nReadPos = size2;
		}
		
		return true;
	}
	
	// 查看数据 不删除
	bool	PeekData(T* pData, An_UInt32 nLen)
	{
		if (nLen > GetMaxReadSize())		//不够读
		{
			return false;
		}
		
		An_UInt32 nTempReadPos	= m_nReadPos;
		
		if ((nTempReadPos + nLen) <= MAX_LEN)
		{
			SafeCopy(pData, GetHeadPtr()+nTempReadPos, nLen );
		}
		else
		{
			An_UInt32 size1 = MAX_LEN - nTempReadPos;
			An_UInt32 size2 = nLen - size1;
			
			SafeCopy(pData, GetHeadPtr()+nTempReadPos, size1 );
			SafeCopy(pData+size1, GetHeadPtr(), size2 );
		}
		
		return true;
	}
	
	// 删除数据
	bool DeleteData(An_UInt32 nLen)
	{
		if (nLen > GetMaxReadSize())		//不够读
		{
			return false;
		}
		
		An_UInt32 nTempReadPos	= m_nReadPos;
		
		if ((nTempReadPos + nLen) <= MAX_LEN )
		{
			An_UInt32 size	= (nTempReadPos + nLen) % MAX_LEN;
			m_nReadPos	= size;
		}
		else
		{
			An_UInt32 size1 = MAX_LEN - nTempReadPos;
			An_UInt32 size2 = nLen - size1;
			
			m_nReadPos = size2;
		}
		
		return true;
	}
	
	// 添加数据
	bool	AddData(An_UInt32 nLength = 1)
	{
		if (nLength > GetMaxWriteSize())
		{
			return false;
		}
		
		An_UInt32 nTempWritePos	= m_nWritePos;
		
		if ((nTempWritePos + nLength) <= MAX_LEN)
		{
			An_UInt32 size	= (nTempWritePos + nLength) % MAX_LEN;
			m_nWritePos = size;
		}
		else
		{
			An_UInt32 size1 = MAX_LEN - nTempWritePos;
			An_UInt32 size2 = nLength - size1;
			
			m_nWritePos = size2;
		}
		
		return true;
	}
	
	
private:
	T*	 GetHeadPtr( ) {
		return ( T* )( &( *m_RingBuffer.begin() ) );
	}
	void SafeCopy(T* pDst, const T* pSrc, An_UInt32 nSize)
	{
		for (An_UInt32 i=0; i<nSize; i++)
		{
			pDst[i] = pSrc[i];
		}
	}
	
private:
	std::vector<T>	m_RingBuffer;
	An_UInt32	m_nReadPos;
	An_UInt32	m_nWritePos;
};

#endif // __CIRCLE_BUFFER_H_520A8DC3_71AC_4263_A247_7608021C01AB__



