package cn.com.antika.bean;

import java.io.Serializable;

public class UnpaidCustomerInfo implements Serializable{
	private static final long serialVersionUID = 1L;
	private int    customerID;
	private String customerName;//顾客姓名
	private String lastOrderTime;//最后一笔未支付的订单的下单时间
	private String customerLoginMobile;//顾客的登陆号码
	private String customerLoginMobileShow;//顾客的登陆号码(只显示后四位)
	private int    unPaidOrderCount;//未支付的订单数量
	
	public String getCustomerLoginMobileShow() {
		return customerLoginMobileShow;
	}
	public void setCustomerLoginMobileShow(String customerLoginMobileShow) {
		this.customerLoginMobileShow = customerLoginMobileShow;
	}
	public int getCustomerID() {
		return customerID;
	}
	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	public String getLastOrderTime() {
		return lastOrderTime;
	}
	public void setLastOrderTime(String lastOrderTime) {
		this.lastOrderTime = lastOrderTime;
	}
	public String getCustomerLoginMobile() {
		return customerLoginMobile;
	}
	public void setCustomerLoginMobile(String customerLoginMobile) {
		this.customerLoginMobile = customerLoginMobile;
	}
	public int getUnPaidOrderCount() {
		return unPaidOrderCount;
	}
	public void setUnPaidOrderCount(int unPaidOrderCount) {
		this.unPaidOrderCount = unPaidOrderCount;
	}
}
