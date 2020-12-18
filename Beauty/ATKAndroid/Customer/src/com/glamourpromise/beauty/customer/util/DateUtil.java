package com.glamourpromise.beauty.customer.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import android.util.Log;

public class DateUtil {
	//比较传进来的日期是否比今天的日期早  不包括今天
	public static  boolean  compareDate(String sourceDateStr){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-dd");
		Date  sourceDate=null;
		try {
			sourceDate=simpleDateFormate.parse(sourceDateStr);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Date nowDateFormate=null;
		try {
			nowDateFormate=simpleDateFormate.parse(new SimpleDateFormat("yyyy-MM-dd").format(nowDate));
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return sourceDate.before(nowDateFormate);
	}
	
	public static  boolean  compareDateEqual(String sourceDateStr){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-dd");
		Date  sourceDate=null;
		try {
			sourceDate=simpleDateFormate.parse(sourceDateStr);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Date nowDateFormate=null;
		try {
			nowDateFormate=simpleDateFormate.parse(new SimpleDateFormat("yyyy-MM-dd").format(nowDate));
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return sourceDate.equals(nowDateFormate);
	}
	
	public static String  getNowFormateDate(){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		return simpleDateFormate.format(nowDate);
	}
	//格式化成yyyy-MM-dd格式
	public static String getFormateDateByString(String source){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm");
		try {
			Date date=sdf.parse(source);
			return new SimpleDateFormat("yyyy-MM-dd").format(date);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
	}
	//格式化成 yyyy-MM-dd HH:mm格式
	public static String getFormateDateByString2(String source){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date date=sdf.parse(source);
			return new SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
	}
}
