package cn.com.antika.constant;
/*
 * 常量值
 * */
public class Constant {
	//public static final String OUT_SERVER_URL="Beauty.Glamise.com";//外网地址
	//public static final String OUT_DEMO_SERVER_URL="Demo.Beauty.Glamise.com";//外网demo地址
	//public static final String OUT_TEST_SERVER_URL="Test.Beauty.Glamise.com";//测试使用地址
    //public static final int INNER_PORT = 443;//内网端口
	//public static final int OUT_PORT = 443;//外网端口
	public static Integer formalFlag = 0;//0外网短域名  1： 外网长域名  2  测试地址
	public static final int GET_WEB_DATA_TRUE = 1;
	public static final int GET_WEB_DATA_FALSE = 0;
	public static final int GET_WEB_DATA_EXCEPTION = -1;
	public static final int GET_DATA_NULL = -2;
	public static final int PARSING_ERROR = -2;
	public static final String OUTNNER_SERVER_URL="";
	public static  final int DATE_DIALOG=0;
	public static  final int TIME_DIALOG=1;
	public static  final int SERVICE_ORDER=0;//服务
	public static  final int COMMODITY_ORDER=1;//
	public static  final int  CROPIMAGEWIDTH=800;
	public static  final int  CROPIMAGEHEIGHT=800;
	public static  final int RESIZEBITMAPMAXWIDTH=500;
	public static  final int RESIZEBITMAPMAXHEIGHT=500;
	public static  final int CROP_PICTURE=600;
	public static  final int SERVICE_TYPE=0;
	public static  final int COMMODITY_TYPE=1;
	public static  final int DEVICE_ANDROID=2;
	public static  final int USER_ROLE_BUSINESS=1;
	public static  final int USER_ROLE_CUSTOMER=0;
	public static  final int MY_REPORT=1;
	public static  final int EMPLOYEE_REPORT=2;
	public static  final int MY_BRANCH_REPORT=3;
	public static  final int ALL_BRANCH_REPORT=4;
	public static  final int COMPANY_REPORT=5;
	public static  final int GROUP_REPORT=6;
	public static  final String RMB="￥";
	public static final String SERVER_URL="http://beauty.glamise.com/";
	//成功对话框消失的时间  2秒
	public static final int   DIALOG_AUTO_DISMISS_TIME=2000;
	//日期框的类型  默认类型
	public static final int  DATE_DIALOG_SHOW_TYPE_DEFAULT=0;
	//服务过期时间 带有设置无有效期的日期选择框
	public static final int  DATE_DIALOG_SHOW_TYPE_EXPIRATION=1;
	//带有清楚功能的日期选择框
	public static final int  DATE_DIALOG_SHOW_TYPE_ClEAR=2;
	//我的顾客
	public static final int  CUSTOMER_FILTER_TYPE_MY=0;
	//全部顾客
	public static final int  CUSTOMER_FILTER_TYPE_COMPANY=1;
	//本店顾客
	public static final int  CUSTOMER_FILTER_TYPE_BRANCH=2;
	//订单来源 全部
	public static final int  ORDER_SOURCE_ALL=-1;
	//订单来源 商家
	public static final int  ORDER_SOURCE_COMPANY=0;
	//订单来源 顾客
	public static final int  ORDER_SOURCE_CUSTOMER=2;
	//订单来源 预约
	public static final int  ORDER_SOURCE_APPOINTMENT=3;
	//订单来源 促销抢购
	public static final int  ORDER_SOURCE_PROMOTION=5;
	//订单来源 导入
	public static final int  ORDER_SOURCE_IMPORT=4;
	//订单状态定义 全部
	public static final int  ORDER_STATUS_ALL=-1;
	//订单状态定义  未完成
	public static final int  ORDER_STATUS_PROCEED=1;
	//订单状态定义  已终止
	public static final int  ORDER_STATUS_STOP=4;
	//订单状态定义  已完成
	public static final int  ORDER_STATUS_COMPLETE=2;
	//订单状态定义  已取消
	public static final int  ORDER_STATUS_CANCEL=3;
	//订单支付状态  全部
	public static final int  ORDER_PAY_STATUS_ALL=-1;
	//订单支付状态 未支付
	public static final int  ORDER_PAY_STATUS_NO_PAIED=1;
	//订单支付状态 部分付
	public static final int  ORDER_PAY_STATUS_PART_PAIED=2;
	//订单支付状态  已支付
	public static final int  ORDER_PAY_STATUS_ALL_PAIED=3;
	//订单支付状态  已退款
    public static final int  ORDER_PAY_STATUS_REFUND=4;
	//订单支付状态  免支付
    public static final int  ORDER_PAY_STATUS_NO_NEED_PAIED=5;
	public static final int  CLIENT_TYPE_BUSINESS=1;
	public static final String MD5_ENCRYPT_SUFFIX="HS";
	//登陆异常，跳转到登陆页
	public static final int    LOGIN_ERROR=10013;
	//当前版本过低
	public static final int    APP_VERSION_ERROR=10010;
	//临时保存图片的路径
	public static final String IMAGE_FILE_LOCATION="file:///sdcard/temp.jpg";
	//微信支付
	public static final int PAYMENT_MODE_WEIXIN=1;
	//支付宝支付
	public static final int PAYMENT_MODE_ALI=2;
	//订单服务组状态 全部
	public static final int  ORDER_TG_STATUS_ALL=-1;
	//进行中
	public static final int  ORDER_TG_STATUS_PROCESSED=1;
	//已完成
	public static final int  ORDER_TG_STATUS_COMPLETE=2;
	//待确认
	public static final int  ORDER_TG_STATUS_CONFIRM=5;
	
}
