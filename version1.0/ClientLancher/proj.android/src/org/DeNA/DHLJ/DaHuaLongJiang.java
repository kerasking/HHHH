package org.DeNA.DHLJ;

import org.cocos2dx.lib.Cocos2dxActivity;
import android.app.AlertDialog;
import android.content.Context;
import android.os.Bundle;
import android.os.Environment;
import android.text.Layout;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.VideoView;

public class DaHuaLongJiang extends Cocos2dxActivity
{
	public static DaHuaLongJiang ms_pkDHLJ = null;
	public VideoView m_pkView;

	protected void onCreate(Bundle savedInstanceState)
	{
		if (isSDCardCanUse())
		{
			ms_pkDHLJ = this;
			nativeInit(480, 320);
			super.onCreate(savedInstanceState);

		} else
		{
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("Title");
			alertDialog.setMessage("Message");

			alertDialog.setIcon(R.drawable.dhlj_icon);
			alertDialog.show();
		}
	}

	public void changeViewToVideo()
	{
		setContentView(R.layout.activity_main);
		m_pkView = (VideoView) findViewById(R.id.videoPlay);
		setContentView(m_pkView);
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

		ms_pkDHLJ.changeViewToVideo();
		NDJavaVideoPlayer kVideoPlayer = new NDJavaVideoPlayer(
				ms_pkDHLJ.m_pkView);

		if (0 != kVideoPlayer.loadVideo(strFile))
		{
			return -1;
		}

		return 0;
	}

	static
	{
		System.loadLibrary("luaplus");
		System.loadLibrary("tinyxml");
		System.loadLibrary("cocos2d");
		System.loadLibrary("ClientEngine");
		System.loadLibrary("ClientLogic");
		System.loadLibrary("GameLauncher");
	}

	private static native void nativeInit(int w, int h);
}