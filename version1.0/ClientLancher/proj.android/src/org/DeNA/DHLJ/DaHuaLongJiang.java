package org.DeNA.DHLJ;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxEditText;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.app.AlertDialog;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.view.KeyEvent;

public class DaHuaLongJiang extends Cocos2dxActivity {
	protected void onCreate(Bundle savedInstanceState) {
		if (isSDCardCanUse()) {
			nativeInit(480, 320);
			super.onCreate(savedInstanceState);
		} else {
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("Title");
			alertDialog.setMessage("Message");

			alertDialog.setIcon(R.drawable.dhlj_icon);
			alertDialog.show();
		}
	}

	public boolean isSDCardCanUse() {
		String strState = Environment.getExternalStorageState();

		if (Environment.MEDIA_MOUNTED.equals(strState)) {
			return true;
		}

		return false;
	}

	static {
		System.loadLibrary("luaplus");
		System.loadLibrary("tinyxml");
		System.loadLibrary("cocos2d");
		System.loadLibrary("ClientEngine");
		System.loadLibrary("ClientLogic");
		System.loadLibrary("GameLauncher");
	}

	private static native void nativeInit(int w, int h);
}