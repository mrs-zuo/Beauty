package com.glamourpromise.beauty.customer.util;

public class StringMultiplyUtil {
	
	StringMultiplyUtil(){
		
	}
	
	public static String FloatFormatStringMuiltiplyUtil(String valueA, String valueB){
		
		return String.valueOf(Float.parseFloat(valueA) * Float.parseFloat(valueB));
	}
	
	public static String FloatFormatStringMuiltiplyUtil(String valueA, float valueB){
		return String.valueOf(Float.parseFloat(valueA) * valueB);
	}
}
