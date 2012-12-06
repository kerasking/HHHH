package org.DeNA.DHLJ;

import java.io.IOException;
import java.util.Timer;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnBufferingUpdateListener;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;

public class NDJavaVideoPlayer implements OnBufferingUpdateListener,
		OnCompletionListener, OnPreparedListener, Callback
{
	private int videoWidth;
	private int videoHeight;
	public MediaPlayer mediaPlayer = null;
	private SurfaceView surfaceView = null;

	public NDJavaVideoPlayer(SurfaceView pkView)
	{
		surfaceView = pkView;
	}

	public int loadVideo(String strFile)
	{		
		try
		{
			mediaPlayer = new MediaPlayer();
			mediaPlayer.setOnBufferingUpdateListener(this);
			mediaPlayer.setOnPreparedListener(this);
			mediaPlayer.setOnCompletionListener(this);
			mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
		} catch (Exception e)
		{
			Log.e("mediaPlayer", "error", e);
		}

		try
		{
			mediaPlayer.reset();
			mediaPlayer.setDataSource("/sdcard/dhlj/SimplifiedChineseRes/res/Video/480_0.mp4");
			mediaPlayer.prepare();
			playVideo();
	        videoWidth = mediaPlayer.getVideoWidth();  
	        videoHeight = mediaPlayer.getVideoHeight(); 
		} catch (IllegalArgumentException e)
		{
			e.printStackTrace();
		} catch (IllegalStateException e)
		{
			e.printStackTrace();
		} catch (IOException e)
		{
			e.printStackTrace();
		}

		return 0;
	}

	public void playVideo()
	{
		mediaPlayer.start();
	//	mediaPlayer.setDisplay();
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height)
	{

	}

	@Override
	public void surfaceCreated(SurfaceHolder holder)
	{
		Log.e("mediaPlayer", "surface created");
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder)
	{

	}

	@Override
	public void onPrepared(MediaPlayer mp)
	{
		videoWidth = mediaPlayer.getVideoWidth();
		videoHeight = mediaPlayer.getVideoHeight();
		if (videoHeight != 0 && videoWidth != 0)
		{
			mp.start();
		}
		Log.e("mediaPlayer", "onPrepared");
	}

	@Override
	public void onCompletion(MediaPlayer mp)
	{

	}

	@Override
	public void onBufferingUpdate(MediaPlayer mp, int percent)
	{

	}

	private static native void playOverCallback(int w, int h);
}