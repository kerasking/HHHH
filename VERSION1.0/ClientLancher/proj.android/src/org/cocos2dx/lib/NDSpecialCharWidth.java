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
		add('A', 0.90f); 	add('a', 0.75f);
		add('B', 0.90f); 	add('b', 0.70f);
		add('C', 0.90f); 	add('c', 0.70f);
		add('D', 0.90f); 	add('d', 0.70f);
		add('E', 0.90f); 	add('e', 0.70f);
		add('F', 0.90f); 	add('f', 0.65f);
		add('G', 0.90f); 	add('g', 0.70f);
		
		add('H', 0.90f); 	add('h', 0.70f);
		add('I', 0.70f); 	add('i', 0.50f);
		add('J', 0.90f); 	add('j', 0.60f);
		add('K', 0.90f); 	add('k', 0.70f);
		add('L', 0.90f); 	add('l', 0.70f);
		add('M', 1.00f); 	add('m', 0.90f);
		add('N', 0.90f); 	add('n', 0.70f);
		
		add('O', 0.90f); 	add('o', 0.80f);
		add('P', 0.90f); 	add('p', 0.7f);
		add('Q', 0.90f); 	add('q', 0.80f);
		add('R', 0.90f); 	add('r', 0.80f);
		add('S', 0.90f); 	add('s', 0.70f);
		add('T', 0.90f); 	add('t', 0.70f);
		
		add('U', 0.90f); 	add('u', 0.70f);
		add('V', 0.90f); 	add('v', 0.70f);
		add('W', 1.00f); 	add('w', 0.85f);
		add('X', 0.90f); 	add('x', 0.70f);
		add('Y', 0.90f); 	add('y', 0.70f);
		add('Z', 0.90f); 	add('z', 0.70f);
		
		add('0', 0.65f);
		add('1', 0.5f);
		add('2', 0.65f);
		add('3', 0.65f);
		add('4', 0.65f);
		add('5', 0.65f);
		add('6', 0.65f);
		add('7', 0.65f);
		add('8', 0.65f);
		add('9', 0.65f);
		
		add('(', 0.55f);	add(')', 0.55f);
		add('[', 0.55f);	add(']', 0.55f);
		add('<', 0.70f);	add('>', 0.75f);
		add('+', 0.70f);	add('-', 0.70f);
		add('.', 0.40f);	add(',', 0.40f);
		add('=', 0.70f);	add(':', 0.40f);
		add('/', 0.70f);	add('\\', 0.70f);
		add('%', 1.00f);	add('\'', 0.60f);

		add(' ', 0.50f);
	}
	
	public static int fixCharWidth( final char c, final int width )
	{
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
