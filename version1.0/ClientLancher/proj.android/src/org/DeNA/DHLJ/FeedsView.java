package org.DeNA.DHLJ;

import java.io.UnsupportedEncodingException;
import java.util.Random;

import android.app.ProgressDialog;
import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mobage.android.Error;
import com.mobage.android.social.Feed;
import com.mobage.android.social.cn.Feeds.OnActivityFeedsComplete;

import org.DeNA.DHLJ.SocialUtils;
import org.cocos2dx.lib.Cocos2dxActivity;

import tw.mobage.g23000052.R;

public class FeedsView extends Cocos2dxActivity{
	protected static final String TAG = "FeedsView";

	public String changeCharset(String str, String newCharset)
    {
		  try {
				if (str != null) {
					//ÓÃÄ¬ÈÏ×Ö·û±àÂë½âÂë×Ö·û´®?1?7
					byte[] bs = str.getBytes();
					//ÓÃÐÂµÄ×Ö·û±àÂëÉú³É×Ö·û´®
					return new String(bs, newCharset);
				}
		  } catch (UnsupportedEncodingException e) {
              	Log.e(TAG, "Failed to open AlertDialog", e);
		  }
		return str;
    }

	public static void openActivityFeeds() {
		FeedsView feed = new FeedsView();
		feed.openActivityFeeds_interal();
	}
	public void openActivityFeeds_interal() {
		int count = 3;
		final int resid[] = {R.string.dialog_share_text1, R.string.dialog_share_text2, R.string.dialog_share_text3 };
		final int r = new Random().nextInt(count);
		String title = getString(R.string.app_name);
		String content = getString(resid[r]);
		Feed feed = new Feed(title , content , "http://54.248.82.174/ft_png/dhlj_icon.png" , "");
		com.mobage.android.social.cn.Feeds.openActivityFeeds(feed);
	}
	
	public void openActivityFeedsWithoutUi() {
		Feed feed = new Feed("test" , "test" , "" , "");
		final ProgressDialog dialog = ProgressDialog.show(SocialUtils.getmActivity(), "", 
                "feeding...", true);
		dialog.show();
		com.mobage.android.social.cn.Feeds.openActivityFeedsWithoutUi(feed, new OnActivityFeedsComplete(){
			@Override
			public void onSuccess() {
				dialog.dismiss();
				SocialUtils.showConfirmDialog(getString(R.string.dialog_share_success), getString(R.string.dialog_share_success), "OK");
			}

			@Override
			public void onError(Error error) {
				// TODO Auto-generated method stub
				dialog.dismiss();
				SocialUtils.showConfirmDialog(getString(R.string.dialog_share_fail),getString(R.string.dialog_share_fail) + error.getDescription(), "OK");
			}
		});
	}

}
