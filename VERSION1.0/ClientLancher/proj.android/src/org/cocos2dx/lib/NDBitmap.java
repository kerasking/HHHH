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
	public static boolean verbose = false;

	//开关：是否启用NDBitmap的Java端开关
	public static boolean isEnabled()
	{
		return true;
		/*
		if (true) return true;//@del
		if (s_enableNDBitmapCache == -1)
		{
			s_enableNDBitmapCache = 0;
			if (enableNDBitmap)
			{
				s_enableNDBitmapCache = isVerOlder() ? 1 : 0;
			}
		}
		return s_enableNDBitmapCache == 1;
		*/
	}
	
	/**
	 * isVerOlder: is this a older android os, such as 2.x
	 * @param n
	 * @return
	 */
	public static boolean isVerOlder()
	{
		String osVer = android.os.Build.VERSION.RELEASE;
		final String[] ver = osVer.split("\\.");
		return (ver[0].compareTo("2") == 0) ? true : false;
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
			log("before create bitmap: w=" + NDTextProxy.bitmapWidth + ", h=" + NDTextProxy.bitmapHeight);
			final Bitmap bitmap = Bitmap.createBitmap( NDTextProxy.bitmapWidth, NDTextProxy.bitmapHeight, Bitmap.Config.ARGB_8888 );
			log("after create bitmap: w=" + NDTextProxy.bitmapWidth + ", h=" + NDTextProxy.bitmapHeight);
			
			// left align for each char
			//paint.setTextAlign(Align.LEFT);
			paint.setTextAlign(Align.CENTER);
			
			// get canvas for bitmap
			final Canvas canvas = new Canvas(bitmap);
			
			// draw each char
			for (final CharProperty objChar : NDTextProxy.charList) 
			{
				if (objChar.bLineFeed) continue;
				
				//paint.setColor( objChar.color );
				if (objChar.x >= 0 && objChar.x + objChar.w <= NDTextProxy.bitmapWidth &&
					objChar.y >= 0 && objChar.y <= NDTextProxy.bitmapHeight)
				{
					String str = String.valueOf( objChar.c );
					
					//canvas.drawText( str, objChar.x, objChar.y, paint );
					canvas.drawText( str, objChar.x + objChar.w*0.5f, objChar.y, paint );
					
					log("canvas.drawText(), str="+str+",x="+objChar.x+",y="+objChar.y);
				}
			}			
	
			log("before initNativeObject(), strText="+strText );
			Cocos2dxBitmap.initNativeObject(bitmap);
			log("after initNativeObject(), strText="+strText );
		}
	}
	
	/**
	 * getStringSize: support rich format
	 * @param strText
	 * @param fontName
	 * @param fontSize
	 * @param alignment
	 * @return
	 */
	public static String getStringSize( final String strText, final String fontName,
											final int fontSize, final int alignment)
	{
		final Paint paint = Cocos2dxBitmap.newPaint( fontName, fontSize, alignment & 0x0F );
	
		if (NDTextProxy.parse( paint, strText, fontName, fontSize, alignment, 0, 0 ))
		{
			int w = NDTextProxy.bitmapWidth;
			int h = NDTextProxy.bitmapHeight;
			return String.valueOf(w)+" " +String.valueOf(h);
		}
		
		return "";
	}
	
	public static void test()
	{
		if (false)
		{
			NDTextProxy.testFormatText( "你好jack" );
			NDTextProxy.testFormatText( "<cff00ee你好<cff00ccjack" );
			NDTextProxy.testFormatText( "<cff00ee你好/e<cff00ccjack/e" );
		}
		if (false)
		{
			//String strText = "<C#112233>hello</C><C#aabbcc>你好吗</C>";
			String strText = "坐騎加成的屬性在競技場、軍團戰等PVP活動中有效<cff0000(加成的屬性受寶石加成)/e。";
			//String strText = "hello你好吗";
			NDBitmap.createTextBitmap(strText, "", 0, 0, 200, 100);
		}
	}
	
	public static void log( final String str )
	{
		if (verbose)
			Log.d("ndbmp", str);
	}
}
