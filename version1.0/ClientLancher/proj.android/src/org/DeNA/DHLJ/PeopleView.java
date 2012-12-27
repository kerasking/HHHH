package org.DeNA.DHLJ;

import java.util.ArrayList;
import java.util.Random;

import com.mobage.android.Error;
import com.mobage.android.Platform;
import org.DeNA.DHLJ.R;
import org.DeNA.DHLJ.SocialUtils;
import com.mobage.android.social.PagingOption;
import com.mobage.android.social.PagingResult;
import com.mobage.android.social.User;
import com.mobage.android.social.common.People;
import com.mobage.android.social.common.People.OnGetUserComplete;
import com.mobage.android.social.common.People.OnGetUsersComplete;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

public class PeopleView extends LinearLayout{
	protected static final String TAG = "People";

	public PeopleView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	protected void onFinishInflate() {
	}
	
	public static void getCurrentUser() {

		User.Field[] fields = { User.Field.ID, User.Field.NICKNAME,
				User.Field.HAS_APP };
		People.getCurrentUser(fields, new OnGetUserComplete() {

			@Override
			public void onSuccess(User user) {
				Log.v(TAG, "testGetCurentUser Success:"
						+ user.toJson().toString());

				SocialUtils.showConfirmDialog("getCurrentUser Status", "User Id:"
						+ user.getId().toString(), "OK");

			}

			@Override
			public void onError(Error error) {
				Log.v(TAG, "testGetCurrentUser Error:"
						+ error.toJson().toString());
			}
		});
	}

	public static void getUser() {
		Log.v(TAG, "begin testGetUser");
//		String userId = "500000011";
		User.Field[] fields = { User.Field.ID, User.Field.NICKNAME,
				User.Field.HAS_APP };
		People.getUser(Platform.getInstance().getUserId(), fields, new OnGetUserComplete() {

			@Override
			public void onSuccess(User user) {
				Log.v(TAG, "testGetUser Success");
				SocialUtils.showConfirmDialog("getUser status",
						"getUser nick name:" + user.getNickname(), "OK");
			}

			@Override
			public void onError(Error error) {
				Log.v(TAG, "testGetUser Error:" + error.getDescription());
				SocialUtils.showConfirmDialog("testGetUser status", "Failed", "OK");
			}

		});
	}

	public static void getUsers() {
		Log.v(TAG, "begin testGetUsers");
		ArrayList<String> userIds = new ArrayList<String>();
//		userIds.add(Platform.getInstance().getUserId());
		int userid = Integer.parseInt(Platform.getInstance().getUserId());
		Random random1 = new Random();
		for(int i = 0; i < 20; ++i)
		{
			int offset = Math.abs(random1.nextInt())%1000;
            if(i % 2 == 0)
            	offset = -offset;
			userIds.add(String.valueOf(userid+offset));
		}
		User.Field[] fields = { User.Field.ID, User.Field.NICKNAME,
				User.Field.HAS_APP };
		PagingOption options = new PagingOption();
		options.start = 0;
		options.count = 20;

		People.getUsers(userIds, fields, new OnGetUsersComplete() {

			@Override
			public void onSuccess(ArrayList<User> users, PagingResult result) {
				Log.v(TAG, "testGetUsers Success");
				String str = "count:" + result.total + ",";
				if (result.total > 0) {
					int count = users.size();
					for (int i = 0; i < count; i++) {
						str += users.get(i).getId() + ":" + users.get(i).getNickname() + ",";
					}
				}
				SocialUtils.showConfirmDialog("getUsers status", str, "OK");
			}

			@Override
			public void onError(Error error) {
				Log.v(TAG, "testGetUsers Error:" + error.getDescription());
				SocialUtils.showConfirmDialog("testGetUsers status", "Failed", "OK");

			}

		});
	}

	public static void getFriends() {
		Log.v(TAG, "begin testGetFriends");
//		String userId = "500000011";
		User.Field[] fields = { User.Field.ID, User.Field.NICKNAME,
				User.Field.HAS_APP };
		PagingOption options = new PagingOption();
		options.start = 0;
		options.count = 20;

		People.getFriends(Platform.getInstance().getUserId(), fields, options, new OnGetUsersComplete() {

			@Override
			public void onSuccess(ArrayList<User> users, PagingResult result) {
				Log.v(TAG, "testGetFriends Success");
				String str = "count:" + result.total + ",";
				if (result.total > 0) {
					int count = users.size();
					for (int i = 0; i < count; i++) {
						str += users.get(i).getNickname() + ",";
					}
					Log.d(TAG, str);
				}
				SocialUtils.showConfirmDialog("getFriends status", str, "OK");
			}

			@Override
			public void onError(Error error) {
				Log.v(TAG, "testGetFriends Error");
				SocialUtils.showConfirmDialog("getFriends status", "getFriends failed",
						"OK");
			}

		});
	}

	public static void getFriendsWithGame() {
		Log.v(TAG, "begin testGetFriendsWithGame");
//		String userId = "1000";
		User.Field[] fields = { User.Field.ID, User.Field.NICKNAME,
				User.Field.HAS_APP };
		PagingOption options = new PagingOption();
		options.start = 0;
		options.count = 20;

		People.getFriendsWithGame(Platform.getInstance().getUserId(), fields, options,
				new OnGetUsersComplete() {

					@Override
					public void onSuccess(ArrayList<User> users,
							PagingResult result) {
						Log.v(TAG, "testGetFriendsWithGame Success");
						String str = "count:" + result.total + ",";
						if (result.total > 0) {
							int count = users.size();
							for (int i = 0; i < count; i++) {
								str += users.get(i).getId() + ",";
							}
						}
						SocialUtils.showConfirmDialog("getFriendsWithGame status", str,
								"OK");
					}

					@Override
					public void onError(Error error) {
						Log.v(TAG, "testGetFriendsWithGame Error");
						SocialUtils.showConfirmDialog("getFriendsWithGame status",
								"getFriendsWithGame failed", "OK");
					}

				});
	}
}
