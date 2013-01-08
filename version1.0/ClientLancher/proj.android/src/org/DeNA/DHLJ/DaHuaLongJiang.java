package org.DeNA.DHLJ;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
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
import com.mobage.android.Error;
import com.mobage.android.Mobage;
import com.mobage.android.Mobage.PlatformListener;
import com.mobage.android.Mobage.ServerMode;
import com.mobage.android.cn.dynamicmenubar.DynamicMenuBar;
import com.mobage.android.social.BalanceButton;
import com.mobage.android.social.common.RemoteNotification;
import com.mobage.android.social.common.RemoteNotification.RemoteNotificationListener;
import com.mobage.android.social.common.RemoteNotificationResponse;

import org.DeNA.DHLJ.PushService;

import org.DeNA.DHLJ.SocialUtils;
import android.R;
//import android.app.ActionBar.LayoutParams;
import android.app.AlertDialog;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.net.ParseException;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewParent;
import android.webkit.CookieSyncManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings.Secure;
import android.text.Layout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.FrameLayout;
import android.widget.MediaController;
import android.widget.VideoView;

public class DaHuaLongJiang extends Cocos2dxActivity
{
	private String mDeviceID;
	private static final String TAG = "DaHuaLongJiang";
	public static DaHuaLongJiang ms_pkDHLJ = null;
	private PlatformListener mPlatformListener;
	public static DynamicMenuBar menubar;
	private static BalanceButton balancebutton;
	private static float s_fScale;
	private View rootView = null;
	private static boolean m_bIsStartingVideo = false;
	private static Context s_context;
	private static LinearLayout s_balancelayout;

	private static Cocos2dxEditText edittext; // @ime

	private static Handler VideoViewHandler = new Handler();
	private static Handler RootViewHandler = new Handler();
	private static Runnable mHideBalance = new Runnable()
	{
		public void run()
		{
			s_balancelayout.setVisibility(View.INVISIBLE);
		};
	};
	private static Runnable mShowVideoView = new Runnable()
	{
		public void run()
		{
			LinearLayout pkLinearLayout = new LinearLayout(ms_pkDHLJ);
			pkLinearLayout.addView(m_pkView);
			pkLinearLayout.setOrientation(LinearLayout.HORIZONTAL);
			LinearLayout.LayoutParams pkParams = new LinearLayout.LayoutParams(
					ViewGroup.LayoutParams.FILL_PARENT,
					ViewGroup.LayoutParams.FILL_PARENT);
			pkParams.gravity = Gravity.CENTER;
			ms_pkDHLJ.setContentView(pkLinearLayout, pkParams);
			m_pkView.setLayoutParams(pkParams);
			// ms_pkDHLJ.rootView.setVisibility(View.INVISIBLE);
			// ms_pkDHLJ.balancebutton.setVisibility(View.INVISIBLE);
			// menubar.setVisibility(View.INVISIBLE);
			m_pkView.start();
			m_pkView.setVisibility(View.VISIBLE);
		};
	};

	private static Runnable mContinueRootView = new Runnable()
	{
		public void run()
		{
			// ms_pkDHLJ.setMain();
			ViewGroup.LayoutParams pkParams = new ViewGroup.LayoutParams(
					ViewGroup.LayoutParams.FILL_PARENT,
					ViewGroup.LayoutParams.FILL_PARENT);
			// ms_pkDHLJ.nativeInit(100, 200);
			ms_pkDHLJ.setContentView(menubar, pkParams);
			ms_pkDHLJ.rootView.setVisibility(View.VISIBLE);
			// ms_pkDHLJ.balancebutton.setVisibility(View.INVISIBLE);
			// menubar.setVisibility(View.INVISIBLE);
			// m_pkView.start();
			// m_pkView.setVisibility(View.INVISIBLE);
		};
	};

	public void continueRootView()
	{
		Log.i("DaHuaLongJiang", "continueRootView");
		VideoViewHandler.post(mContinueRootView);
		resumeBackgroundMusic();
	}

	private static Handler BalanceHandler = new Handler();
	private static Runnable mUpdateBalance = new Runnable()
	{
		public void run()
		{
			s_balancelayout.setVisibility(View.VISIBLE);
			balancebutton.update();
		};
	};

	private static class Callback implements
			RemoteNotification.OnSetRemoteNotificationsEnabledComplete,
			RemoteNotification.OnGetRemoteNotificationsEnabledComplete,
			RemoteNotification.OnSendComplete
	{
		@Override
		public void onSuccess(RemoteNotificationResponse arg0)
		{
			// TODO Auto-generated method stub
		}

		@Override
		public void onSuccess(boolean arg0)
		{
			// TODO Auto-generated method stub
		}

		@Override
		public void onError(Error arg0)
		{
			// TODO Auto-generated method stub
		}

		@Override
		public void onSuccess()
		{
			// TODO Auto-generated method stub
		}
	}

	protected void onCreate(Bundle savedInstanceState)
	{
		if (isSDCardCanUse())
		{
			ms_pkDHLJ = this;
			super.onCreate(savedInstanceState);
			Log.e(TAG, "onCreate called");

			Context context = getApplication().getApplicationContext();
			CookieSyncManager.createInstance(this);
			s_context = context;

			Mobage.registerMobageResource(this, "org.DeNA.DHLJ.R");
			final Callback callback = new Callback();
			RemoteNotification.setRemoteNotificationsEnabled(false, callback);
			SocialUtils.initializeMobage(this);
			mPlatformListener = SocialUtils.createPlatformListener(true);
			Mobage.addPlatformListener(mPlatformListener);

			// RemoteNotification.setListener(new RemoteNotificationListener()
			// {
			//
			// @Override
			// public void handleReceive(Context context, Intent intent)
			// {
			// // You can use static method which performing a notification
			// // in status bar.
			// C2DMBaseReceiver.displayStatusBarNotification(context,
			// intent);
			//
			// // If you want to handle message yourself, below lists one
			// // of keys:
			// // "NOTIFICATION_MESSAGE"
			// // You should analysis the json string by yourself, keys are
			// // "style", "message", "iconUrl", "extras", etc,
			// Bundle bundle = intent.getExtras();
			// String message = bundle.getString("NOTIFICATION_MESSAGE");
			// try
			// {
			// JSONObject obj = new JSONObject(message);
			// String style = obj.getString("style");
			// String iconUrl = obj.getString("iconUrl");
			// String msg = obj.getString("message");
			//
			// Map<String, String> extras = new HashMap<String, String>();
			// JSONObject e = new JSONObject(obj.getString("extras"));
			// Iterator<String> keys = e.keys();
			// while (keys.hasNext())
			// {
			// String key = keys.next();
			// String val = e.optString(key);
			// if (val != null)
			// {
			// extras.put(key, val);
			// }
			// }
			// } catch (JSONException ex)
			// {
			// ex.printStackTrace();
			// }
			// }
			// });

			nativeInit(480, 320);

			Mobage.checkLoginStatus();
			Mobage.onCreate();

			mDeviceID = Secure.getString(this.getContentResolver(),
					Secure.ANDROID_ID);
			PushService.actionStart(context);

			menubar = new DynamicMenuBar(this);
			menubar.setMenubarVisibility(View.VISIBLE);
			menubar.setMenuIconGravity(Gravity.TOP | Gravity.LEFT);

			Rect rect = new Rect(0, 0, 160, 90);
			balancebutton = com.mobage.android.social.common.Service
					.getBalanceButton(rect);

			// button1 = new Button(this);
			// button1.setText("aaaaaaaaa".toCharArray(), 1, 6);
			// FrameLayout.LayoutParams pkParamsButton = new
			// FrameLayout.LayoutParams(200,200);
			// pkParamsButton.topMargin = 10;
			// pkParamsButton.leftMargin = 10;
			// button1.setLayoutParams(pkParamsButton);
			//
			// button1.setOnClickListener(new OnClickListener() {
			// @Override
			// public void onClick(View view) {
			// FeedsView.openActivityFeeds();
			// // RemoteNotificationView.SendRemoteNotification("500002013");
			// // RemoteNotificationView.SendRemoteNotification("500001919");
			// // PeopleView.getFriendsWithGame();
			// // PeopleView.getFriends();
			// // PeopleView.getUsers();
			// // PeopleView.getCurrentUser();
			// // PeopleView.getUser();
			// }
			// });
		} else
		{
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("Title");
			alertDialog.setMessage("Message");

			// alertDialog.setIcon(R.drawable.dhlj_icon);
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
		Log.d(TAG, "DaHuaLongJiang::setMain()");

		// remove all views
		rootView = (View) getView();
		FrameLayout parent = (FrameLayout) rootView.getParent();
		if (parent != null)
		{
			parent.removeView(rootView);
		}
		menubar.removeAllViews();

		// add edit view
		addEditView();

		// add surface view
		m_pkView.setVisibility(View.INVISIBLE);
		// menubar.addView(m_pkView);
		menubar.addView(rootView);

		s_balancelayout = new LinearLayout(s_context);
		s_balancelayout.setOrientation(LinearLayout.VERTICAL);

		LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.FILL_PARENT);

		setScaleX();
		Float x = 200 * s_fScale;
		Float y = 56 * s_fScale;
		Float sizex = 80 * s_fScale;
		Float sizey = 36 * s_fScale;
		layoutParams.topMargin = y.intValue();
		layoutParams.leftMargin = x.intValue();
		layoutParams.width = sizex.intValue();
		layoutParams.height = sizey.intValue();

		s_balancelayout.addView(balancebutton, layoutParams);

		menubar.addView(s_balancelayout);
		s_balancelayout.setVisibility(View.INVISIBLE);

		// set content view
		ViewGroup.LayoutParams pkParams = new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.FILL_PARENT);
		this.setContentView(menubar, pkParams);

		// set menu bar visible
		menubar.setMenubarVisibility(View.VISIBLE);
	}

	// @ime
	public void addEditView()
	{
		if (edittext == null)
		{
			ViewGroup.LayoutParams edittext_layout_params = new ViewGroup.LayoutParams(
					ViewGroup.LayoutParams.FILL_PARENT,
					ViewGroup.LayoutParams.WRAP_CONTENT);

			edittext = new Cocos2dxEditText(this);
			edittext.setLayoutParams(edittext_layout_params);
		}

		if (edittext != null)
		{
			// add edit to layout
			menubar.addView(edittext);

			// set this edit to cocos2dx surface view
			Cocos2dxGLSurfaceView surfaceView = getView();
			surfaceView.setCocos2dxEditText(edittext);
			surfaceView.setDHLJ(this);

			// single line
			edittext.setSingleLine();
		}
	}

	// @ime
	private static boolean isFullScreenIME()
	{
		if (ms_pkDHLJ != null && ms_pkDHLJ.rootView != null)
		{
			final InputMethodManager imm = (InputMethodManager) ms_pkDHLJ.rootView
					.getContext()
					.getSystemService(Context.INPUT_METHOD_SERVICE);

			if (imm != null)
			{
				boolean bFull = imm.isFullscreenMode();
				Log.d("test", "@@ ime isFull: " + bFull);
				return bFull;
			}
		}
		return false;
	}

	// @ime
	public void notifyIMEOpenClose(boolean bImeOpen)
	{
		Log.d("test", "@@ DaHuaLongJiang.notifyIMEOpenClose(): " + bImeOpen);

		// refreshLayout( bOpen );
		if (!isFullScreenIME())
		{
			if (bImeOpen)
			{
				// bring editView to top
				menubar.bringChildToFront(edittext);
			} else
			{
				// bring surface view to top
				menubar.bringChildToFront(getView());
			}
		}
	}

	public void LoginComplete(int userid)
	{
		onLoginComplete(userid, mDeviceID);
	}

	public void LoginError(String error)
	{
		onLoginError(error);
	}

	private void setScaleX()
	{
		Log.v(TAG, "begin setScaleX");

		DisplayMetrics dm = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(dm);

		// dm.heightPixels;
		// dm.widthPixels;

		s_fScale = 2.0f * dm.widthPixels / 960.0f;
	}

	private static void showBalanceButton()
	{
		Log.v(TAG, "begin showBalanceButton");

		BalanceHandler.post(mUpdateBalance);
	}

	private static void hideBalanceButton()
	{
		Log.v(TAG, "begin showBalanceButton");
		BalanceHandler.post(mHideBalance);
	}

	public static String getTextFromStringXML(int nTextID)
	{
		String strRet = "";

		strRet = ms_pkDHLJ.getResources().getString(nTextID);

		return strRet;
	}

	public static String getStringFromJasonFile(String strBuffer,
			String strTextName)
	{
		String strRet = "";
		StringBuffer strReadBuffer = new StringBuffer();
		String strLine = null;

		strReadBuffer.append(strBuffer);
//			BufferedReader kReader = new BufferedReader(strBuffer);
//			while ((strLine = kReader.readLine()) != null)
//			{
//				
//			}

		try
		{
			JSONObject kJsonObject;
			kJsonObject = new JSONObject(strReadBuffer.toString());
			strRet = kJsonObject.getString(strTextName);
			// JSONArray provinces = jsonObject.getJSONArray("provinces");
			// String name = null;
			// StringBuffer jsonFileInfo = new StringBuffer();
			// JSONArray citys = null;
			// for (int i = 0; i < provinces.length(); i++)
			// {
			// name = provinces.getJSONObject(i).getString("name");
			// jsonFileInfo.append("/nname:" + name + "/n" + "citys:");
			// citys = provinces.getJSONObject(i).getJSONArray("citys");
			// for (int j = 0; j < citys.length(); j++)
			// {
			// jsonFileInfo.append(citys.getString(j) + "/t");
			// }
			// }
			//
			// System.out.println(jsonFileInfo);
		} catch (ParseException e)
		{
			e.printStackTrace();
		}
		catch (JSONException e1)
		{
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		return strRet;
	}

	public static void ShowBankUi()
	{
		Log.v(TAG, "begin ShowBankUi");
		com.mobage.android.social.common.Service
				.showBankUi(new com.mobage.android.social.common.Service.OnDialogComplete()
				{
					@Override
					public void onDismiss()
					{
					}
				});
	}

	private static void OpenUserProfile()
	{
		Log.v(TAG, "begin testGetUserProfile");
		String userId = SocialUtils.getmUserId();// Platform.getInstance().getUserId();
		com.mobage.android.social.common.Service.openUserProfile(userId,
				new com.mobage.android.social.common.Service.OnDialogComplete()
				{
					@Override
					public void onDismiss()
					{
						SocialUtils.showConfirmDialog("openUserProfile status",
								"Dismiss", "OK");
					}
				});
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
		if (true)
		{
			return 0;
		}

		pauseAllBackgroundMusic();
		// ms_pkDHLJ.setContentView(m_pkView,pkLayoutParams);
		m_bIsStartingVideo = true;
		VideoViewHandler.post(mShowVideoView);
		// m_pkView.setVisibility(View.VISIBLE);
		Log.i("DaHuaLongJiang", "Entry java playVideo");

		if (strFile.length() == 0)
		{
			Log.e("DaHuaLongJiang", "strFile length == 0");
			return -1;
		}

		if (null == ms_pkDHLJ)
		{
			Log.e("DaHuaLongJiang", "ms_pkDHLJ == 0");
			return -1;
		}

		// ms_pkDHLJ.m_pkView.start();
		// ms_pkDHLJ.setContentView(ms_pkDHLJ.m_pkView, pkLayoutParams);
		Log.i("DaHuaLongJiang", "Leave java playVideo");
		return 0;
	}

	public static int stopVideo(final String strFile)
	{
		return 0;
	}

	public static int openUrl(final String strFile)
	{
		if (ms_pkDHLJ == null)
		{
			return -1;
		}

		Intent it = new Intent(Intent.ACTION_VIEW, Uri.parse(strFile));
		it.setClassName("com.android.browser",
				"com.android.browser.BrowserActivity");
		ms_pkDHLJ.startActivity(it);

		return 0;
	}

	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)
		{
			event.startTracking();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	public boolean onTouchEvent(MotionEvent event)
	{
		if (m_bIsStartingVideo)
		{
			m_pkView.stopPlayback();
			continueRootView();
		}

		return true;
	}

	private void getAndroidVer()
	{
		// Log.d( "getAndroidVer" , "@@ ver SDK: " +
		// android.os.Build.VERSION.SDK );
		// Log.d( "getAndroidVer" , "@@ ver release: " +
		// android.os.Build.VERSION.RELEASE );
		// Log.d( "getAndroidVer" , "@@ ver codename: " +
		// android.os.Build.VERSION.CODENAME );
		// Log.d( "getAndroidVer" , "@@ ver incremental: " +
		// android.os.Build.VERSION.INCREMENTAL );
		// Log.d( "getAndroidVer" , "@@ ver SDK: " +
		// android.os.Build.VERSION.SDK );
		// isVerOlder(0);
	}

	public static int isWifiConnected()
	{
		WifiManager wifiManger = (WifiManager) s_context
				.getSystemService(Service.WIFI_SERVICE);
		if (WifiManager.WIFI_STATE_ENABLED == wifiManger.getWifiState())
			return 1;
		return 0;
	}

	// 是否古老系统
	public static int isVerOlder(int n)
	{
		String osVer = android.os.Build.VERSION.RELEASE;
		final String[] ver = osVer.split("\\.");

		// for (String v : ver)
		// {
		// Log.d( "ver", "@@ v: " + v );
		// }

		return (ver[0].compareTo("2") == 0) ? 1 : 0;
	}

	static
	{
		System.loadLibrary("mobage");
		System.loadLibrary("cocos2d");
		System.loadLibrary("GameLauncher");
	}

	private static native void pauseAllBackgroundMusic();

	private static native void resumeBackgroundMusic();

	private static native void nativeInit(int w, int h);

	private static native void onLoginComplete(int userid, String DeviceToken);

	private static native void onLoginError(String error);
}
