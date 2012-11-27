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
		super.onCreate(savedInstanceState);
	}
	
    static
    {
        System.loadLibrary("luaplus");
        System.loadLibrary("NetWork");
        System.loadLibrary("tinyxml");
        System.loadLibrary("ClientEngine");
        System.loadLibrary("ClientLogic");
        System.loadLibrary("GameLauncher");
    }
}