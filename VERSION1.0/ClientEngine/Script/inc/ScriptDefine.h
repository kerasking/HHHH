/*
 *  ScriptDefine.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-5.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _SCRIPT_DEFINE_H_
#define _SCRIPT_DEFINE_H_

namespace NDEngine {

// ET-EXPORT
#ifdef __APPLE__

	#define ETLUAFUNC(nameinlua, funcaddr) \
	LuaStateMgrObj.GetState()->GetGlobals().Register(nameinlua, funcaddr);

	#define ETCFUNC(nameinlua, funcaddr) \
	LuaStateMgrObj.GetState()->GetGlobals().RegisterDirect(nameinlua, funcaddr);

	//#define ETVAR(nameinlua, varaddr)
	//LuaStateMgrObj.GetState()->GetGlobals()[nameinlua].SetInteger()

	#define ETCLASSBEGIN(classname) \
	bool ETClassBegin##classname(){ \
	LuaClass<classname>  LuaClassTmp(LuaStateMgrObj.GetState());

	#define ETSUBCLASSBEGIN(classname, parentclassname) \
	bool ETClassBegin##classname(){ \
	LuaClass<classname>  LuaClassTmp(LuaStateMgrObj.GetState()); \
	do \
	{ \
	std::string metaname("MetaClass_"); \
	metaname += typeid(classname).name(); \
	LuaObject meta = LuaStateMgrObj.GetState()->GetRegistry()[metaname.c_str()]; \
	std::string pmetaname("MetaClass_"); \
	pmetaname += typeid(parentclassname).name(); \
	LuaObject pmeta = LuaStateMgrObj.GetState()->GetRegistry()[pmetaname.c_str()]; \
	if (pmeta.IsNil()) \
	{ \
	pmeta = LuaStateMgrObj.GetState()->GetRegistry().CreateTable(pmetaname.c_str()); \
	pmeta.SetObject("__index", pmeta); \
	} \
	meta.SetMetaTable(pmeta); \
	} while (0);

	#define ETCONSTRUCT(nameinlua) \
	LuaClassTmp.create(nameinlua);

	#define ETCONSTRUCTARG1(nameinlua, argtype1) \
	LuaClassTmp.create<argtype1>(nameinlua);

	#define ETCONSTRUCTARG2(nameinlua, argtype1, argtype2) \
	LuaClassTmp.create<argtype1, argtype2>(nameinlua);

	#define ETCONSTRUCTARG3(nameinlua, argtype1, argtype2, argtype3) \
	LuaClassTmp.create<argtype1, argtype2, argtype3>(nameinlua);

	#define ETCONSTRUCTARG4(nameinlua, argtype1, argtype2, argtype3, argtype4) \
	LuaClassTmp.create<argtype1, argtype2, argtype3, argtype4>(nameinlua);

	#define ETCONSTRUCTARG5(nameinlua, argtype1, argtype2, argtype3, argtype5) \
	LuaClassTmp.create<argtype1, argtype2, argtype3, argtype4, argtype5>(nameinlua);

	#define ETMEMBERFUNC(nameinlua, funcaddr) \
	LuaClassTmp.def(nameinlua, funcaddr);

	#define ETDESTRUCT(nameinlua) \
	LuaClassTmp.destroy(nameinlua);

	#define ETCLASSEND(classname) \
	return true;} \
	bool bool##classname = ScriptMgrObj.AddRegClassFunc(&(ETClassBegin##classname));

	#define ETSTRUCTBEGIN(structname) \
	bool ETStructBegin##structname(){ \
	LuaClass<structname>  LuaClassTmp(LuaStateMgrObj.GetState()); \
	LuaClassTmp.createStruct(#structname);

	#define ETSTRUCTPROP(nameinlua, propaddr) \
	LuaClassTmp.prop(nameinlua, propaddr);

	#define ETSTRUCTEND(structname) \
	return true;} \
	bool bool##structname = ScriptMgrObj.AddRegClassFunc(&(ETStructBegin##structname));
	
#else // __APPLE__
	
	#define ETLUAFUNC(nameinlua, funcaddr) \
	LuaStateMgrObj.GetState()->GetGlobals().Register(nameinlua, funcaddr);

	#define ETCFUNC(nameinlua, funcaddr) \
	LuaStateMgrObj.GetState()->GetGlobals().RegisterDirect(nameinlua, funcaddr);

	//#define ETVAR(nameinlua, varaddr)
	//LuaStateMgrObj.GetState()->GetGlobals()[nameinlua].SetInteger()

	#define ETCLASSBEGIN(classname) \
	bool ETClassBegin##classname(){ \
	LuaClass<classname>  LuaClassTmp(LuaStateMgrObj.GetState());

#ifdef WIN32
#define ETSUBCLASSBEGIN(classname, parentclassname) \
	bool ETClassBegin##classname(){ \
	LuaClass<classname>  LuaClassTmp(LuaStateMgrObj.GetState()); \
	do \
	{ \
	std::string metaname("MetaClass_"); \
	metaname += typeid(classname).raw_name(); \
	LuaObject meta = LuaStateMgrObj.GetState()->GetRegistry()[metaname.c_str()]; \
	std::string pmetaname("MetaClass_"); \
	pmetaname += typeid(parentclassname).raw_name(); \
	LuaObject pmeta = LuaStateMgrObj.GetState()->GetRegistry()[pmetaname.c_str()]; \
	if (pmeta.IsNil()) \
	{ \
	pmeta = LuaStateMgrObj.GetState()->GetRegistry().CreateTable(pmetaname.c_str()); \
	pmeta.SetObject("__index", pmeta); \
} \
	meta.SetMetaTable(pmeta); \
} while (0);
#else
#define ETSUBCLASSBEGIN(classname, parentclassname) \
	bool ETClassBegin##classname(){ \
	LuaClass<classname>  LuaClassTmp(LuaStateMgrObj.GetState()); \
	do \
	{ \
	std::string metaname("MetaClass_"); \
	metaname += typeid(classname).name(); \
	LuaObject meta = LuaStateMgrObj.GetState()->GetRegistry()[metaname.c_str()]; \
	std::string pmetaname("MetaClass_"); \
	pmetaname += typeid(parentclassname).name(); \
	LuaObject pmeta = LuaStateMgrObj.GetState()->GetRegistry()[pmetaname.c_str()]; \
	if (pmeta.IsNil()) \
	{ \
	pmeta = LuaStateMgrObj.GetState()->GetRegistry().CreateTable(pmetaname.c_str()); \
	pmeta.SetObject("__index", pmeta); \
} \
	meta.SetMetaTable(pmeta); \
} while (0);
#endif

	#define ETCONSTRUCT(nameinlua) \
	LuaClassTmp.create(nameinlua);

	#define ETCONSTRUCTARG1(nameinlua, argtype1) \
	LuaClassTmp.create<argtype1>(nameinlua);

	#define ETCONSTRUCTARG2(nameinlua, argtype1, argtype2) \
	LuaClassTmp.create<argtype1, argtype2>(nameinlua);

	#define ETCONSTRUCTARG3(nameinlua, argtype1, argtype2, argtype3) \
	LuaClassTmp.create<argtype1, argtype2, argtype3>(nameinlua);

	#define ETCONSTRUCTARG4(nameinlua, argtype1, argtype2, argtype3, argtype4) \
	LuaClassTmp.create<argtype1, argtype2, argtype3, argtype4>(nameinlua);

	#define ETCONSTRUCTARG5(nameinlua, argtype1, argtype2, argtype3, argtype5) \
	LuaClassTmp.create<argtype1, argtype2, argtype3, argtype4, argtype5>(nameinlua);

	#define ETMEMBERFUNC(nameinlua, funcaddr) \
	LuaClassTmp.def(nameinlua, funcaddr);

	#define ETDESTRUCT(nameinlua) \
	LuaClassTmp.destroy(nameinlua);

	#define ETCLASSEND(classname) \
	return true;} \
 	bool bool##classname = ScriptMgrObj.AddRegClassFunc(&(ETClassBegin##classname));


	#define ETSTRUCTBEGIN(structname) \
 	bool ETStructBegin##structname(){ \
 	LuaClass<structname>  LuaClassTmp(LuaStateMgrObj.GetState()); \
 	LuaClassTmp.createStruct(#structname);

	#define ETSTRUCTPROP(nameinlua, propaddr) \
	LuaClassTmp.prop(nameinlua, propaddr);

	#define ETSTRUCTEND(structname) \
 	return true;} \
 	bool bool##structname = ScriptMgrObj.AddRegClassFunc(&(ETStructBegin##structname));

#endif
	
}


#endif // _SCRIPT_DEFINE_H_