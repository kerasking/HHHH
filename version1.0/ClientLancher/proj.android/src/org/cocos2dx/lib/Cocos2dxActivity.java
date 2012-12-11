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
import org.DeNA.DHLJ.R;
import org.DeNA.DHLJ.NDVideoView;

import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;

import android.app.Activity;
import android.content.Context;
import android.graphics.Paint;
import android.graphics.Paint.FontMetricsInt;
import android.os.Bundle;
import android.os.Message;
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
	private static Paint s_pPaint; 

	// ===========================================================
	// Fields
	// ===========================================================

	public Cocos2dxGLSurfaceView mGLSurfaceView;
	public FrameLayout m_pkFrameView = null;
	private Cocos2dxHandler mHandler;
	public NDVideoView m_pkView = null;

	// ===========================================================
	// Constructors
	// ===========================================================

	@Override
	protected void onCreate(final Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		this.mHandler = new Cocos2dxHandler(this);

		this.init();

		Cocos2dxHelper.init(this, this);
		TextView textView = new TextView(this);  
		s_pPaint = textView.getPaint(); 
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
		super.onResume();

		Cocos2dxHelper.onResume();
		// this.mGLSurfaceView.onResume();
	}

	@Override
	protected void onPause()
	{
		super.onPause();

		Cocos2dxHelper.onPause();
		// this.mGLSurfaceView.onPause();
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
		// Cocos2dxGLSurfaceView
		this.mGLSurfaceView = this.onCreateView();

		mGLSurfaceView.setCocos2dxRenderer(new Cocos2dxRenderer());

//		NDVideoControl pkVideoControl = new NDVideoControl(
//				Cocos2dxActivity.this);
//		pkVideoControl.setCocos2dxActivity(this);
//		pkVideoControl.hide();
//
//		LinearLayout tp = new LinearLayout(this.getApplicationContext());
//		LinearLayout.LayoutParams pkLayoutParams = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.FILL_PARENT);
//		m_pkView = new NDVideoView(this.getApplicationContext());
//		m_pkView.setVideoPath("/sdcard/dhlj/SimplifiedChineseRes/res/Video/480_0.mp4");
//		m_pkView.setBackgroundColor(0);
//		m_pkView.setMediaController(pkVideoControl);
//		m_pkView.setOnCompletionListener(pkVideoControl);
//		m_pkView.requestFocus();
//
//		setContentView(m_pkView);
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
	private static int getStringSize(String pString)				
	{
//		Paint pPaint = new Paint();
		int w = (int) Math.ceil(s_pPaint.measureText(pString)); 
		final FontMetricsInt fm = s_pPaint.getFontMetricsInt();
		int h = (int) Math.ceil(fm.bottom - fm.top);
//		Log.e("Cocos2dxActivity", String.valueOf(w)+" " +String.valueOf(h));
		return h*10000+w;
	}
}
