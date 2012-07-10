/*按下Ctrl+鼠标弹出设置UI对话框
*/
#ifndef __SPY_X_HH__
#define __SPY_X_HH__

#include <windows.h>

#ifdef USE_DLL
#define EXT_CDLL extern "C" __declspec(dllexport)
#else
#define EXT_CDLL 
#endif

EXT_CDLL LRESULT CALLBACK
SNewWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam);

EXT_CDLL LRESULT
SSetOldProc(WNDPROC proc);

EXT_CDLL void 
SSetHinstance(HINSTANCE hInstance);



#endif //__SPY_X_HH__
