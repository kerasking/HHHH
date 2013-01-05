package org.DeNA.DHLJ;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Vibrator;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.Toast;
 
public class BootReceiver extends BroadcastReceiver {
 
	@Override
	public void onReceive(Context context, Intent intent) {
		PushService.actionStart(context);	
//		Toast.makeText(context, "Don't panik but your time is up!!!!.",
//				Toast.LENGTH_LONG).show();
//		// Vibrate the mobile phone
//		Vibrator vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
//		vibrator.vibrate(5000);
	}
}