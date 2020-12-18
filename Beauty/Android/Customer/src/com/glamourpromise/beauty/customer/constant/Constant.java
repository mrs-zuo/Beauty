package com.glamourpromise.beauty.customer.constant;

public class Constant {
	public static final String OUT_SERVER_URL="Beauty.Glamise.com";//外网地址
	public static final String OUT_DEMO_SERVER_URL="Demo.Beauty.Glamise.com";//外网demo地址
	public static final String OUT_Test_SERVER_URL="Test.Beauty.Glamise.com";//外网demo地址
	public static final int OUT_PORT = 443;//外网端口 
	
	public static boolean formalFlag = true;//true:正式用户；false:测试用户 
	public static final boolean outFlag = true;//是否外网标记；false:内网；true:外网  
	
	public static final String NET_ERR_PROMPT="您的网络貌似不给力，请检查网络设置";//外网demo地址
	
	//返回代码 
	public static final int GET_WEB_DATA_TRUE = 1;
	public static final int GET_WEB_DATA_FALSE = 0;
	public static final int GET_WEB_DATA_EXCEPTION = -1;
	public static final int GET_DATA_NULL = -2;
	public static final int PARSING_ERROR = -2;
	
	public static  final int CROP_PICTURE=600;
	public static  final int RESIZEBITMAPMAXWIDTH=500; 
	public static  final int RESIZEBITMAPMAXHEIGHT=500;
	public static  final String RMB="￥";
	
	public static final String APK_FILE_NAME = "com.glamourpromise.beauty.customer";
	public static final String IMAGE_CACHE_DIR_NAME = "images";
	//临时保存图片的路径
	public static final String IMAGE_FILE_LOCATION="file:///sdcard/temp.jpg";
	public static  final int  CROPIMAGEWIDTH=800;
	public static  final int  CROPIMAGEHEIGHT=800;
}
