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

public class FeedsView extends LinearLayout{
	protected static final String TAG = "FeedsView";

	public FeedsView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	

	@Override
	protected void onFinishInflate() {
	}
	public String changeCharset(String str, String newCharset)
    {
		  try {
				if (str != null) {
					//用默认字符编码解码字符串〄1�7
					byte[] bs = str.getBytes();
					//用新的字符编码生成字符串
					return new String(bs, newCharset);
				}
		  } catch (UnsupportedEncodingException e) {
              	Log.e(TAG, "Failed to open AlertDialog", e);
		  }
		return str;
    }

	public static void openActivityFeeds() {
		int count = 3;
		String str[] = {"我在玩《大話龍將》，很好玩的遊戲哦～","快來體驗《大話龍將》，三國巨作，高畫質～","《大話龍將》高清Q版RPG，與三國武將們並肩作戰，體驗三國豪情～"};
		int r = new Random().nextInt(count);
		Feed feed = new Feed("大話龍將" , str[r] , "http://54.248.82.174/ft_png/dhlj_icon.png" , "");
		com.mobage.android.social.cn.Feeds.openActivityFeeds(feed);
	}
	
	public static void openActivityFeedsWithoutUi() {
		Feed feed = new Feed("test" , "test" , "" , "");
		final ProgressDialog dialog = ProgressDialog.show(SocialUtils.getmActivity(), "", 
                "feeding...", true);
		dialog.show();
		com.mobage.android.social.cn.Feeds.openActivityFeedsWithoutUi(feed, new OnActivityFeedsComplete(){
			@Override
			public void onSuccess() {
				dialog.dismiss();
				SocialUtils.showConfirmDialog("分享成功", "分享成功", "OK");
			}

			@Override
			public void onError(Error error) {
				// TODO Auto-generated method stub
				dialog.dismiss();
				SocialUtils.showConfirmDialog("分享失敗","分享失敗" + error.getDescription(), "OK");
			}
		});
	}

}
