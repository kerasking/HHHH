/****************************************************************************
 * NDBitmap.java
 * extension of Cocos2dxBitmap.java
 ****************************************************************************/
package org.cocos2dx.lib;

import org.cocos2dx.lib.NDHexUtil;
import org.cocos2dx.lib.NDTextProxy.CharProperty;

import android.graphics.*;
import android.graphics.Paint.*;
import android.util.*;

import java.util.*;

public class NDBitmap { 
	private static boolean enableNDBitmap = true; //to enable NDBitmap.
	private static int s_enableNDBitmapCache = -1; //-1,0,1

	// only for old version OS.
	public static boolean isEnabled()
	{
		if (true) return true;//@del
		if (s_enableNDBitmapCache == -1)
		{
			s_enableNDBitmapCache = 0;
			if (enableNDBitmap)
			{
				String osVer = android.os.Build.VERSION.RELEASE;
				final String[] ver = osVer.split("\\.");
				if (ver[0].compareTo("2") == 0)
					s_enableNDBitmapCache = 1;
			}
		}
		return s_enableNDBitmapCache == 1;
	}
	
	/**
	 * createTextBitmap: create bitmap for rich format label.
	 * @param strText
	 * @param fontName
	 * @param fontSize
	 * @param alignment
	 * @param width
	 * @param height
	 */
	public static void createTextBitmap(
		String strText, final String fontName, final int fontSize, 
		final int alignment, final int width, final int height) 
	{			
		// create a paint
		final Paint paint = Cocos2dxBitmap.newPaint( fontName, fontSize, alignment & 0x0F );
	
		// reset proxy
		if (NDTextProxy.parse( paint, strText, fontName, fontSize, alignment, width, height ))
		{
			// create bitmap with the calc size
			final Bitmap bitmap = Bitmap.createBitmap( NDTextProxy.bitmapWidth, NDTextProxy.bitmapHeight, Bitmap.Config.ARGB_8888 );
			
			// left align for each char
			paint.setTextAlign(Align.LEFT);
			
			// get canvas for bitmap
			final Canvas canvas = new Canvas(bitmap);
			
			// draw each char
			for (final CharProperty objChar : NDTextProxy.charList) 
			{
				if (objChar.bLineFeed) continue;
				
				//paint.setColor( objChar.color );
				
				String str = String.valueOf( objChar.c );
				canvas.drawText( str, objChar.x, objChar.y, paint );
			}			
	
			Cocos2dxBitmap.initNativeObject(bitmap);
		}
	}
	
	public static void test()
	{
		if (false)
		{
			//String strText = "<C#112233>hello</C><C#aabbcc>你好吗</C>";
			String strText = "坐騎加成的屬性在競技場、軍團戰等PVP活動中有效<cff0000(加成的屬性受寶石加成)/e。";
			//String strText = "hello你好吗";
			NDBitmap.createTextBitmap(strText, "", 0, 0, 200, 100);
		}
	}
}
