package cn.com.antika.bean;

import java.io.Serializable;

/*
 * 服务订单下的联系
 * */
public class Contact implements Serializable{
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么)
	 */
	private static final long serialVersionUID = 1L;
	private int    id;
	private String time;
	private int    scheduleID;
	private int    isCompleted;
	private String remark;
	private int    contactControlFlag;
	public Contact(){
		
	}
	public int getId() {
		return id;
	}

	public String getTime() {
		return time;
	}

	public int getScheduleID() {
		return scheduleID;
	}

	public int getIsCompleted() {
		return isCompleted;
	}

	public String getRemark() {
		return remark;
	}

	public void setId(int id) {
		this.id = id;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public void setScheduleID(int scheduleID) {
		this.scheduleID = scheduleID;
	}

	public void setIsCompleted(int isCompleted) {
		this.isCompleted = isCompleted;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}
	public int getContactControlFlag() {
		return contactControlFlag;
	}
	public void setContactControlFlag(int contactControlFlag) {
		this.contactControlFlag = contactControlFlag;
	}
}
