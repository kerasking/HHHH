package org.DeNA.DHLJ;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.view.Gravity;
import android.view.View;
import android.view.MotionEvent;
import android.widget.EditText;

import org.DeNA.DHLJ.NDVideoControl;
import org.DeNA.DHLJ.NDVideoView;

public class VideoActivity extends Activity
{
	public static NDVideoView m_pkView = null;

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		// setContentView(R.layout.activity_main);
		// test();
		go();
	}

	/*
	 * @Override public boolean onCreateOptionsMenu(Menu menu) { // Inflate the
	 * menu; this adds items to the action bar if it is present.
	 * getMenuInflater().inflate(R.menu.activity_main, menu); return true; }
	 */

	private void test()
	{
		LinearLayout pkLinearLayout = new LinearLayout(this);
		pkLinearLayout.setOrientation(LinearLayout.HORIZONTAL);

		LinearLayout.LayoutParams pkParams = new LinearLayout.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.FILL_PARENT);

		pkParams.gravity = Gravity.CENTER;

		EditText edit = new EditText(this);
		edit.setLayoutParams(pkParams);
		pkLinearLayout.addView(edit);
		edit.setText("hello world");

		setContentView(pkLinearLayout, pkParams);
	}

	private void go()
	{
		Log.d("video test", "@@ go");

		initView();
		playVideo();

		Log.d("video test", "@@ go -- done.");
	}

	private void initView()
	{
		Log.d("video test", "@@ initView");

		m_pkView = new NDVideoView(this.getApplicationContext());

		LinearLayout pkLinearLayout = new LinearLayout(this);
		pkLinearLayout.addView(m_pkView);
		pkLinearLayout.setOrientation(LinearLayout.HORIZONTAL);
		pkLinearLayout.setGravity(Gravity.CENTER_HORIZONTAL);

		LinearLayout.LayoutParams pkParams = new LinearLayout.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.FILL_PARENT);

		pkParams.gravity = Gravity.CENTER;
		m_pkView.setLayoutParams(pkParams);

		setContentView(pkLinearLayout, pkParams);
	};

	private void playVideo()
	{
		Log.d("video test", "@@ playVideo()");

		NDVideoControl pkVideoControl = new NDVideoControl(this);
		pkVideoControl.setVideoActivity(this);
		pkVideoControl.hide();

		m_pkView.setVideoPath("/sdcard/dhlj/SimplifiedChineseRes/res/Video/480_0.mp4");
		m_pkView.setBackgroundColor(0);
		// m_pkView.setMediaController(pkVideoControl);
		m_pkView.setOnCompletionListener(pkVideoControl);
		m_pkView.requestFocus();

		m_pkView.start();
		m_pkView.setVisibility(View.VISIBLE);

		Log.d("video test", "@@ playVideo() -- done");
	}

	public boolean onTouchEvent(MotionEvent event)
	{
		Log.d("video test",
				"@@ onTouchEvent, now stopPlayback() & continueRootView()");

		if (m_pkView != null)
		{
			m_pkView.stopPlayback();
			this.finish();
		}

		return true;
	}
}
