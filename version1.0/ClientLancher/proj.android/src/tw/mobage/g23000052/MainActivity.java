package tw.mobage.g23000052;

import org.DeNA.DHLJ.DaHuaLongJiang;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class MainActivity extends Activity {	
	private static MainActivity mActivity;
	
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("init", "@@ MainActivity.onCreate()");
		super.onCreate(savedInstanceState);
		mActivity = this;
    
		Intent i = new Intent(this, DaHuaLongJiang.class);
		i.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		i.addFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
		i.addFlags(Intent.FLAG_ACTIVITY_PREVIOUS_IS_TOP);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(i);
	}
	
	public static void onExit()
	{
//		android.os.Process.killProcess(pid);
		if(mActivity != null) {
			mActivity.finish();
			mActivity = null;
			System.exit(0);
		}
	}

}
