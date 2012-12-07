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
import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;

import android.app.Activity;
import android.os.Bundle;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.MediaController;
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
	public FrameLayout m_pkFrameView = null;
	private Cocos2dxHandler mHandler;
	public VideoView m_pkView = null;
	
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
		this.mGLSurfaceView.onResume();
	}

	@Override
	protected void onPause()
	{
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
		// FrameLayout
		ViewGroup.LayoutParams framelayout_params = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.FILL_PARENT);
		m_pkFrameView = new FrameLayout(this);
		m_pkFrameView.setLayoutParams(framelayout_params);

		// Cocos2dxEditText layout
		ViewGroup.LayoutParams edittext_layout_params = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT);
		Cocos2dxEditText edittext = new Cocos2dxEditText(this);
		edittext.setLayoutParams(edittext_layout_params);

		// ...add to FrameLayout
		m_pkFrameView.addView(edittext);

		// Cocos2dxGLSurfaceView
		this.mGLSurfaceView = this.onCreateView();

		// ...add to FrameLayout
		m_pkFrameView.addView(this.mGLSurfaceView);

		mGLSurfaceView.setCocos2dxRenderer(new Cocos2dxRenderer());
		mGLSurfaceView.setCocos2dxEditText(edittext);

		// Set framelayout as the content view
		ViewGroup.LayoutParams pkLayoutParams = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.FILL_PARENT,
                ViewGroup.LayoutParams.FILL_PARENT);
		setContentView(R.layout.helloworld_demo);
		//addContentView(m_pkFrameView,pkLayoutParams);

		addContentView(m_pkFrameView,pkLayoutParams);
		
		NDVideoControl pkVideoControl = new NDVideoControl(Cocos2dxActivity.this);
		pkVideoControl.setCocos2dxActivity(this);
		
		m_pkView = (VideoView)this.findViewById(R.id.videoPlay);
		m_pkView.setVideoPath("/sdcard/dhlj/SimplifiedChineseRes/res/Video/480_0.mp4");
		m_pkView.setMediaController(pkVideoControl);
		m_pkView.setOnCompletionListener(pkVideoControl);
		m_pkView.requestFocus();
		
        DisplayMetrics metrics = new DisplayMetrics(); getWindowManager().getDefaultDisplay().getMetrics(metrics);
        ViewGroup.LayoutParams params = (ViewGroup.LayoutParams) m_pkView.getLayoutParams();
        params.width =  metrics.widthPixels;
        params.height = metrics.heightPixels;
        m_pkView.setLayoutParams(params);
		
		m_pkView.start();
	}

	public Cocos2dxGLSurfaceView onCreateView()
	{
		return new Cocos2dxGLSurfaceView(this);
	}

	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
}
