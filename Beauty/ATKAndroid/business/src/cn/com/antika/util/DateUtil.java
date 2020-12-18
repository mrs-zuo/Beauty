package cn.com.antika.util;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
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
	//将当前日期格式化 年月日时分秒毫秒
	public static String  getNowFormateDate(){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		return simpleDateFormate.format(nowDate);
	}
	public static String  getNowFormateDate2(){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-dd");
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
	//比较预约的时间是否在当前日期和时间之后
	public static  boolean  compareDateForAppointment(String sourceDateStr){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-ddHH:mm");
		SimpleDateFormat simpleDateFormate2=new SimpleDateFormat("yyyy/MM/ddHH:mm");
		Date  sourceDate=null;
		try {
			sourceDate=simpleDateFormate.parse(sourceDateStr);
		} catch (ParseException e) {
			try {
				sourceDate=simpleDateFormate2.parse(sourceDateStr);
			} catch (ParseException e1) {
			}
		}
		Date nowDateFormate=null;
		try {
			nowDateFormate=simpleDateFormate.parse(new SimpleDateFormat("yyyy-MM-dd HH:mm").format(nowDate));
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return sourceDate.after(nowDateFormate);
	}
	
	/**比较回访的时间是否在创建回访日期和时间之后*/
	public static  boolean  compareDateForAppointment(String sourceDateStr , String createTime){
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-ddHH:mm");
		SimpleDateFormat simpleDateFormate2=new SimpleDateFormat("yyyy/MM/ddHH:mm");
		SimpleDateFormat simpleDateFormateCreate=new SimpleDateFormat("yyyy-MM-ddHH:mm");
		Date  sourceDate=null;
		try {
			sourceDate=simpleDateFormate.parse(sourceDateStr);
		} catch (ParseException e) {
			try {
				sourceDate=simpleDateFormate2.parse(sourceDateStr);
			} catch (ParseException e1) {
			}
		}
		Date nowDateFormate=null;
		try {
			nowDateFormate=simpleDateFormateCreate.parse(createTime);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return sourceDate.after(nowDateFormate);
	}
	
	public static int  compareStartTimeAndEndTime(String startTime,String endTime){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm");
		try {
			long startDate=sdf.parse(startTime).getTime();
			long endDate=sdf.parse(endTime).getTime();
			return (int)((endDate-startDate)/1000);
		} catch (ParseException e) {
		}
		return 0;
	}
}
