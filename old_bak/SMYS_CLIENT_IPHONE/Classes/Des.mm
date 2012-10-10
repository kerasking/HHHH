// DES.mm: implementation of the CDes class.
//
//////////////////////////////////////////////////////////////////////
#import "DES.h"
////////////////////////////////////////////////////////////////////////
// initial permutation IP
const char IP_Table[64] = {
		58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4,
		62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8,
		57, 49, 41, 33, 25, 17,  9, 1, 59, 51, 43, 35, 27, 19, 11, 3,
		61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7
};
// final permutation IP^-1 
const char IPR_Table[64] = {
		40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31,
		38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29,
		36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27,
		34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41,  9, 49, 17, 57, 25
};
// expansion operation matrix
const char E_Table[48] = {
	    32, 1,  2,  3,  4,  5,  4,  5,  6,  7,  8,  9,
		8,  9, 10, 11, 12, 13, 12, 13, 14, 15, 16, 17,
		16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25,
		24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32,  1
};
// 32-bit permutation function P used on the output of the S-boxes 
const char P_Table[32] = {
	    16, 7, 20, 21, 29, 12, 28, 17, 1,  15, 23, 26, 5,  18, 31, 10,
		2,  8, 24, 14, 32, 27, 3,  9,  19, 13, 30, 6,  22, 11, 4,  25
};
// permuted choice table (key) 
const char PC1_Table[56] = {
		57, 49, 41, 33, 25, 17,  9,  1, 58, 50, 42, 34, 26, 18,
		10,  2, 59, 51, 43, 35, 27, 19, 11,  3, 60, 52, 44, 36,
		63, 55, 47, 39, 31, 23, 15,  7, 62, 54, 46, 38, 30, 22,
		14,  6, 61, 53, 45, 37, 29, 21, 13,  5, 28, 20, 12,  4
};
// permuted choice key (table) 
const char PC2_Table[48] = {
		14, 17, 11, 24,  1,  5,  3, 28, 15,  6, 21, 10,
		23, 19, 12,  4, 26,  8, 16,  7, 27, 20, 13,  2,
		41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48,
		44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32
};
// number left rotations of pc1 
const char LOOP_Table[16] = {
	1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1
};
// The (in)famous S-boxes 
const char S_Box[8][4][16] = {
	    // S1 
		14,	 4,	13,	 1,  2, 15, 11,  8,  3, 10,  6, 12,  5,  9,  0,  7,
		0, 15,  7,  4, 14,  2, 13,  1, 10,  6, 12, 11,  9,  5,  3,  8,
		4,  1, 14,  8, 13,  6,  2, 11, 15, 12,  9,  7,  3, 10,  5,  0,
		15, 12,  8,  2,  4,  9,  1,  7,  5, 11,  3, 14, 10,  0,  6, 13,
		// S2 
		15,  1,  8, 14,  6, 11,  3,  4,  9,  7,  2, 13, 12,  0,  5, 10,
		3, 13,  4,  7, 15,  2,  8, 14, 12,  0,  1, 10,  6,  9, 11,  5,
		0, 14,  7, 11, 10,  4, 13,  1,  5,  8, 12,  6,  9,  3,  2, 15,
		13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12,  0,  5, 14,  9,
		// S3 
		10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12,  7, 11,  4,  2,  8,
		13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15,  1,
		13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12,  5, 10, 14,  7,
		1, 10, 13,  0,  6,  9,  8,  7,  4, 15, 14,  3, 11,  5,  2, 12,
		// S4 
		7, 13, 14,  3,  0,  6,  9, 10,  1,  2,  8,  5, 11, 12,  4, 15,
		13,  8, 11,  5,  6, 15,  0,  3,  4,  7,  2, 12,  1, 10, 14,  9,
		10,  6,  9,  0, 12, 11,  7, 13, 15,  1,  3, 14,  5,  2,  8,  4,
		3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7,  2, 14,
		// S5 
		2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14,  9,
		14, 11,  2, 12,  4,  7, 13,  1,  5,  0, 15, 10,  3,  9,  8,  6,
		4,  2,  1, 11, 10, 13,  7,  8, 15,  9, 12,  5,  6,  3,  0, 14,
		11,  8, 12,  7,  1, 14,  2, 13,  6, 15,  0,  9, 10,  4,  5,  3,
		// S6 
		12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11,
		10, 15,  4,  2,  7, 12,  9,  5,  6,  1, 13, 14,  0, 11,  3,  8,
		9, 14, 15,  5,  2,  8, 12,  3,  7,  0,  4, 10,  1, 13, 11,  6,
		4,  3,  2, 12,  9,  5, 15, 10, 11, 14,  1,  7,  6,  0,  8, 13,
		// S7 
		4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1,
		13,  0, 11,  7,  4,  9,  1, 10, 14,  3,  5, 12,  2, 15,  8,  6,
		1,  4, 11, 13, 12,  3,  7, 14, 10, 15,  6,  8,  0,  5,  9,  2,
		6, 11, 13,  8,  1,  4, 10,  7,  9,  5,  0, 15, 14,  2,  3, 12,
		// S8 
		13,  2,  8,  4,  6, 15, 11,  1, 10,  9,  3, 14,  5,  0, 12,  7,
		1, 15, 13,  8, 10,  3,  7,  4, 12,  5,  6, 11,  0, 14,  9,  2,
		7, 11,  4,  1,  9, 12, 14,  2,  0,  6, 10, 13, 15,  3,  5,  8,
		2,  1, 14,  7,  4, 10,  8, 13, 15, 12,  9,  0,  3,  5,  6, 11
};

CDes::CDes()
{
}

CDes::~CDes()
{
}

static void ByteToBit(bool *Out, const char *In, int bits)
{
	//MB_CHECK(bits <= 64);
    for (int i=0; i < bits; ++i)
        Out[i] = ( In[i>>3] >> (7 - i&7) ) & 1;
}

static void BitToByte(char *Out, const bool *In, int bits)
{
	//MB_CHECK(bits <= 64);
    memset(Out, 0, bits>>3);
    for(int i=0; i<bits; ++i)
        Out[i>>3] |= In[i]<<(7 - i&7);
}

static void RotateL(bool *In, int len, int loop)
{
	bool Tmp[256];

    memcpy(Tmp, In, loop);
    memcpy(In, In+loop, len-loop);
    memcpy(In+len-loop, Tmp, loop);
}

static void Xor(bool *InA, const bool *InB, int len)
{
    for(int i=0; i<len; ++i)
        InA[i] ^= InB[i];
}

static void Transform(bool *Out, 
					  bool *In,
					  const char *Table,
					  int len)
{
	bool Tmp[256];
    char btVal = 0;
    for (int i=0; i<len; ++i)
	{
		btVal = Table[i];
		if (btVal >= 1)
		{
			Tmp[i] = In[ btVal-1 ];
		}
	}
    memcpy(Out, Tmp, len);
}

static void S_func(bool Out[32],
				   const bool In[48])
{
    for (char i=0,j,k; 
		 i<8;
		 ++i,In+=6,Out+=4) 
	{
        j = (In[0]<<1) + In[5];
        k = (In[1]<<3) + (In[2]<<2) + (In[3]<<1) + In[4];	//组织SID下标
		
		for (int l=0; l<4; ++l)								//把相应4bit赋值
			Out[l] = (S_Box[i][j][k] >> (3 - l)) & 1;
    }
}

static void F_func(bool In[32], 
				   const bool Ki[48])
{
    bool MR[48];
    Transform(MR, In, E_Table, 48);
    Xor(MR, Ki, 48);
    S_func(In, MR);
    Transform(In, In, P_Table, 32);
}

bool CDes::RunDes(bool bType,
				  bool bMode,
				  char* In,
				  unsigned int uInDataLen,
				  char* Out,
				  unsigned int uOutDataLen,
				  const char *Key,
				  const unsigned char uKeyLen)
{
	//判断输入合法性
	//MB_CHECKF(In && Out && Key && uInDataLen && uOutDataLen && uKeyLen >= 16);
	//只处理8的整数倍，不足长度自己填充
	//MB_CHECKF(!(uInDataLen & 0x00000007));
	//MB_CHECKF(uOutDataLen >=uInDataLen);
	
	bool m_SubKey[3][16][48];//秘钥
	//构造并生成SubKeys
	unsigned char ucKey	= (uKeyLen >> 3) > 3 ? 3 : (uKeyLen >> 3);
	for (int i = 0; i < ucKey; i ++)
	{
		SetSubKey(&m_SubKey[i], &Key[i<<3]);
	}

	if (bMode == ECB)	
	{//ECB模式
		switch(ucKey)
		{
		case 1:
			{//单Key
				for (int i=0, j = uInDataLen>>3;
					 i<j;
					 ++i, Out+=8, In+=8)
				{
					DES(Out, In, &m_SubKey[0], bType);
				}
			}
			break;
		case 2:
			{//3DES 2Key
				for (int i=0, j = uInDataLen>>3;
					 i<j;
					 ++i, Out+=8, In+=8)
				{
					DES(Out,  In, &m_SubKey[0], bType);
					DES(Out, Out, &m_SubKey[1], !bType);
					DES(Out, Out, &m_SubKey[0], bType);
				}
			}
			break;
		default:
			{//3DES 3Key
				for (int i = 0, j = uInDataLen >> 3;
					 i < j;
					 ++i, Out += 8, In += 8)
				{
					DES(Out,  In, &m_SubKey[bType? 2 : 0], bType);
					DES(Out, Out, &m_SubKey[1]			 , !bType);
					DES(Out, Out, &m_SubKey[bType? 0 : 2], bType);	
				}
			}
			break;
		}
	}	
	else				
	{//CBC模式
			char	cvec[8]	=	"";	//扭转向量
			char	cvin[8]	=	""; //中间变量

			switch(ucKey)
			{//0
			case 1://单Key	
				{//a
					for (int i=0, j=uInDataLen>>3;
						 i<j;
						 ++i,Out+=8,In+=8)
					{//b
						if (bType	==	CDes::ENCRYPT)
						{//c
							for (int j=0; j < 8; ++j)		//将输入与扭转变量异或
							{//d
								cvin[j]	=	In[j] ^ cvec[j];
							}
						}
						else
						{//c
							memcpy(cvin, In, 8);
						}

						DES(Out, cvin, &m_SubKey[0], bType);
						if (bType == CDes::ENCRYPT)
						{//c
							memcpy(cvec, Out, 8);		//将输出设定为扭转变量
						}
						else
						{//c
							for (int j=0; j<8; ++j)		//将输出与扭转变量异或
							{//d
								Out[j]	=	Out[j] ^ cvec[j];
							}
							memcpy(cvec,cvin,8);		//将输入设定为扭转变量
						}//c
					}//b
				}//a
				break;
			case 2:	//3DES CBC 2Key
				{//a
					for (int i=0, j=uInDataLen>>3;
						 i<j;
						 ++i, Out+=8, In+=8)
					{//b
						if (bType == CDes::ENCRYPT)
						{//c
							for (int j=0;j<8;++j)		//将输入与扭转变量异或
							{//d
								cvin[j]	= In[j] ^ cvec[j];
							}
						}
						else
						{//c
							memcpy(cvin, In, 8);
						}
					
						DES(Out, cvin, &m_SubKey[0] ,bType);
						DES(Out, Out , &m_SubKey[1] ,!bType);
						DES(Out, Out , &m_SubKey[0] ,bType);				
						if (bType == CDes::ENCRYPT)
						{//c
							memcpy(cvec, Out, 8);		//将输出设定为扭转变量
						}
						else
						{//c
							for(int j=0;j<8;++j)		//将输出与扭转变量异或
							{//d
								Out[j] = Out[j] ^ cvec[j];
							}
							memcpy(cvec, cvin, 8);		//将输入设定为扭转变量
						}
					}//b
				}//a
				break;
			default://3DES CBC 3Key
				{//a
					for (int i=0,j=uInDataLen>>3;
						 i<j;
						 ++i,Out+=8,In+=8)
					{//b
						if (bType == CDes::ENCRYPT)
						{//c
							for(int j=0; j<8; ++j)		//将输入与扭转变量异或
							{//d
								cvin[j]	= In[j] ^ cvec[j];
							}
						}
						else
						{//c
							memcpy(cvin, In, 8);
						}
					
						DES(Out, cvin, &m_SubKey[bType ? 2 : 0], bType);
						DES(Out, Out,  &m_SubKey[1]            , !bType);
						DES(Out, Out,  &m_SubKey[bType ? 0 : 2], bType);
					
						if (bType	==	CDes::ENCRYPT)
						{//c
							memcpy(cvec, Out, 8);		//将输出设定为扭转变量
						}
						else
						{//c
							for (int j=0; j<8; ++j)		//将输出与扭转变量异或
							{//d
								Out[j] = Out[j] ^ cvec[j];
							}
							memcpy(cvec, cvin, 8);		//将输入设定为扭转变量
						}
					}//b
				}//a
				break;
		}//0
	}	
	return true;
}
/*******************************************************************/
/* 
 函 数 名 称:	RunPad
  功 能 描 述：	根据协议对加密前的数据进行填充
  参 数 说 明：	bType	:类型：PAD类型
				In		:数据串指针
				Out		:填充输出串指针
				nDataLen	:数据的长度
				padlen	:(in,out)输出buffer的长度，填充后的长度

  返回值 说明：	bool	:是否填充成功
/*******************************************************************/
////////////////////////////////////////////////////////////////////////
bool	CDes::RunPad(int nType,
					 const char* In,
					 unsigned int  uDataLen,
					 char* Out,
					 unsigned int & uPadLen)
{
	int res = (uDataLen & 0x00000007);				//得到除以8以后的余数
  
	unsigned int uTmpPadLen	= (uDataLen + 8 - res);
	//MB_CHECKF(uTmpPadLen <= uPadLen);
	uPadLen = uTmpPadLen;

	memcpy(Out, In, uDataLen);
	if(nType	==	CDes::PAD_ISO_1)
	{
	     memset(Out+uDataLen, 0x00, 8-res);
	}
	else if(nType	==	CDes::PAD_ISO_2)
	{
		 memset(Out+uDataLen  , 0x80, 1);
		 memset(Out+uDataLen+1, 0x00, 7-res);
	}
    else if(nType	==	CDes::PAD_PKCS_7)
	{
		 memset(Out+uDataLen, 8-res, 8-res);
	}
	else
	{
		 return false;
	}
  
	return true;
}
////////////////////////////////////////////////////////////////////////
//计算并填充子密钥到SubKey数据中
void CDes::SetSubKey(PSubKey pSubKey, const char Key[8])
{
	bool K[64], *KL=&K[0], *KR=&K[28];
    ByteToBit(K, Key, 64);
    Transform(K, K, PC1_Table, 56);
    for (int i=0; i<16; ++i) 
	{
        RotateL(KL, 28, LOOP_Table[i]);
        RotateL(KR, 28, LOOP_Table[i]);
        Transform((*pSubKey)[i], K, PC2_Table, 48);
    }
}
////////////////////////////////////////////////////////////////////////
//DES单元运算
void CDes::DES(char Out[8], 
			   char In[8],
			   const PSubKey pSubKey,
			   bool Type)
{
    bool M[64], tmp[32], *Li=&M[0], *Ri=&M[32];
    ByteToBit(M, In, 64);
    Transform(M, M, IP_Table, 64);
    if ( Type == ENCRYPT )
	{
        for (int i=0; i<16; ++i)
		{
            memcpy(tmp, Ri, 32);		//Ri[i-1] 保存
            F_func(Ri, (*pSubKey)[i]);	//Ri[i-1]经过转化和SBox输出为P
            Xor(Ri, Li, 32);			//Ri[i] = P XOR Li[i-1]
            memcpy(Li, tmp, 32);		//Li[i] = Ri[i-1]
        }
    }
	else
	{   
        for (int i=15; i>=0; --i) 
		{
			memcpy(tmp, Ri, 32);		//Ri[i-1] 保存
            F_func(Ri, (*pSubKey)[i]);	//Ri[i-1]经过转化和SBox输出为P
            Xor(Ri, Li, 32);			//Ri[i] = P XOR Li[i-1]
            memcpy(Li, tmp, 32);		//Li[i] = Ri[i-1]
        }
	}
	RotateL(M, 64, 32);					//Ri与Li换位重组M
    Transform(M, M, IPR_Table, 64);		//最后结果进行转化
    BitToByte(Out, M, 64);				//组织成字符
}
////////////////////////////////////////////////////////////////////////
//计算加密时填充的位数
bool CDes::Pad_PKCS_7_Count(char* In, int& count)
{
	int nLen  = count;
    count = In[count-1] & 0xff;

	if(count > nLen)
	{
	   // MB_CHECKF(0);
	}
	for(int i=1; i<=count; i++)
	{
	    if(In[nLen-i] != count)
		{
		   //  MB_CHECKF(0);
		}
	}
	return true;
}
////////////////////////////////////////////////////////////////////////
bool CDes::Encrypt_Pad_PKCS_7( const char *Key,
							   const unsigned char ucKeyLen,
							   char* In,
							   unsigned int uInDataLen,
							   char* Out,
							   unsigned int& uOutDataLen)
{
	//MB_CHECKF(
			  CDes::RunPad(PAD_PKCS_7,
						In,						   
						uInDataLen,
						Out,
						uOutDataLen);
	//);

	return CDes::RunDes(ENCRYPT,
						CBC,
						Out,
						uOutDataLen,
						Out,
						uOutDataLen,
						Key,
						ucKeyLen);
}
////////////////////////////////////////////////////////////////////////
bool CDes::Decrypt_Pad_PKCS_7( const char *Key,
							   const unsigned char ucKeyLen,
							   char* In,
							   unsigned int uInDataLen,
							   char* Out,
							   unsigned int& uOutDataLen)
{	
	CDes::RunDes(DECRYPT,
						CBC,
						In,
						uInDataLen,
						Out,
						uOutDataLen,
						Key,
						ucKeyLen);

	int nNewOutDataLen = uInDataLen;
	CDes::Pad_PKCS_7_Count(Out, nNewOutDataLen);
	//MB_CHECKF( (nNewOutDataLen > 0) && (uInDataLen >= nNewOutDataLen) );
	uOutDataLen = uInDataLen - nNewOutDataLen; 
	return true;
}
////////////////////////////////////////////////////////////////////////

  
