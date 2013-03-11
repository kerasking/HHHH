/****************************************************************************
* NDSpecialCharWidth.java
****************************************************************************/
package org.cocos2dx.lib;

import java.util.*;

public class NDSpecialCharWidth 
{
	private static boolean initFlag = false;
	private static HashMap mapChar = new HashMap();
	
	private static class CharInfo
	{
		char c;
		float rate;
	}
	
	private static void add( final char c, final float rate )
	{
		String key = ""+c;
		String value = ""+rate;
		mapChar.put( key, value );
	}
	
	private static void checkInit()
	{
		if (!initFlag)
		{
			doInit();
			initFlag = true;
		}
	}
	
	/**
	 * isSpecialChar: 
	 * @param c
	 * @return
	 */
	public static boolean isSpecialChar( final char c )
	{
		checkInit();
		return mapChar.containsKey( ""+c);
	}

	private static void doInit()
	{
		add('A', 0.80f); 	add('a', 0.65f);
		add('B', 0.80f); 	add('b', 0.60f);
		add('C', 0.80f); 	add('c', 0.60f);
		add('D', 0.80f); 	add('d', 0.60f);
		add('E', 0.80f); 	add('e', 0.60f);
		add('F', 0.80f); 	add('f', 0.55f);
		add('G', 0.80f); 	add('g', 0.60f);
		
		add('H', 0.80f); 	add('h', 0.60f);
		add('I', 0.40f); 	add('i', 0.40f);
		add('J', 0.60f); 	add('j', 0.50f);
		add('K', 0.80f); 	add('k', 0.60f);
		add('L', 0.80f); 	add('l', 0.40f);
		add('M', 0.90f); 	add('m', 0.80f);
		add('N', 0.80f); 	add('n', 0.60f);
		
		add('O', 0.80f); 	add('o', 0.65f);
		add('P', 0.75f); 	add('p', 0.65f);
		add('Q', 0.80f); 	add('q', 0.70f);
		add('R', 0.80f); 	add('r', 0.65f);
		add('S', 0.80f); 	add('s', 0.60f);
		add('T', 0.80f); 	add('t', 0.60f);
		
		add('U', 0.80f); 	add('u', 0.60f);
		add('V', 0.80f); 	add('v', 0.60f);
		add('W', 0.90f); 	add('w', 0.75f);
		add('X', 0.80f); 	add('x', 0.60f);
		add('Y', 0.80f); 	add('y', 0.60f);
		add('Z', 0.80f); 	add('z', 0.60f);
		
		add('0', 0.60f);
		add('1', 0.45f);
		add('2', 0.60f);
		add('3', 0.60f);
		add('4', 0.60f);
		add('5', 0.60f);
		add('6', 0.60f);
		add('7', 0.60f);
		add('8', 0.60f);
		add('9', 0.60f);
		
		add('(', 0.50f);	add(')', 0.50f);
		add('[', 0.50f);	add(']', 0.50f);
		add('<', 0.65f);	add('>', 0.70f);
		add('+', 0.65f);	add('-', 0.65f);
		add('.', 0.35f);	add(',', 0.35f);
		add('=', 0.65f);	add(':', 0.35f);
		add('/', 0.65f);	add('\\', 0.65f);
		add('%', 0.95f);	add('\'', 0.55f);

		add(' ', 0.50f);
	}
	
	public static int fixCharWidth( final char c, final int width, final String fontName )
	{
		if (fontName.indexOf("LiSu") == -1)
		{
			return width;
		}

		checkInit();
		
		String key = ""+c;
		String value = (String) mapChar.get( key );
		if (value.length() > 0)
		{
			float rate = Float.valueOf(value);
			return Math.max(1, (int)(width * rate));
		}
		return width;
	}
}
