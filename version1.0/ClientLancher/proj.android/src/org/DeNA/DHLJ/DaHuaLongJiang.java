package org.DeNA.DHLJ;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Stack;

import org.cocos2dx.lib.Cocos2dxActivity;

import org.cocos2dx.lib.Cocos2dxEditText;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParserException;

import com.mobage.android.C2DMBaseReceiver;
import com.mobage.android.Mobage;
import com.mobage.android.Mobage.PlatformListener;
import com.mobage.android.Mobage.ServerMode;
import com.mobage.android.cn.dynamicmenubar.DynamicMenuBar;
import com.mobage.android.social.BalanceButton;
import com.mobage.android.social.common.RemoteNotification;
import com.mobage.android.social.common.RemoteNotification.RemoteNotificationListener;

import org.DeNA.DHLJ.SocialUtils;
import android.R;
import android.app.ActionBar.LayoutParams;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.webkit.CookieSyncManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Environment;
import android.text.Layout;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.MediaController;
import android.widget.VideoView;

public class DaHuaLongJiang extends Cocos2dxActivity
{
	private static final String TAG = "DaHuaLongJiang";
	public static DaHuaLongJiang ms_pkDHLJ = null;
	private PlatformListener mPlatformListener;
	private DynamicMenuBar menubar;

	protected void onCreate(Bundle savedInstanceState)
	{
		if (isSDCardCanUse())
		{
			ms_pkDHLJ = this;
			super.onCreate(savedInstanceState);
			Log.e(TAG, "onCreate called");

			Mobage.registerMobageResource(this, "org.DeNA.DHLJ.R");
			SocialUtils.initializeMobage(this);
			mPlatformListener = SocialUtils.createPlatformListener(true);
			Mobage.addPlatformListener(mPlatformListener);

			RemoteNotification.setListener(new RemoteNotificationListener()
			{

				@Override
				public void handleReceive(Context context, Intent intent)
				{
					// You can use static method which performing a notification
					// in status bar.
					C2DMBaseReceiver.displayStatusBarNotification(context,
							intent);

					// If you want to handle message yourself, below lists one
					// of keys:
					// "NOTIFICATION_MESSAGE"
					// You should analysis the json string by yourself, keys are
					// "style", "message", "iconUrl", "extras", etc,
					Bundle bundle = intent.getExtras();
					String message = bundle.getString("NOTIFICATION_MESSAGE");
					try
					{
						JSONObject obj = new JSONObject(message);
						String style = obj.getString("style");
						String iconUrl = obj.getString("iconUrl");
						String msg = obj.getString("message");

						Map<String, String> extras = new HashMap<String, String>();
						JSONObject e = new JSONObject(obj.getString("extras"));
						Iterator<String> keys = e.keys();
						while (keys.hasNext())
						{
							String key = keys.next();
							String val = e.optString(key);
							if (val != null)
							{
								extras.put(key, val);
							}
						}
					} catch (JSONException ex)
					{
						ex.printStackTrace();
					}
				}
			});

			nativeInit(480, 320);

			Mobage.checkLoginStatus();
			Mobage.onCreate();

			menubar = new DynamicMenuBar(this);
			menubar.setMenubarVisibility(View.VISIBLE);
			menubar.setMenuIconGravity(Gravity.TOP | Gravity.LEFT);
		} else
		{
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("Title");
			alertDialog.setMessage("Message");

			//alertDialog.setIcon(R.drawable.dhlj_icon);
			alertDialog.show();
		}
	}

	@Override
	public void onPause()
	{
		super.onPause();
		Mobage.onPause();
	}

	@Override
	public void onResume()
	{
		Mobage.setCurrentActivity(this);
		super.onResume();
		Mobage.onResume();
	}

	@Override
	public void onStop()
	{
		Log.e(TAG, "onStop called");
		super.onStop();
	}

	@Override
	public void onDestroy()
	{
		Log.e(TAG, "onDestroy called");
		super.onDestroy();
		Mobage.onStop();
	}

	@Override
	public void onRestart()
	{
		Log.e(TAG, "onRestart called");
		super.onRestart();
		Mobage.onRestart();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig)
	{
		super.onConfigurationChanged(newConfig);
	}

	public void setMain()
	{
		Log.e(TAG, "DaHuaLongJiang::setMain()");
		
		View rootView = (View) getView();
		FrameLayout parent = (FrameLayout) rootView.getParent();
		if (parent != null)
		{
			parent.removeView(rootView);
		}
		menubar.removeAllViews();
		addEditView();
		menubar.addView(rootView);

		ViewGroup.LayoutParams pkParams = new ViewGroup.LayoutParams(
				LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
		this.setContentView(menubar, pkParams);
	}

	public void addEditView(){
        // Cocos2dxEditText layout
        ViewGroup.LayoutParams edittext_layout_params =
            new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT,
                                       ViewGroup.LayoutParams.WRAP_CONTENT);
        Cocos2dxEditText edittext = new Cocos2dxEditText(this);
        edittext.setLayoutParams(edittext_layout_params);
        //edittext.setVisibility( View.INVISIBLE );

		// add edit to layout
		menubar.addView(edittext);

		// set this edit to cocos2dx surface view
		Cocos2dxGLSurfaceView surfaceView = getView();
		surfaceView.setCocos2dxEditText(edittext);
	}
	
	public void LoginComplete(int userid)
	{
		onLoginComplete(userid);
	}

	public void LoginError(String error)
	{
		onLoginError(error);
	}

	private void showBalanceButton() {
		Log.v(TAG, "begin showBalanceButton");

		Rect rect = new Rect(200, 70, 100, 36);
		BalanceButton button = com.mobage.android.social.common.Service.getBalanceButton(rect); 
//		LinearLayout layout = (LinearLayout)mActivity.findViewById(R.id.placeholder); layout.addView(button);
	}
	
	public void changeViewToVideo()
	{
	}

	public boolean isSDCardCanUse()
	{
		String strState = Environment.getExternalStorageState();

		if (Environment.MEDIA_MOUNTED.equals(strState))
		{
			return true;
		}

		return false;
	}

	public static int playVideo(final String strFile)
	{
		if (strFile.length() == 0)
		{
			return -1;
		}

		if (null == ms_pkDHLJ)
		{
			return -1;
		}

		ms_pkDHLJ.m_pkView.start();

		return 0;
	}

	public static int stopVideo(final String strFile)
	{
		return 0;
	}

	static
	{
		System.loadLibrary("mobage");
		System.loadLibrary("iconv");
		System.loadLibrary("cocos2d");
		System.loadLibrary("GameLauncher");
	}

	private static native void nativeInit(int w, int h);

	private static native void onLoginComplete(int userid);

	private static native void onLoginError(String error);
}
