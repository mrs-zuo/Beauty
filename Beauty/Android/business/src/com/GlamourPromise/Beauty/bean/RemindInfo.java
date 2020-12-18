package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

/*
 * 提醒 包括生日 服务 和回访
 * */
public class RemindInfo implements Serializable {
	private static final long serialVersionUID = 1L;
	private String scheduleTime;// 服务和顾客生日时间
	private int scheduleType;// 0:服务  1：回访   2：生日
	private String remindContent;// 服务或者回访的服务名称
	private int remindType;// 提醒类型  0:服务提醒  1：回访提醒  2：生日提醒
	private int orderID;
	private int productType;
	public String getScheduleTime() {
		return scheduleTime;
	}
	public void setScheduleTime(String scheduleTime) {
		this.scheduleTime = scheduleTime;
	}

	public int getScheduleType() {
		return scheduleType;
	}
	public void setScheduleType(int scheduleType) {
		this.scheduleType = scheduleType;
	}
	public String getRemindContent() {
		return remindContent;
	}

	public void setRemindContent(String remindContent) {
		this.remindContent = remindContent;
	}
	public int getRemindType() {
		return remindType;
	}
	public void setRemindType(int remindType) {
		this.remindType = remindType;
	}
	public int getOrderID() {
		return orderID;
	}
	public void setOrderID(int orderID) {
		this.orderID = orderID;
	}
	public int getProductType() {
		return productType;
	}
	public void setProductType(int productType) {
		this.productType = productType;
	}
}
