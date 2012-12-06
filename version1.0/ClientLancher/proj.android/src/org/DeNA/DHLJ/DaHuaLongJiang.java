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
import com.mobage.android.social.common.RemoteNotification;
import com.mobage.android.social.common.RemoteNotification.RemoteNotificationListener;

import org.DeNA.DHLJ.SocialUtils;

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
import android.webkit.CookieSyncManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.Toast;

public class DaHuaLongJiang extends Cocos2dxActivity {
	private static final String TAG = "DaHuaLongJiang";
	private PlatformListener mPlatformListener;
	private DynamicMenuBar menubar;
	
	protected void onCreate(Bundle savedInstanceState) {
		if (isSDCardCanUse()) {
			super.onCreate(savedInstanceState);
			Log.e(TAG, "onCreate called");
			
			Mobage.registerMobageResource(this, "org.DeNA.DHLJ.R");
			SocialUtils.initializeMobage(this);
			mPlatformListener = SocialUtils.createPlatformListener(true);
			Mobage.addPlatformListener(mPlatformListener);

			RemoteNotification.setListener(new RemoteNotificationListener() {

				@Override
				public void handleReceive(Context context, Intent intent) {
					//You can use static method which performing a notification in status bar.
					C2DMBaseReceiver.displayStatusBarNotification(context, intent);
					
					
					//If you want to handle message yourself, below lists one of keys:
					//"NOTIFICATION_MESSAGE"
					//You should analysis the json string by yourself, keys are "style", "message", "iconUrl", "extras", etc,
					Bundle bundle = intent.getExtras();
					String message = bundle.getString("NOTIFICATION_MESSAGE");
					try {
						JSONObject obj = new JSONObject(message);
						String style = obj.getString("style");
				        String iconUrl = obj.getString("iconUrl");
				        String msg = obj.getString("message");

				        Map<String, String> extras = new HashMap<String, String>();
				        JSONObject e = new JSONObject(obj.getString("extras"));
				        Iterator<String> keys = e.keys();
				        while (keys.hasNext()) {
				            String key = keys.next();
				            String val = e.optString(key);
				            if (val != null) {
				                extras.put(key, val);
				            }
				        }
				    }catch (JSONException ex) {
				        ex.printStackTrace();
				    }        
				}
			});

			nativeInit(480, 320);
			
			Mobage.checkLoginStatus();
			Mobage.onCreate();

			menubar = new DynamicMenuBar(this);
			menubar.setMenubarVisibility(View.VISIBLE);
			menubar.setMenuIconGravity(Gravity.TOP|Gravity.LEFT);

			View rootView =(View)getView();
			
			menubar.addView(rootView);
		} else {
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("Title");
			alertDialog.setMessage("Message");

			alertDialog.setIcon(R.drawable.dhlj_icon);
			alertDialog.show();
		}
	}

	@Override
	public void onPause() {
		Log.e(TAG, "onPause called");
		super.onPause();
		Mobage.onPause();
	}

	@Override
	public void onResume() {
		Log.e(TAG, "onResume called");
		Mobage.setCurrentActivity(this);
		super.onResume();
		Mobage.onResume();
	}

	@Override
	public void onStop() {
		Log.e(TAG, "onStop called");
		super.onStop();
	}

	@Override
	public void onDestroy() {
		Log.e(TAG, "onDestroy called");
		super.onDestroy();
		Mobage.onStop();
	}

	@Override
	public void onRestart() {
		Log.e(TAG, "onRestart called");
		super.onRestart();
		Mobage.onRestart();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}
	
	public void setMain(){
		LayoutParams params = new LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.FILL_PARENT);
		this.setContentView(menubar,params);
	}

	public void LoginComplete(int userid){
		onLoginComplete(userid);
	}
	public void LoginError(String error){
		onLoginError(error);
	}
	public boolean isSDCardCanUse() {
		String strState = Environment.getExternalStorageState();

		if (Environment.MEDIA_MOUNTED.equals(strState)) {
			return true;
		}

		return false;
	}

	static {
		System.loadLibrary("mobage");
		System.loadLibrary("luaplus");
		System.loadLibrary("tinyxml");
		System.loadLibrary("cocos2d");
		System.loadLibrary("ClientEngine");
		System.loadLibrary("ClientLogic");
		System.loadLibrary("GameLauncher");
	}

	private static native void nativeInit(int w, int h);
	private static native void onLoginComplete(int userid);
	private static native void onLoginError(String error);
}
