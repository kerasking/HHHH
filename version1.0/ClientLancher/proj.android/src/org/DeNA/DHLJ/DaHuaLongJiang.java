package org.DeNA.DHLJ;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxEditText;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.KeyEvent;

public class DaHuaLongJiang extends Cocos2dxActivity
{
	protected void onCreate(Bundle savedInstanceState)
	{
		nativeInit(480,320);
		super.onCreate(savedInstanceState);
	}
	
    static
    {
        System.loadLibrary("luaplus");
        System.loadLibrary("tinyxml");
        System.loadLibrary("cocos2d");
        System.loadLibrary("ClientEngine");
        System.loadLibrary("ClientLogic");
        System.loadLibrary("GameLauncher");
    }
    
    private static native void nativeInit(int w, int h);
}