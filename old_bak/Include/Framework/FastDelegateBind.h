/**
快速代理绑定类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef FASTDELEGATEBIND_H
#define FASTDELEGATEBIND_H
#if _MSC_VER > 1000
#pragma once
#endif 

#ifdef FASTDELEGATE_ALLOW_FUNCTION_TYPE_SYNTAX

namespace fastdelegate {


template <class X, class Y, class RetType>
FastDelegate< RetType (  ) >
bind(
    RetType (X::*func)(  ),
    Y * y,
    ...)
{
  return FastDelegate< RetType (  ) >(y, func);
}

template <class X, class Y, class RetType>
FastDelegate< RetType (  ) >
bind(
    RetType (X::*func)(  ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType (  ) >(y, func);
}


template <class X, class Y, class RetType, class Param1>
FastDelegate< RetType ( Param1 p1 ) >
bind(
    RetType (X::*func)( Param1 p1 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1>
FastDelegate< RetType ( Param1 p1 ) >
bind(
    RetType (X::*func)( Param1 p1 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2>
FastDelegate< RetType ( Param1 p1, Param2 p2 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2>
FastDelegate< RetType ( Param1 p1, Param2 p2 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2, class Param3>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2, class Param3>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7 ) >(y, func);
}


template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class Param8>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ),
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ) >(y, func);
}

template <class X, class Y, class RetType, class Param1, class Param2, class Param3, class Param4, class Param5, class Param6, class Param7, class Param8>
FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ) >
bind(
    RetType (X::*func)( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ) const,
    Y * y,
    ...)
{
  return FastDelegate< RetType ( Param1 p1, Param2 p2, Param3 p3, Param4 p4, Param5 p5, Param6 p6, Param7 p7, Param8 p8 ) >(y, func);
}


#endif 

} 

#endif 

