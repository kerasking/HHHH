LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := luaplus

LOCAL_MODULE_FILENAME := libluaplus

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../

LOCAL_SRC_FILES := \
../../Main.cpp \
../../LuaCall.cpp \
../../LuaObject.cpp \
../../LuaPlus.cpp \
../../LuaPlus_Libs.cpp \
../../LuaPlusAddons.c \
../../LuaPlusFunctions.cpp \
../../LuaStackObject.cpp \
../../LuaStackTableIterator.cpp \
../../LuaState.cpp \
../../LuaState_DumpObject.cpp \
../../LuaStateOutFile.cpp \
../../LuaTableIterator.cpp \
../../src/lapi.c \
../../src/lauxlib.c \
../../src/lbaselib.c \
../../src/lcode.c \
../../src/ldblib.c \
../../src/ldebug.c \
../../src/ldo.c \
../../src/ldump.c \
../../src/lfunc.c \
../../src/lgc.c \
../../src/linit.c \
../../src/liolib.c \
../../src/llex.c \
../../src/lmathlib.c \
../../src/lmem.c \
../../src/loadlib.c \
../../src/lobject.c \
../../src/lopcodes.c \
../../src/loslib.c \
../../src/lparser.c \
../../src/lstate.c \
../../src/lstring.c \
../../src/lstrlib.c \
../../src/ltable.c \
../../src/ltablib.c \
../../src/ltm.c \
../../src/lundump.c \
../../src/lvm.c \
../../src/lwstrlib.c \
../../src/lzio.c \
../../src/print.c

include $(BUILD_SHARED_LIBRARY)
