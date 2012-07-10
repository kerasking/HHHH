//////////////////////////////////////////////////////////////////////////
/*
    Provided by Õıø°¥®, Northeastern University (www.neu.edu.cn)
    Email: blackdrn@sohu.com
	This product is free for use.
*/
//////////////////////////////////////////////////////////////////////////

enum	{ENCRYPT,DECRYPT};

//////////////////////////////////////////////////////////////////////////

// º”/Ω‚√‹ Type°™ENCRYPT:º”√‹,DECRYPT:Ω‚√‹
void Des_Run(char Out[8], char In[8], bool Type=ENCRYPT);
// …Ë÷√√‹‘ø
void Des_SetKey(const char Key[8]);
void DesPriv_SetKey(const char Key[8]);

//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// add by jhzheng
typedef unsigned char uint_8;
typedef unsigned int  uint_32;
/*bool Encrypt(const uint_8* data,uint_32 nSrcLen,uint_8* out,uint_32& nDstLen,const uint_8* key);*/
void Run_PadPwd(char* pPwd,char*outStr);
char* Transcode(char* pstr,int length);
char* Encode(char* Str);
char* EncryptPwd(char* pPwd,char*key);
//////////////////////////////////////////////////////////////////////////
/***************用法********************/
/*
 #define DES_KEY "n7=7=7d" //密钥
 char* p = EncryptPwd((char*)password,DES_KEY);//p即为加密后的输出
 
 free(p);
 */
