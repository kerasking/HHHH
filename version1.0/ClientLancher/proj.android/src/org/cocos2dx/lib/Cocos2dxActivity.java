/****************************************************************************
Copyright (c) 2010-2011 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lib;

import org.DeNA.DHLJ.NDJavaVideoPlayer;
import org.DeNA.DHLJ.NDVideoControl;
import org.DeNA.DHLJ.NDVideoView;

import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;

import android.app.Activity;
import android.content.Context;
import android.graphics.Paint;
import android.graphics.Paint.FontMetricsInt;
import android.os.Bundle;
import android.os.Message;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.ViewGroup.LayoutParams;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.MediaController;
import android.widget.TextView;
import android.widget.VideoView;

public abstract class Cocos2dxActivity extends Activity implements
		Cocos2dxHelperListener
{
	// ===========================================================
	// Constants
	// ===========================================================

	private static final String TAG = Cocos2dxActivity.class.getSimpleName();

	// ===========================================================
	// Fields
	// ===========================================================

	public Cocos2dxGLSurfaceView mGLSurfaceView;
	private Cocos2dxHandler mHandler;

	public FrameLayout m_pkFrameView = null;

	// ===========================================================
	// Constructors
	// ===========================================================

	@Override
	protected void onCreate(final Bundle savedInstanceState)
	{
		Log.d("init", "@@ Cocos2dxActivity.onCreate()");

		super.onCreate(savedInstanceState);

		this.mHandler = new Cocos2dxHandler(this);

		this.init();

		Cocos2dxHelper.init(this, this);
	}

	// ===========================================================
	// Getter & Setter
	// ===========================================================

	// ===========================================================
	// Methods for/from SuperClass/Interfaces
	// ===========================================================

	@Override
	protected void onResume()
	{
		Log.i("DaHuaLongJiang", "Entry Cocos2dxActivity onResume");
		super.onResume();

		Cocos2dxHelper.onResume();
		this.mGLSurfaceView.onResume();
	}

	@Override
	protected void onPause()
	{
		Log.i("DaHuaLongJiang", "Entry Cocos2dxActivity onPause");
		super.onPause();

		Cocos2dxHelper.onPause();
		this.mGLSurfaceView.onPause();
	}

	@Override
	public void showDialog(final String pTitle, final String pMessage)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_DIALOG;
		msg.obj = new Cocos2dxHandler.DialogMessage(pTitle, pMessage);
		this.mHandler.sendMessage(msg);
	}

	@Override
	public void showEditTextDialog(final String pTitle, final String pContent,
			final int pInputMode, final int pInputFlag, final int pReturnType,
			final int pMaxLength)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_EDITBOX_DIALOG;
		msg.obj = new Cocos2dxHandler.EditBoxMessage(pTitle, pContent,
				pInputMode, pInputFlag, pReturnType, pMaxLength);
		this.mHandler.sendMessage(msg);
	}

	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		return super.onKeyDown(keyCode, event);
	}

	public void onBackPressed()
	{
		finish();
	}

	@Override
	public void runOnGLThread(final Runnable pRunnable)
	{
		this.mGLSurfaceView.queueEvent(pRunnable);
	}

	// ===========================================================
	// Methods
	// ===========================================================
	public void init()
	{
		Log.d("init", "@@ Cocos2dxActivity.init()");

		// Cocos2dxGLSurfaceView
		this.mGLSurfaceView = this.onCreateView();

		Log.d("init", "@@ to create Cocos2dxRenderer");
		mGLSurfaceView.setCocos2dxRenderer(new Cocos2dxRenderer());

 		ViewGroup.LayoutParams pkLayoutParams = new ViewGroup.LayoutParams(
 				LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);

		 setContentView(mGLSurfaceView,pkLayoutParams);
	}

	public Cocos2dxGLSurfaceView onCreateView()
	{
		return new Cocos2dxGLSurfaceView(this);
	}

	public Cocos2dxGLSurfaceView getView()
	{
		return this.mGLSurfaceView;
	}
	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
}
