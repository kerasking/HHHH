package org.DeNA.DHLJ;

import android.app.ProgressDialog;
import android.content.Context;
import android.util.AttributeSet;
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

	public static void openActivityFeeds() {
		Feed feed = new Feed("大话龙将" , "我在玩大话龙将，很好玩的游戏哦～" , "" , "");
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
				SocialUtils.showConfirmDialog("分享失败","分享失败" + error.getDescription(), "OK");
			}
		});
	}

}
