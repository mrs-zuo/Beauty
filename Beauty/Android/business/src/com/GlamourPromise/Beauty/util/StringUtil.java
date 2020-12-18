package com.GlamourPromise.Beauty.util;

public class StringUtil {
	/*
	 * 判断两个字符串是不是同一字符串
	 * */
	public static  int isTheSameString(String strOld, String strNew) {
		if (strOld.equals(strNew)) {
			return 0;
		} else
			return 1;
	}
	public static  String splitsNum(String tempStr, int num){ 
	    return  tempStr.substring(tempStr.length()- num);
	}
	public static String  replaceCustomerLoginMobile(String loginMobile){
		String loginMobileReplace="";
		if(loginMobile!=null && !("").equals(loginMobile) && loginMobile.length()>=5){
			String preString=loginMobile.substring(0,loginMobile.length()-4);
			loginMobileReplace=loginMobile.replace(preString,"*******");
		}
		return loginMobileReplace;
	}
}
