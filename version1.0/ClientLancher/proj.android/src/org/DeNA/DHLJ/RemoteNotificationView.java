package org.DeNA.DHLJ;

import java.util.HashMap;

import com.mobage.android.Error;
import org.DeNA.DHLJ.SocialUtils;
import com.mobage.android.social.common.RemoteNotification;
import com.mobage.android.social.common.RemoteNotificationPayload;
import com.mobage.android.social.common.RemoteNotificationResponse;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

public class RemoteNotificationView extends LinearLayout{
	protected static final String TAG = "RemoteNotificationView";

	public RemoteNotificationView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	@Override
	protected void onFinishInflate() {
	}

	
	private static class Callback implements
	RemoteNotification.OnSetRemoteNotificationsEnabledComplete,
	RemoteNotification.OnGetRemoteNotificationsEnabledComplete,
	RemoteNotification.OnSendComplete {

		@Override
		public void onError(Error error) {
			SocialUtils.showConfirmDialog("RemoteNotification status","onError called: " + error.toString(),"OK");
		}

		@Override
		public void onSuccess() {
			// OnSetRemoteNotificationsEnabledComplete
			SocialUtils.showConfirmDialog("RemoteNotification status","onSuccess called","OK");
		}

		@Override
		public void onSuccess(boolean canBeNotified) {
			// OnGetRemoteNotificationsEnabledComplete
			SocialUtils.showConfirmDialog("RemoteNotification status","onSuccess called: canBeNotified is " + canBeNotified,"OK");
		}

		@Override
		public void onSuccess(RemoteNotificationResponse response) {
			// OnSendComplete
			SocialUtils.showConfirmDialog("RemoteNotification status","onSuccess called: " + response.toString(),"OK");
		}
	}

	private static Callback callback = new Callback();
	

	public static void DisableRemoteNotification() {
		RemoteNotification.setRemoteNotificationsEnabled(false, callback);
	}
	
	public static void SendRemoteNotification(String recipientId) {
		RemoteNotification.setRemoteNotificationsEnabled(true, callback);
		RemoteNotification.send(recipientId, new RemoteNotificationPayload() {{
			setMessage("您好!一起来玩大话龙将吧～");
			setStyle("largeIcon");
			setCollapseKey("abc");
			setExtras(new HashMap<String, String>(){{
				put("key1", "value1");
				put("key2", "value2");
			}});
			setIconUrl("https://developer.dena.jp/images/icon/28x28.png");
		}}, callback);
	}

}
