package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;
/*
 * course下的服务详细
 * */
public class Treatment implements Serializable{
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么) 
	 */
	private static final long serialVersionUID = 1L;
	private String  treatmentCode;//服务编码
	private int     id;
	private int     executorID;
	private String  executorName;
	private String  startTime;//开始时间
	private String  endTime;//结束时间
	private int     scheduleID;
	private  int    isCompleted;//服务是否已完成
	private String  remark;
	private String  subServiceName;//子服务名称
	private int     subServiceId;
	private boolean isDesignated;
	private int     orderObjectID;
	private int		delflag = 0;
	private List<TreatmentImage> treatmentImageList;
	public Treatment(){
		isDesignated=false;
	}
	
	public int getDelflag() {
		return delflag;
	}

	public void setDelflag(int delflag) {
		this.delflag = delflag;
	}

	public boolean isDesignated() {
		return isDesignated;
	}

	public void setDesignated(boolean isDesignated) {
		this.isDesignated = isDesignated;
	}

	public int getSubServiceId() {
		return subServiceId;
	}
	public void setSubServiceId(int subServiceId) {
		this.subServiceId = subServiceId;
	}
	public int getId() {
		return id;
	}
	public int getExecutorID() {
		return executorID;
	}
	public String getExecutorName() {
		return executorName;
	}
	public int getScheduleID() {
		return scheduleID;
	}
	public void setId(int id) {
		this.id = id;
	}
	public void setExecutorID(int executorID) {
		this.executorID = executorID;
	}
	public void setExecutorName(String executorName) {
		this.executorName = executorName;
	}
	public void setScheduleID(int scheduleID) {
		this.scheduleID = scheduleID;
	}
	
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	public String getSubServiceName() {
		return subServiceName;
	}
	public void setSubServiceName(String subServiceName) {
		this.subServiceName = subServiceName;
	}
	public String getTreatmentCode() {
		return treatmentCode;
	}
	public void setTreatmentCode(String treatmentCode) {
		this.treatmentCode = treatmentCode;
	}
	public int getIsCompleted() {
		return isCompleted;
	}
	public void setIsCompleted(int isCompleted) {
		this.isCompleted = isCompleted;
	}
	public String getStartTime() {
		return startTime;
	}
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}
	public String getEndTime() {
		return endTime;
	}
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	
	public int getOrderObjectID() {
		return orderObjectID;
	}

	public void setOrderObjectID(int orderObjectID) {
		this.orderObjectID = orderObjectID;
	}

	public List<TreatmentImage> getTreatmentImageList() {
		return treatmentImageList;
	}

	public void setTreatmentImageList(List<TreatmentImage> treatmentImageList) {
		this.treatmentImageList = treatmentImageList;
	}
}
