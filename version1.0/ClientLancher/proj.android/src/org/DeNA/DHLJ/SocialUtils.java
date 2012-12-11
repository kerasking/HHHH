package org.DeNA.DHLJ;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URLDecoder;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;

import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.conn.ssl.X509HostnameVerifier;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.SingleClientConnManager;
import org.apache.http.util.EntityUtils;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.xmlpull.v1.XmlPullParserException;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.mobage.android.Error;
import com.mobage.android.Mobage;
import com.mobage.android.Mobage.PlatformListener;
import com.mobage.android.Mobage.ServerMode;

public class SocialUtils {
	
	private static final String TAG = "SocialUtils";
	
	private static String mUserId;
	private static PlatformListener mPlatformListener = null;
	private static Cocos2dxActivity mActivity;
	
	public static void initializeMobage(Cocos2dxActivity activity) {
		Log.d(TAG, "SocialUtils initializeMobage");
		mActivity = activity;
		initCN(activity);
	}

	private static void initCN(Cocos2dxActivity activity) {
		try {
			ServerMode serverMode = Mobage.getPlatformEnvironment(mActivity,
					R.xml.init);
			if (serverMode == ServerMode.SANDBOX) {
				Mobage.initialize(Mobage.Region.CN, Mobage.ServerMode.SANDBOX,
						"sdk_app_id:13000314",
						"0be0f1827fa82036ca1a569e341d015f", "13000314",
						activity);
			} else if (serverMode == ServerMode.PRODUCTION) {
				Mobage.initialize(Mobage.Region.CN,
						Mobage.ServerMode.PRODUCTION, "sdk_app_id:13000314",
						"4e7aa408fbe3194bba7472fa859dc92d", "13000314",
						activity);
			}
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (XmlPullParserException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static void showConfirmDialog(String title, String content,
			String buttonText) {
		Activity activity = mActivity;
		if (!activity.isFinishing()) {
			new AlertDialog.Builder(activity).setTitle(title)
					.setMessage(content)
					.setPositiveButton(buttonText, new OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog,
								int whichButton) {

						}
					}).show();
		}
	}
	
	public static PlatformListener createPlatformListener(boolean isShowSplash) {

		if (mPlatformListener != null) {
			return mPlatformListener;
		}

		mPlatformListener = new PlatformListener() {

			boolean mSplashCompleted = false;
			boolean mLoginCompleted = false;

			boolean checkComplete() {
				return mSplashCompleted && mLoginCompleted;
			}

			void onCompleted() {
				mSplashCompleted = false;
				mLoginCompleted = false;

				Mobage.hideSplashScreen();
			}

			public void onLoginComplete(String userId) {
				Log.i(TAG, "Login completed:" + userId);
				mLoginCompleted = true;
				mUserId = userId;

				Mobage.registerTick();

				if (checkComplete()) {
					onCompleted();
				}
				getmActivity().setMain();
				getmActivity().LoginComplete(Integer.parseInt(mUserId));
			}

			public void onLoginRequired() {
				Log.i(TAG, "Login required.");

			}

			public void onLoginError(Error error) {
				Log.e(TAG, "Login failed.  " + error.toString());
				Mobage.checkLoginStatus();
				getmActivity().LoginError(error.toString());
			}

			@Override
			public void onSplashComplete() {
				// TODO Auto-generated method stub
				Log.e(TAG, "splash complete!.");
				mSplashCompleted = true;

				if (checkComplete()) {
					onCompleted();
				}
			}

			@Override
			public void onLoginCancel() {
				// TODO Auto-generated method stub

			}

			@Override
			public void onSwitchAccount() {
				// TODO Auto-generated method stub
				mActivity.finish();
			}

			public void onDashboardClose() {
				// TODO Auto-generated method stub
//				Toast.makeText(mActivity, "宸查��鍑虹ぞ鍖�", Toast.LENGTH_LONG).show();
			}
		};

		return (mPlatformListener);

	}
	
	public static String getHttpResponseString(String url,
			String consumer_key, String consumer_secret) {

		OAuthSupport support = new OAuthSupport(consumer_key, consumer_secret);
		String header = support.getOAuthHeader("POST", url, null);
		Log.v(TAG, url);
		Log.v(TAG, header);
		HttpClient httpclient = initHttpClient2();
		HttpPost httppost = new HttpPost(url);

		httppost.setHeader("Authorization", header);
		httppost.setHeader("Content-Type", "application/json; charset=utf8");

		byte[] result = null;
		try {
			// Execute HTTP Post Request
			HttpResponse response = httpclient.execute(httppost);
			StatusLine statusLine = response.getStatusLine();
			if (statusLine.getStatusCode() != HttpURLConnection.HTTP_OK) {
				result = EntityUtils.toByteArray(response.getEntity());
				Log.e(TAG, "error response= " + new String(result, "UTF-8"));

				Log.e(TAG, "statusCode is" + statusLine.getStatusCode()
						+ ", json failed");
			} else {
				result = EntityUtils.toByteArray(response.getEntity());
			}
			return new String(result, "UTF-8");
		} catch (Throwable e) {

		}
		return null;
	}
	
	private static HttpClient initHttpClient2() {
		HostnameVerifier hostnameVerifier = org.apache.http.conn.ssl.SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER;
		SchemeRegistry registry = new SchemeRegistry();
		SSLSocketFactory socketFactory = SSLSocketFactory.getSocketFactory();
		socketFactory
				.setHostnameVerifier((X509HostnameVerifier) hostnameVerifier);
		registry.register(new Scheme("https", socketFactory, 443));
		registry.register(new Scheme("http", PlainSocketFactory
				.getSocketFactory(), 80));

		DefaultHttpClient client = new DefaultHttpClient();
		SingleClientConnManager mgr = new SingleClientConnManager(
				client.getParams(), registry);
		DefaultHttpClient httpClient = new DefaultHttpClient(mgr,
				client.getParams());
		HttpsURLConnection.setDefaultHostnameVerifier(hostnameVerifier);
		return httpClient;
	}
	
	public static Bundle decodeUrl(String s) {
		Bundle params = new Bundle();
		if (s != null) {
			String array[] = s.split("&");
			for (String parameter : array) {
				String v[] = parameter.split("=");
				if (v.length == 2) {
					params.putString(URLDecoder.decode(v[0]),
							URLDecoder.decode(v[1]));
				} else if (v.length == 1) {
					params.putString(URLDecoder.decode(v[0]), "");
				}
			}
		}
		return params;
	}

	public static DaHuaLongJiang getmActivity() {
		return (DaHuaLongJiang) mActivity;
	}

	public static String getmUserId() {
		return mUserId;
	}
}
