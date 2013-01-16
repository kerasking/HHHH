/*
*
*/

#ifndef NDPACKAGEDEFINE_H
#define NDPACKAGEDEFINE_H

#define SafeDel(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete pObject;\
		pObject = 0;\
	}\
} while (false)

#define SafeDelArray(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete [] pObject;\
		pObject = 0;\
	}\
} while (false)

#endif