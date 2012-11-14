#ifndef _ENCRYPTOR_H_
#define _ENCRYPTOR_H_

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "BaseType.h"


#define UNUSED_ARG(a) (a)

namespace net
{
	class  IEncryptor
	{
	protected:
		virtual ~IEncryptor()	{};
	public:
		// ??�ơ֣���o���???̦���??
		virtual USHORT			Release			(void)							= 0;
        
		// �ޣ��¡??ǡݡ??o족�?????
		virtual int				Encrypt			(unsigned char* buf, int nLen)	= 0;
        
		// ̡ޣ��¡??ǡݡ??즸?�?????	
		virtual int				Decrypt			(unsigned char* buf, int nLen)	= 0;
        
		// ̣����Ʀ��??ơ������ޡ��¡??ǡݡ??�?̦�?�?????̡?¨C?o���?̡ꡧa�¡ǣ��̦���?�??̡ަ??̣�?��
		virtual int				Rencrypt		(unsigned char* buf, int nLen)	= 0;
        
		// �?ǡ�o롱�???̡???
		virtual void			ChangeCode		(unsigned int ulCode)			= 0;
		virtual void			ChangeCode		(const char* pszKey)			= 0;
        
		// �ܨB���B��a�?ǨC?�?o̡��???̦���??
		virtual IEncryptor*		Duplicate		(void)							= 0;
        
		// ?��?�
		virtual int				ShakeHand		(char* pszBuf, int nLenvoid)	= 0;
	};

    
	// <a1,  b1,   c1,   fst1, a2,   b2,   c2,   fst2>
	// 0xEE, 0x17, 0x33, 0x50, 0x82, 0x23, 0x61, 0x33

	////////////////////////////////////////////////////////////////////////////////////////////////////
	// TEncryptClient
 	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			 unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	class TEncryptClient : public net::IEncryptor
	{
	public:
		TEncryptClient()	{ this->Init(); }
		//TEncryptClient(TEncryptClient& rEncrypt);
		
		// Interface
	public:
		virtual void			ChangeCode	(unsigned int dwData);
		virtual void			ChangeCode	(const char* pszKey);
		
		virtual int				Encrypt		(unsigned char * bufMsg, int nLen);
		virtual int				Decrypt		(unsigned char* buf, int nLen);
		virtual int				Rencrypt	(unsigned char* buf, int nLen)		{ UNUSED_ARG(buf); UNUSED_ARG(nLen); return 0; }
		
		virtual IEncryptor*		Duplicate	(void)								{ return new TEncryptClient;}
		virtual USHORT			Release		(void)								{ delete this; return 0; }

		virtual int				ShakeHand	(char* pszBuf, int nLenvoid)		{  UNUSED_ARG(pszBuf); UNUSED_ARG(nLenvoid);m_nPos1 = m_nPos2 = 0; return 0;}
	protected:
		void			Init		(void);
		int				m_nPos1;
		int				m_nPos2;

		// EncryptCode
		unsigned char m_bufEncrypt1[256];
		unsigned char m_bufEncrypt2[256];
		
		// heap manage
	public:
		//MYHEAP_DECLARATION(s_heap)
	};


	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Implemention
	////////////////////////////////////////////////////////////////////////////////////////////////////
	/*template<unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			 unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	tq::CHeap TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::s_heap("TEncryptClient");*/

	//template <unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
	//			unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	//TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::CEncryptCode	TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::m_cGlobalEncrypt;


	// Init
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template <unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	inline void 
	TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::Init(void)
	{
		m_nPos1 = m_nPos2 = 0;
		
		try{
			int	nCode = fst1;
            int i = 0;
			for(i = 0; i < 256; i++)
			{
				m_bufEncrypt1[i] = nCode;
				//printf("%02X ", nCode);
				nCode = (a1*nCode*nCode + b1*nCode + c1) % 256;
			}
			//printf("[%02X]\n", nCode);
			assert(nCode == fst1);
			
			nCode = fst2;
			for( i = 0; i < 256; i++)
			{
				m_bufEncrypt2[i] = nCode;
				nCode = (a2*nCode*nCode + b2*nCode + c2) % 256;
			}
			assert(nCode == fst2);
		}catch(...){  }
	}


	// Encrypt
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template <unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	inline int 
	TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::Encrypt(unsigned char * bufMsg, int nLen)
	{
		bool bMove = true;
		try{
			int		nOldPos1 = m_nPos1;
			int		nOldPos2 = m_nPos2;
			for(int i = 0; i < nLen; i++)
			{
				bufMsg[i] ^= m_bufEncrypt1[m_nPos1];
				bufMsg[i] ^= m_bufEncrypt2[m_nPos2];
				if(++m_nPos1 >= 256)
				{
					m_nPos1 = 0;
					if(++m_nPos2 >= 256)
						m_nPos2 = 0;
				}
				assert(m_nPos1 >=0 && m_nPos1 < 256);
				assert(m_nPos2 >=0 && m_nPos2 < 256);

			/*	// CQ AccountServer ??¡��C�?
				int a = (bufMsg[i]&0x0f)*0x10;
				int b = (bufMsg[i]&0xf0)/0x10;
				bufMsg[i] = (a + b) ^ 0xab;
				*/
			}
			
			if(!bMove)
			{
				// a̡¡ǣ��¡ǡ�?
				m_nPos1 = nOldPos1;
				m_nPos2 = nOldPos2;
			}

			return nLen;
		}catch(...){  }
		return 0;
	}

	// Decrypt
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template <unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	inline int 
	TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::Decrypt(unsigned char * bufMsg, int nLen)
	{
		return this->Encrypt(bufMsg, nLen);
/*
		bool bMove = true;
		try{
			int		nOldPos1 = m_nPos1;
			int		nOldPos2 = m_nPos2;
			for(int i = 0; i < nLen; i++)
			{
				bufMsg[i] ^= m_bufEncrypt1[m_nPos1];
				bufMsg[i] ^= m_bufEncrypt2[m_nPos2];
				if(++m_nPos1 >= 256)
				{
					m_nPos1 = 0;
					if(++m_nPos2 >= 256)
						m_nPos2 = 0;
				}
				assert(m_nPos1 >=0 && m_nPos1 < 256);
				assert(m_nPos2 >=0 && m_nPos2 < 256);

				// CQ AccountServer ??���C�?
				int a = (bufMsg[i]&0x0f)*0x10;
				int b = (bufMsg[i]&0xf0)/0x10;
				bufMsg[i] = (a + b) ^ 0xab;
			}
			
			if(!bMove)
			{
				// a̡¡ǣ��¡ǡ�?
				m_nPos1 = nOldPos1;
				m_nPos2 = nOldPos2;
			}

			return nLen;
		}catch(...){ tq::LogSave("Net", "Encryptor Decrypt fail."); }
*/
	}


	// ChangeCode
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	inline void 
	TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::ChangeCode(unsigned int  dwData)
	{
		try{
			DWORD	dwData2 = dwData*dwData;
			for(int i = 0; i < 256; i += 4)
			{
				*(DWORD*)(&m_bufEncrypt1[i]) ^= dwData;
				*(DWORD*)(&m_bufEncrypt2[i]) ^= dwData2;
			}
		}catch(...){  }
	}

	// ChangeCode
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned char a1, unsigned char b1, unsigned char c1, unsigned char fst1, 
			unsigned char a2, unsigned char b2, unsigned char c2, unsigned char fst2>
	inline void 
	TEncryptClient<a1, b1, c1, fst1, a2, b2, c2, fst2>::ChangeCode(const char* pszKey)
	{
		if (!pszKey)
			return;
		
		try{
            DWORD dwData = strtoul(pszKey, NULL, 10);
//			DWORD dwData = (DWORD) tq::TQ_atoi(pszKey);
			
			DWORD	dwData2 = dwData*dwData;
			for(int i = 0; i < 256; i += 4)
			{
				*(DWORD*)(&m_bufEncrypt1[i]) ^= dwData;
				*(DWORD*)(&m_bufEncrypt2[i]) ^= dwData2;
			}
		}catch(...){ }
	}



	////////////////////////////////////////////////////////////////////////////////////////////////////
	// 3�?Ǩ���a�B??, ���̡�?��?�?ܡ??ƨ�?��INI�¨C�?SERVER KEY̡��aܡ�
	////////////////////////////////////////////////////////////////////////////////////////////////////
	#define		__aa	0x7E
	#define		__bb	0x33
	#define		__cc	0xA1


	// #define LOGIN_KEY1				0xa61fce5e	// A = 0x20, B = 0xFD, C = 0x07, first = 0x1F, key = a61fce5e
	// #define LOGIN_KEY2				0x443ffc04	// A = 0x7A, B = 0xCF, C = 0xE5, first = 0x3F, key = 443ffc04
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// TEncryptServer
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned long key1, unsigned long key2>
	class TEncryptServer : public IEncryptor
	{
	public:
		TEncryptServer()		{ this->Init(); }
		//TEncryptServer(TEncryptServer& rEncrypt);

		// Interface
	public:
		virtual void			ChangeCode	(DWORD dwData);
		virtual void			ChangeCode	(const char* pszKey);
		
		virtual int				Encrypt		(unsigned char * bufMsg, int nLen);
		virtual int				Decrypt		(unsigned char* buf, int nLen);
		virtual int				Rencrypt	(unsigned char* buf, int nLen)		{ UNUSED_ARG(buf); UNUSED_ARG(nLen); return 0; }
		
		virtual IEncryptor*		Duplicate	(void)								{ return new TEncryptServer; }
		virtual USHORT			Release		(void)								{ delete this; return 0; }
		virtual int				ShakeHand	(char* pszBuf, int nLenvoid)		{ UNUSED_ARG(pszBuf);UNUSED_ARG(nLenvoid);return 0; }
	protected:
		void			Init		(void);
		int				m_nPos1;
		int				m_nPos2;

		// EncryptCode
		unsigned char m_bufEncrypt1[256];
		unsigned char m_bufEncrypt2[256];
		
		// heap manage
	public:
		//MYHEAP_DECLARATION(s_heap)
	};


	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Implemention
	////////////////////////////////////////////////////////////////////////////////////////////////////
	/*template<unsigned long key1, unsigned long key2>
	tq::CHeap TEncryptServer<key1, key2>::s_heap("TEncryptServer");*/

	//template <unsigned long key1, unsigned long key2>
	//TEncryptServer<key1, key2>::CEncryptCode	TEncryptServer<key1, key2>::m_cGlobalEncrypt;


	// Init
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned long key1, unsigned long key2>
	inline void 
	TEncryptServer<key1, key2>::Init(void)
	{
		m_nPos1 = m_nPos2 = 0;
		
		try{
			// 롭�B�ݡ� ABC
			int	a1, b1, c1, fst1;
			a1		= ((key1 >> 0) & 0xFF) ^ __aa;
			b1		= ((key1 >> 8) & 0xFF) ^ __bb;
			c1		= ((key1 >> 24) & 0xFF) ^ __cc;
			fst1	= (key1 >> 16) & 0xFF;
			
			int	a2, b2, c2, fst2;
			a2		= ((key2 >> 0) & 0xFF) ^ __aa;
			b2		= ((key2 >> 8) & 0xFF) ^ __bb;
			c2		= ((key2 >> 24) & 0xFF) ^ __cc;
			fst2	= (key2 >> 16) & 0xFF;
			
			unsigned char	nCode = fst1;
            int i = 0;
			for(i = 0; i < 256; i++)
			{
				m_bufEncrypt1[i] = nCode;
				//printf("%02X ", nCode);
				nCode = (a1*nCode*nCode + b1*nCode + c1) % 256;
			}
			//printf("[%02X]\n", nCode);
			assert(nCode == fst1);
			
			nCode = fst2;
			for( i = 0; i < 256; i++)
			{
				m_bufEncrypt2[i] = nCode;
				nCode = (a2*nCode*nCode + b2*nCode + c2) % 256;
			}
			assert(nCode == fst2);
		}catch(...){ }
	}
	
	// Encrypt
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned long key1, unsigned long key2>
	inline int 
	TEncryptServer<key1, key2>::Encrypt(unsigned char * bufMsg, int nLen)
	{
		bool bMove = true;
		try{
			int		nOldPos1 = m_nPos1;
			int		nOldPos2 = m_nPos2;
			for(int i = 0; i < nLen; i++)
			{
				/*
				// CQ AccountServer ??���C�?
				bufMsg[i] ^= 0xab;
				int a = (bufMsg[i]&0x0f)*0x10;
				int b = (bufMsg[i]&0xf0)/0x10;
				bufMsg[i] = (a + b);
				*/
				
				bufMsg[i] ^= m_bufEncrypt1[m_nPos1];
				bufMsg[i] ^= m_bufEncrypt2[m_nPos2];
				if(++m_nPos1 >= 256)
				{
					m_nPos1 = 0;
					if(++m_nPos2 >= 256)
						m_nPos2 = 0;
				}
				assert(m_nPos1 >=0 && m_nPos1 < 256);
				assert(m_nPos2 >=0 && m_nPos2 < 256);
			}
			
			if(!bMove)
			{
				// a̡¡ǣ��¡ǡ�?
				m_nPos1 = nOldPos1;
				m_nPos2 = nOldPos2;
			}

			return nLen;
		}catch(...){ }
		return 0;
	}

	// Decrypt
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned long key1, unsigned long key2>
	inline int 
	TEncryptServer<key1, key2>::Decrypt(unsigned char * bufMsg, int nLen)
	{
		return this->Encrypt(bufMsg, nLen);
/*
		bool bMove = true;
		try{
			int		nOldPos1 = m_nPos1;
			int		nOldPos2 = m_nPos2;
			for(int i = 0; i < nLen; i++)
			{
				// CQ AccountServer ??���C�?
				bufMsg[i] ^= 0xab;
				int a = (bufMsg[i]&0x0f)*0x10;
				int b = (bufMsg[i]&0xf0)/0x10;
				bufMsg[i] = (a + b);

				bufMsg[i] ^= m_bufEncrypt1[m_nPos1];
				bufMsg[i] ^= m_bufEncrypt2[m_nPos2];
				if(++m_nPos1 >= 256)
				{
					m_nPos1 = 0;
					if(++m_nPos2 >= 256)
						m_nPos2 = 0;
				}
				assert(m_nPos1 >=0 && m_nPos1 < 256);
				assert(m_nPos2 >=0 && m_nPos2 < 256);
			}
			
			if(!bMove)
			{
				// a̡¡ǣ��¡ǡ�?
				m_nPos1 = nOldPos1;
				m_nPos2 = nOldPos2;
			}

			return nLen;
		}catch(...){ tq::LogSave("Net", "Encryptor Encrypt fail."); }
*/
	}
	
	
	// ChangeCode
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned long key1, unsigned long key2>
	inline void 
	TEncryptServer<key1, key2>::ChangeCode(DWORD dwData)
	{
		try{
			DWORD	dwData2 = dwData*dwData;
			for(int i = 0; i < 256; i += 4)
			{
				*(DWORD*)(&m_bufEncrypt1[i]) ^= dwData;
				*(DWORD*)(&m_bufEncrypt2[i]) ^= dwData2;
			}
		}catch(...){ }
	}
	
	
	// ChangeCode
	////////////////////////////////////////////////////////////////////////////////////////////////////
	template<unsigned long key1, unsigned long key2>
	inline void 
	TEncryptServer<key1, key2>::ChangeCode(const char* pszKey)
	{
		if (!pszKey)
			return;
		
		try{
//			DWORD dwData = (DWORD) tq::TQ_atoi(pszKey);
			DWORD dwData = strtoul(pszKey, NULL, 10);
			DWORD	dwData2 = dwData*dwData;
			for(int i = 0; i < 256; i += 4)
			{
				*(DWORD*)(&m_bufEncrypt1[i]) ^= dwData;
				*(DWORD*)(&m_bufEncrypt2[i]) ^= dwData2;
			}
		}catch(...){  }
	}


}


#endif // _ENCRYPTOR_H_
