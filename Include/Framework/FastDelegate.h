/**
快速代理类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef FASTDELEGATE_H
#define FASTDELEGATE_H

#if _MSC_VER > 1000
#pragma once
#endif 

#include <memory.h> 

#define FASTDELEGATE_USESTATICFUNCTIONHACK

#if defined(_MSC_VER) && !defined(__MWERKS__) && !defined(__VECTOR_C) && !defined(__ICL) && !defined(__BORLANDC__)
#define FASTDLGT_ISMSVC

#if (_MSC_VER <1300) 
#define FASTDLGT_VC6
#pragma warning(disable:4786) 
#endif

#endif

#if defined(_MSC_VER) && !defined(__MWERKS__)
#define FASTDLGT_MICROSOFT_MFP

#if !defined(__VECTOR_C)

#define FASTDLGT_HASINHERITANCE_KEYWORDS
#endif
#endif


#if defined(FASTDLGT_ISMSVC) && (_MSC_VER >=1310) 
#define FASTDELEGATE_ALLOW_FUNCTION_TYPE_SYNTAX
#endif


#if defined (__DMC__) || defined(__GNUC__) || defined(__ICL) || defined(__COMO__)
#define FASTDELEGATE_ALLOW_FUNCTION_TYPE_SYNTAX
#endif


#if defined (__MWERKS__)
#define FASTDELEGATE_ALLOW_FUNCTION_TYPE_SYNTAX
#endif

#ifdef __GNUC__ 
	
#define FASTDELEGATE_GCC_BUG_8271
#endif

namespace fastdelegate {
namespace detail {	

template <class OutputClass, class InputClass>
inline OutputClass implicit_cast(InputClass input){
	return input;
}











template <class OutputClass, class InputClass>
union horrible_union{
	OutputClass out;
	InputClass in;
};

template <class OutputClass, class InputClass>
inline OutputClass horrible_cast(const InputClass input){
	horrible_union<OutputClass, InputClass> u;
	
	
	
	typedef int ERROR_CantUseHorrible_cast[sizeof(InputClass)==sizeof(u)
		&& sizeof(InputClass)==sizeof(OutputClass) ? 1 : -1];
	u.in = input;
	return u.out;
}








#define FASTDELEGATEDECLARE(CLASSNAME)	class CLASSNAME;


#ifdef __MEDIUM__
#undef FASTDELEGATE_USESTATICFUNCTIONHACK
#endif


















#ifdef FASTDLGT_VC6

typedef const void * DefaultVoid;
#else

typedef void DefaultVoid;
#endif



template <class T>
struct DefaultVoidToVoid { typedef T type; };

template <>
struct DefaultVoidToVoid<DefaultVoid> {	typedef void type; };



template <class T>
struct VoidToDefaultVoid { typedef T type; };

template <>
struct VoidToDefaultVoid<void> { typedef DefaultVoid type; };
















#ifdef  FASTDLGT_MICROSOFT_MFP

#ifdef FASTDLGT_HASINHERITANCE_KEYWORDS
	
	
	
	class __single_inheritance GenericClass;
#endif
	
	
	
	
	
	
	class GenericClass {};
#else
	class GenericClass;
#endif


const int SINGLE_MEMFUNCPTR_SIZE = sizeof(void (GenericClass::*)());













template <int N>
struct SimplifyMemFunc {
	template <class X, class XFuncType, class GenericMemFuncType>
	inline static GenericClass *Convert(X *pthis, XFuncType function_to_bind,
		GenericMemFuncType &bound_func) {
		
	    
		typedef char ERROR_Unsupported_member_function_pointer_on_this_compiler[N-100];
		return 0;
	}
};



template <>
struct SimplifyMemFunc<SINGLE_MEMFUNCPTR_SIZE>  {
	template <class X, class XFuncType, class GenericMemFuncType>
	inline static GenericClass *Convert(X *pthis, XFuncType function_to_bind,
			GenericMemFuncType &bound_func) {
#if defined __DMC__
		
		
		
		bound_func = horrible_cast<GenericMemFuncType>(function_to_bind);
#else
        bound_func = reinterpret_cast<GenericMemFuncType>(function_to_bind);
#endif
        return reinterpret_cast<GenericClass *>(pthis);
	}
};











#ifdef FASTDLGT_MICROSOFT_MFP







template<>
struct SimplifyMemFunc< SINGLE_MEMFUNCPTR_SIZE + sizeof(int) >  {
	template <class X, class XFuncType, class GenericMemFuncType>
	inline static GenericClass *Convert(X *pthis, XFuncType function_to_bind,
		GenericMemFuncType &bound_func) {
		
		
        union {
			XFuncType func;
			struct {
				GenericMemFuncType funcaddress; 
				int delta;	     
			}s;
        } u;
		
		typedef int ERROR_CantUsehorrible_cast[sizeof(function_to_bind)==sizeof(u.s)? 1 : -1];
        u.func = function_to_bind;
		bound_func = u.s.funcaddress;
		return reinterpret_cast<GenericClass *>(reinterpret_cast<char *>(pthis) + u.s.delta);
	}
};











struct MicrosoftVirtualMFP {
	void (GenericClass::*codeptr)(); 
	int delta;		
	int vtable_index; 
};









struct GenericVirtualClass : virtual public GenericClass
{
	typedef GenericVirtualClass * (GenericVirtualClass::*ProbePtrType)();
	GenericVirtualClass * GetThis() { return this; }
};


template <>
struct SimplifyMemFunc<SINGLE_MEMFUNCPTR_SIZE + 2*sizeof(int) >
{

	template <class X, class XFuncType, class GenericMemFuncType>
	inline static GenericClass *Convert(X *pthis, XFuncType function_to_bind,
		GenericMemFuncType &bound_func) {
		union {
			XFuncType func;
			GenericClass* (X::*ProbeFunc)();
			MicrosoftVirtualMFP s;
		} u;
		u.func = function_to_bind;
		bound_func = reinterpret_cast<GenericMemFuncType>(u.s.codeptr);
		union {
			GenericVirtualClass::ProbePtrType virtfunc;
			MicrosoftVirtualMFP s;
		} u2;
		
		typedef int ERROR_CantUsehorrible_cast[sizeof(function_to_bind)==sizeof(u.s)
			&& sizeof(function_to_bind)==sizeof(u.ProbeFunc)
			&& sizeof(u2.virtfunc)==sizeof(u2.s) ? 1 : -1];
   
   
		u2.virtfunc = &GenericVirtualClass::GetThis;
		u.s.codeptr = u2.s.codeptr;
		return (pthis->*u.ProbeFunc)();
	}
};

#if (_MSC_VER <1300)




template <>
struct SimplifyMemFunc<SINGLE_MEMFUNCPTR_SIZE + 3*sizeof(int) >
{
	template <class X, class XFuncType, class GenericMemFuncType>
	inline static GenericClass *Convert(X *pthis, XFuncType function_to_bind,
		GenericMemFuncType &bound_func) {
		
		
		
		
		
		
		
		
		
		

		
		
		
		
		
		
		
		
		
		
		
		
		
		typedef char ERROR_VC6CompilerBug[-100];
		return 0;
	}
};


#else





template <>
struct SimplifyMemFunc<SINGLE_MEMFUNCPTR_SIZE + 3*sizeof(int) >
{
	template <class X, class XFuncType, class GenericMemFuncType>
	inline static GenericClass *Convert(X *pthis, XFuncType function_to_bind,
			GenericMemFuncType &bound_func) {
		
		
		union {
			XFuncType func;
			
			
			struct {
				GenericMemFuncType m_funcaddress; 
				int delta;		
				int vtordisp;		
				int vtable_index; 
			} s;
		} u;
		
		typedef int ERROR_CantUsehorrible_cast[sizeof(XFuncType)==sizeof(u.s)? 1 : -1];
		u.func = function_to_bind;
		bound_func = u.s.funcaddress;
		int virtual_delta = 0;
		if (u.s.vtable_index) { 
			
			
			const int * vtable = *reinterpret_cast<const int *const*>(
				reinterpret_cast<const char *>(pthis) + u.s.vtordisp );

			
			virtual_delta = u.s.vtordisp + *reinterpret_cast<const int *>(
				reinterpret_cast<const char *>(vtable) + u.s.vtable_index);
		}
		
        
        return reinterpret_cast<GenericClass *>(
			reinterpret_cast<char *>(pthis) + u.s.delta + virtual_delta);
	};
};
#endif 

#endif 

}  















































class DelegateMemento {
protected:
	
	
	typedef void (detail::GenericClass::*GenericMemFuncType)(); 
	detail::GenericClass *m_pthis;
	GenericMemFuncType m_pFunction;

#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
	typedef void (*GenericFuncPtr)(); 
	GenericFuncPtr m_pStaticFunction;
#endif

public:
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
	DelegateMemento() : m_pthis(0), m_pFunction(0), m_pStaticFunction(0) {};
	void clear() {
		m_pthis=0; m_pFunction=0; m_pStaticFunction=0;
	}
#else
	DelegateMemento() : m_pthis(0), m_pFunction(0) {};
	void clear() {	m_pthis=0; m_pFunction=0;	}
#endif
public:
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
	inline bool IsEqual (const DelegateMemento &x) const{
	    
		if (m_pFunction!=x.m_pFunction) return false;
		
		if (m_pStaticFunction!=x.m_pStaticFunction) return false;
		if (m_pStaticFunction!=0) return m_pthis==x.m_pthis;
		else return true;
	}
#else 
	inline bool IsEqual (const DelegateMemento &x) const{
		return m_pthis==x.m_pthis && m_pFunction==x.m_pFunction;
	}
#endif
	
	inline bool IsLess(const DelegateMemento &right) const {
		
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
		if (m_pStaticFunction !=0 || right.m_pStaticFunction!=0)
				return m_pStaticFunction < right.m_pStaticFunction;
#endif
		if (m_pthis !=right.m_pthis) return m_pthis < right.m_pthis;
	
	
	
		return memcmp(&m_pFunction, &right.m_pFunction, sizeof(m_pFunction)) < 0;

	}
	
	
	
	inline bool operator ! () const		
	{ return m_pthis==0 && m_pFunction==0; }
	inline bool empty() const		
	{ return m_pthis==0 && m_pFunction==0; }
public:
	DelegateMemento & operator = (const DelegateMemento &right)  {
		SetMementoFrom(right);
		return *this;
	}
	inline bool operator <(const DelegateMemento &right) {
		return IsLess(right);
	}
	inline bool operator >(const DelegateMemento &right) {
		return right.IsLess(*this);
	}
	DelegateMemento (const DelegateMemento &right)  :
		m_pFunction(right.m_pFunction), m_pthis(right.m_pthis)
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
		, m_pStaticFunction (right.m_pStaticFunction)
#endif
		{}
protected:
	void SetMementoFrom(const DelegateMemento &right)  {
		m_pFunction = right.m_pFunction;
		m_pthis = right.m_pthis;
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
		m_pStaticFunction = right.m_pStaticFunction;
#endif
	}
};

















namespace detail {

template < class GenericMemFunc, class StaticFuncPtr, class UnvoidStaticFuncPtr>
class ClosurePtr : public DelegateMemento {
public:
	

	
	
	
	template < class X, class XMemFunc >
	inline void bindmemfunc(X *pthis, XMemFunc function_to_bind ) {
		m_pthis = SimplifyMemFunc< sizeof(function_to_bind) >
			::Convert(pthis, function_to_bind, m_pFunction);
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
		m_pStaticFunction = 0;
#endif
	}
	
	
	
	
	template < class X, class XMemFunc>
	inline void bindconstmemfunc(const X *pthis, XMemFunc function_to_bind) {
		m_pthis= SimplifyMemFunc< sizeof(function_to_bind) >
			::Convert(const_cast<X*>(pthis), function_to_bind, m_pFunction);
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
		m_pStaticFunction = 0;
#endif
	}
#ifdef FASTDELEGATE_GCC_BUG_8271	
	template < class X, class XMemFunc>
	inline void bindmemfunc(const X *pthis, XMemFunc function_to_bind) {
		bindconstmemfunc(pthis, function_to_bind);
#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)
		m_pStaticFunction = 0;
#endif
	}
#endif
	
	inline GenericClass *GetClosureThis() const { return m_pthis; }
	inline GenericMemFunc GetClosureMemPtr() const { return reinterpret_cast<GenericMemFunc>(m_pFunction); }







#if !defined(FASTDELEGATE_USESTATICFUNCTIONHACK)







public:
	
	
	
	template< class DerivedClass >
	inline void CopyFrom (DerivedClass *pParent, const DelegateMemento &x) {
		SetMementoFrom(x);
		if (m_pStaticFunction!=0) {
			
			m_pthis=reinterpret_cast<GenericClass *>(pParent);
		}
	}
	
	
	
	template < class DerivedClass, class ParentInvokerSig >
	inline void bindstaticfunc(DerivedClass *pParent, ParentInvokerSig static_function_invoker,
				StaticFuncPtr function_to_bind ) {
		if (function_to_bind==0) { 
			m_pFunction=0;
		} else {
			bindmemfunc(pParent, static_function_invoker);
        }
		m_pStaticFunction=reinterpret_cast<GenericFuncPtr>(function_to_bind);
	}
	inline UnvoidStaticFuncPtr GetStaticFunction() const {
		return reinterpret_cast<UnvoidStaticFuncPtr>(m_pStaticFunction);
	}
#else











	template< class DerivedClass >
	inline void CopyFrom (DerivedClass *pParent, const DelegateMemento &right) {
		SetMementoFrom(right);
	}
	
	
	
	
	template < 	class DerivedClass, class ParentInvokerSig>
	inline void bindstaticfunc(DerivedClass *pParent, ParentInvokerSig static_function_invoker,
				StaticFuncPtr function_to_bind) {
		if (function_to_bind==0) { 
			m_pFunction=0;
		} else {
		   
		   
			bindmemfunc(pParent, static_function_invoker);
        }

		
		
		
		
		typedef int ERROR_CantUseEvilMethod[sizeof(GenericClass *)==sizeof(function_to_bind) ? 1 : -1];
		m_pthis = horrible_cast<GenericClass *>(function_to_bind);
		

		

	}
	
	
	
	
	inline UnvoidStaticFuncPtr GetStaticFunction() const {
		
		
		
		typedef int ERROR_CantUseEvilMethod[sizeof(UnvoidStaticFuncPtr)==sizeof(this) ? 1 : -1];
		return horrible_cast<UnvoidStaticFuncPtr>(this);
	}
#endif 

	
	inline bool IsEqualToStaticFuncPtr(StaticFuncPtr funcptr){
		if (funcptr==0) return empty();
	
	
		else return funcptr==reinterpret_cast<StaticFuncPtr>(GetStaticFunction());
	}
};


} 









































template<class RetType=detail::DefaultVoid>
class FastDelegate0 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)();
	typedef RetType (*UnvoidStaticFunctionPtr)();
	typedef RetType (detail::GenericClass::*GenericMemFn)();
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate0 type;

	
	FastDelegate0() { clear(); }
	FastDelegate0(const FastDelegate0 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate0 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate0 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate0 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate0 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate0 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate0(Y *pthis, DesiredRetType (X::* function_to_bind)() ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)()) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate0(const Y *pthis, DesiredRetType (X::* function_to_bind)() const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)() const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate0(DesiredRetType (*function_to_bind)() ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)() ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)()) {
		m_Closure.bindstaticfunc(this, &FastDelegate0::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() () const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction() const {
	return (*(m_Closure.GetStaticFunction()))(); }
};


template<class Param1, class RetType=detail::DefaultVoid>
class FastDelegate1 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate1 type;

	
	FastDelegate1() { clear(); }
	FastDelegate1(const FastDelegate1 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate1 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate1 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate1 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate1 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate1 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate1(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate1(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate1(DesiredRetType (*function_to_bind)(Param1 p1) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1)) {
		m_Closure.bindstaticfunc(this, &FastDelegate1::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1) const {
	return (*(m_Closure.GetStaticFunction()))(p1); }
};


template<class Param1, class Param2, class RetType=detail::DefaultVoid>
class FastDelegate2 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate2 type;

	
	FastDelegate2() { clear(); }
	FastDelegate2(const FastDelegate2 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate2 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate2 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate2 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate2 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate2 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate2(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate2(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate2(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2)) {
		m_Closure.bindstaticfunc(this, &FastDelegate2::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2); }
};


template<class Param1, class Param2, class Param3, class RetType=detail::DefaultVoid>
class FastDelegate3 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2, Param3 p3);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate3 type;

	
	FastDelegate3() { clear(); }
	FastDelegate3(const FastDelegate3 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate3 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate3 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate3 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate3 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate3 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate3(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate3(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate3(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3)) {
		m_Closure.bindstaticfunc(this, &FastDelegate3::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2, Param3 p3) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2, p3); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2, Param3 p3) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2, p3); }
};


template<class Param1, class Param2, class Param3, class Param4, class RetType=detail::DefaultVoid>
class FastDelegate4 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2, Param3 p3, Param4 p4);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate4 type;

	
	FastDelegate4() { clear(); }
	FastDelegate4(const FastDelegate4 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate4 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate4 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate4 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate4 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate4 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate4(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate4(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate4(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4)) {
		m_Closure.bindstaticfunc(this, &FastDelegate4::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2, Param3 p3, Param4 p4) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2, p3, p4); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2, Param3 p3, Param4 p4) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2, p3, p4); }
};


template<class Param1, class Param2, class Param3, class Param4, class Param5, class RetType=detail::DefaultVoid>
class FastDelegate5 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate5 type;

	
	FastDelegate5() { clear(); }
	FastDelegate5(const FastDelegate5 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate5 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate5 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate5 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate5 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate5 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate5(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate5(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate5(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5)) {
		m_Closure.bindstaticfunc(this, &FastDelegate5::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2, p3, p4, p5); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2, p3, p4, p5); }
};


template<class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class RetType=detail::DefaultVoid>
class FastDelegate6 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate6 type;

	
	FastDelegate6() { clear(); }
	FastDelegate6(const FastDelegate6 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate6 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate6 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate6 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate6 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate6 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate6(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate6(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate6(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6)) {
		m_Closure.bindstaticfunc(this, &FastDelegate6::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2, p3, p4, p5, p6); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2, p3, p4, p5, p6); }
};


template<class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class RetType=detail::DefaultVoid>
class FastDelegate7 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate7 type;

	
	FastDelegate7() { clear(); }
	FastDelegate7(const FastDelegate7 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate7 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate7 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate7 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate7 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate7 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate7(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate7(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate7(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7)) {
		m_Closure.bindstaticfunc(this, &FastDelegate7::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2, p3, p4, p5, p6, p7); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2, p3, p4, p5, p6, p7); }
};


template<class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class Param8, class RetType=detail::DefaultVoid>
class FastDelegate8 {
private:
	typedef typename detail::DefaultVoidToVoid<RetType>::type DesiredRetType;
	typedef DesiredRetType (*StaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8);
	typedef RetType (*UnvoidStaticFunctionPtr)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8);
	typedef RetType (detail::GenericClass::*GenericMemFn)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8);
	typedef detail::ClosurePtr<GenericMemFn, StaticFunctionPtr, UnvoidStaticFunctionPtr> ClosureType;
	ClosureType m_Closure;
public:
	
	typedef FastDelegate8 type;

	
	FastDelegate8() { clear(); }
	FastDelegate8(const FastDelegate8 &x) {
		m_Closure.CopyFrom(this, x.m_Closure); }
	void operator = (const FastDelegate8 &x)  {
		m_Closure.CopyFrom(this, x.m_Closure); }
	bool operator ==(const FastDelegate8 &x) const {
		return m_Closure.IsEqual(x.m_Closure);	}
	bool operator !=(const FastDelegate8 &x) const {
		return !m_Closure.IsEqual(x.m_Closure); }
	bool operator <(const FastDelegate8 &x) const {
		return m_Closure.IsLess(x.m_Closure);	}
	bool operator >(const FastDelegate8 &x) const {
		return x.m_Closure.IsLess(m_Closure);	}
	
	template < class X, class Y >
	FastDelegate8(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) ) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind); }
	template < class X, class Y >
	inline void bind(Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8)) {
		m_Closure.bindmemfunc(detail::implicit_cast<X*>(pthis), function_to_bind);	}
	
	template < class X, class Y >
	FastDelegate8(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X*>(pthis), function_to_bind);	}
	template < class X, class Y >
	inline void bind(const Y *pthis, DesiredRetType (X::* function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) const) {
		m_Closure.bindconstmemfunc(detail::implicit_cast<const X *>(pthis), function_to_bind);	}
	
	
	FastDelegate8(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) ) {
		bind(function_to_bind);	}
	
	void operator = (DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) ) {
		bind(function_to_bind);	}
	inline void bind(DesiredRetType (*function_to_bind)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8)) {
		m_Closure.bindstaticfunc(this, &FastDelegate8::InvokeStaticFunction,
			function_to_bind); }
	
	RetType operator() (Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) const {
	return (m_Closure.GetClosureThis()->*(m_Closure.GetClosureMemPtr()))(p1, p2, p3, p4, p5, p6, p7, p8); }
	
private:
	typedef struct SafeBoolStruct {
		int a_data_pointer_to_this_is_0_on_buggy_compilers;
		StaticFunctionPtr m_nonzero;
	} UselessTypedef;
    typedef StaticFunctionPtr SafeBoolStruct::*unspecified_bool_type;
public:
	operator unspecified_bool_type() const {
        return empty()? 0: &SafeBoolStruct::m_nonzero;
    }
	
	inline bool operator==(StaticFunctionPtr funcptr) {
		return m_Closure.IsEqualToStaticFuncPtr(funcptr);	}
	inline bool operator!=(StaticFunctionPtr funcptr) {
		return !m_Closure.IsEqualToStaticFuncPtr(funcptr);    }
	inline bool operator ! () const	{	
			return !m_Closure; }
	inline bool empty() const	{
			return !m_Closure; }
	void clear() { m_Closure.clear();}
	
	const DelegateMemento & GetMemento() { return m_Closure; }
	void SetMemento(const DelegateMemento &any) { m_Closure.CopyFrom(this, any); }

private:	
	RetType InvokeStaticFunction(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) const {
	return (*(m_Closure.GetStaticFunction()))(p1, p2, p3, p4, p5, p6, p7, p8); }
};













#ifdef FASTDELEGATE_ALLOW_FUNCTION_TYPE_SYNTAX



template <typename Signature>
class FastDelegate;






template<typename R>
class FastDelegate< R (  ) >
  
  : public FastDelegate0 < R >
{
public:
  
  typedef FastDelegate0 < R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)(  ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)(  ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)(  ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1>
class FastDelegate< R ( Param1 ) >
  
  : public FastDelegate1 < Param1, R >
{
public:
  
  typedef FastDelegate1 < Param1, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2>
class FastDelegate< R ( Param1, Param2 ) >
  
  : public FastDelegate2 < Param1, Param2, R >
{
public:
  
  typedef FastDelegate2 < Param1, Param2, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2, class Param3>
class FastDelegate< R ( Param1, Param2, Param3 ) >
  
  : public FastDelegate3 < Param1, Param2, Param3, R >
{
public:
  
  typedef FastDelegate3 < Param1, Param2, Param3, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2, Param3 p3 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2, class Param3, class Param4>
class FastDelegate< R ( Param1, Param2, Param3, Param4 ) >
  
  : public FastDelegate4 < Param1, Param2, Param3, Param4, R >
{
public:
  
  typedef FastDelegate4 < Param1, Param2, Param3, Param4, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2, class Param3, class Param4, class Param5>
class FastDelegate< R ( Param1, Param2, Param3, Param4, Param5 ) >
  
  : public FastDelegate5 < Param1, Param2, Param3, Param4, Param5, R >
{
public:
  
  typedef FastDelegate5 < Param1, Param2, Param3, Param4, Param5, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6>
class FastDelegate< R ( Param1, Param2, Param3, Param4, Param5, Param6 ) >
  
  : public FastDelegate6 < Param1, Param2, Param3, Param4, Param5, Param6, R >
{
public:
  
  typedef FastDelegate6 < Param1, Param2, Param3, Param4, Param5, Param6, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7>
class FastDelegate< R ( Param1, Param2, Param3, Param4, Param5, Param6, Param7 ) >
  
  : public FastDelegate7 < Param1, Param2, Param3, Param4, Param5, Param6, Param7, R >
{
public:
  
  typedef FastDelegate7 < Param1, Param2, Param3, Param4, Param5, Param6, Param7, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};






template<typename R, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class Param8>
class FastDelegate< R ( Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8 ) >
  
  : public FastDelegate8 < Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, R >
{
public:
  
  typedef FastDelegate8 < Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, R > BaseType;

  
  typedef FastDelegate SelfType;

  
  FastDelegate() : BaseType() { }

  template < class X, class Y >
  FastDelegate(Y * pthis,
    R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ))
    : BaseType(pthis, function_to_bind)  { }

  template < class X, class Y >
  FastDelegate(const Y *pthis,
      R (X::* function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ) const)
    : BaseType(pthis, function_to_bind)
  {  }

  FastDelegate(R (*function_to_bind)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ))
    : BaseType(function_to_bind)  { }
  void operator = (const BaseType &x)  {
		*static_cast<BaseType*>(this) = x; }
};


#endif 

























#ifdef FASTDLGT_VC6
#define FASTDLGT_RETTYPE detail::VoidToDefaultVoid<RetType>::type
#else
#define FASTDLGT_RETTYPE RetType
#endif


template <class X, class Y, class RetType>
FastDelegate0<FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)()) {
	return FastDelegate0<FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class RetType>
FastDelegate0<FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)() const) {
	return FastDelegate0<FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class RetType>
FastDelegate1<Param1, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1)) {
	return FastDelegate1<Param1, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class RetType>
FastDelegate1<Param1, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1) const) {
	return FastDelegate1<Param1, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class RetType>
FastDelegate2<Param1, Param2, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2)) {
	return FastDelegate2<Param1, Param2, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class RetType>
FastDelegate2<Param1, Param2, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2) const) {
	return FastDelegate2<Param1, Param2, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class Param3, class RetType>
FastDelegate3<Param1, Param2, Param3, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3)) {
	return FastDelegate3<Param1, Param2, Param3, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class Param3, class RetType>
FastDelegate3<Param1, Param2, Param3, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3) const) {
	return FastDelegate3<Param1, Param2, Param3, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class RetType>
FastDelegate4<Param1, Param2, Param3, Param4, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4)) {
	return FastDelegate4<Param1, Param2, Param3, Param4, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class RetType>
FastDelegate4<Param1, Param2, Param3, Param4, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4) const) {
	return FastDelegate4<Param1, Param2, Param3, Param4, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class RetType>
FastDelegate5<Param1, Param2, Param3, Param4, Param5, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5)) {
	return FastDelegate5<Param1, Param2, Param3, Param4, Param5, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class RetType>
FastDelegate5<Param1, Param2, Param3, Param4, Param5, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5) const) {
	return FastDelegate5<Param1, Param2, Param3, Param4, Param5, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class RetType>
FastDelegate6<Param1, Param2, Param3, Param4, Param5, Param6, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6)) {
	return FastDelegate6<Param1, Param2, Param3, Param4, Param5, Param6, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class RetType>
FastDelegate6<Param1, Param2, Param3, Param4, Param5, Param6, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6) const) {
	return FastDelegate6<Param1, Param2, Param3, Param4, Param5, Param6, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class RetType>
FastDelegate7<Param1, Param2, Param3, Param4, Param5, Param6, Param7, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7)) {
	return FastDelegate7<Param1, Param2, Param3, Param4, Param5, Param6, Param7, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class RetType>
FastDelegate7<Param1, Param2, Param3, Param4, Param5, Param6, Param7, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7) const) {
	return FastDelegate7<Param1, Param2, Param3, Param4, Param5, Param6, Param7, FASTDLGT_RETTYPE>(x, func);
}


template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class Param8, class RetType>
FastDelegate8<Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8)) {
	return FastDelegate8<Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, FASTDLGT_RETTYPE>(x, func);
}

template <class X, class Y, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class Param8, class RetType>
FastDelegate8<Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, FASTDLGT_RETTYPE> MakeDelegate(Y* x, RetType (X::*func)(Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8) const) {
	return FastDelegate8<Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, FASTDLGT_RETTYPE>(x, func);
}


 
#undef FASTDLGT_RETTYPE

} 

#endif 

