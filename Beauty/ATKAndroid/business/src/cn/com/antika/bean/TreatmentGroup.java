/**
 * TreatmentGroup.java
 * cn.com.antika.bean
 * tim.zhang@bizapper.com
 * 2015年1月13日 下午4:50:10
 * @version V1.0
 */
package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;

/**
 *TreatmentGroup
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年1月13日 下午4:50:10
 * 定义一个服务组  连接订单的课程和服务  一个服务组可以对多个(子)服务或者一个服务
 */
public class TreatmentGroup implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private  long    treatmentGroupID;
	private  int     servicePicID;//服务顾问ID
	private  String  servicePicName;//服务顾问名字
	private  String  branchName;//服务店名
	private  int     commodityQuantity;//商品交付的数量
	private  String  startTime;//商品或者服务开始的时间
	private  String  endTime;
	private  int     status;
	private  String  remark,signImageUrl;
	private  List<Treatment> treatmentList;
	public TreatmentGroup() {
	}
	public long getTreatmentGroupID() {
		return treatmentGroupID;
	}
	public void setTreatmentGroupID(long treatmentGroupID) {
		this.treatmentGroupID = treatmentGroupID;
	}
	public List<Treatment> getTreatmentList() {
		return treatmentList;
	}
	public void setTreatmentList(List<Treatment> treatmentList) {
		this.treatmentList = treatmentList;
	}
	public int getServicePicID() {
		return servicePicID;
	}
	public void setServicePicID(int servicePicID) {
		this.servicePicID = servicePicID;
	}
	public String getServicePicName() {
		return servicePicName;
	}
	public void setServicePicName(String servicePicName) {
		this.servicePicName = servicePicName;
	}
	public int getCommodityQuantity() {
		return commodityQuantity;
	}
	public void setCommodityQuantity(int commodityQuantity) {
		this.commodityQuantity = commodityQuantity;
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
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	public String getBranchName() {
		return branchName;
	}
	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}
	public String getSignImageUrl() {
		return signImageUrl;
	}
	public void setSignImageUrl(String signImageUrl) {
		this.signImageUrl = signImageUrl;
	}
}	
