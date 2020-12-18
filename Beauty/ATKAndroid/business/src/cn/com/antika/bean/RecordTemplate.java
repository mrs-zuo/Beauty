/**
 * RecordTemplate.java
 * cn.com.antika.bean
 * tim.zhang@bizapper.com
 * 2015年5月22日 下午1:57:44
 * @version V1.0
 */
package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;

/**
 *RecordTemplate
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年5月22日 下午1:57:44
 * 专业信息或者咨询记录的模板对象
 */
public class RecordTemplate implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int     recordTemplateID;//模板主键
	private int     groupID;
	private String  recordTemplateTitle;//模板标题
	private String  recordTemplateUpdateTime;//模板最后客户答的时间
	private String  recordTemplateCustomerName;//模板作答的客户姓名
	private String  recordTemplateResponsibleName;//模板作答的美丽顾问姓名
	private boolean recordTemplateIsVisible;//模板作答对客户是否可见
	private boolean recordTemplateIsEditable;//模板下面的题目回答过了之后是否可编辑
	private List<CustomerVocation> customerVocationList;//模板下面的题目列表
	private int  customerID;
	private boolean isTemp;
	public int getRecordTemplateID() {
		return recordTemplateID;
	}
	public void setRecordTemplateID(int recordTemplateID) {
		this.recordTemplateID = recordTemplateID;
	}
	public String getRecordTemplateTitle() {
		return recordTemplateTitle;
	}
	public void setRecordTemplateTitle(String recordTemplateTitle) {
		this.recordTemplateTitle = recordTemplateTitle;
	}
	public String getRecordTemplateUpdateTime() {
		return recordTemplateUpdateTime;
	}
	public void setRecordTemplateUpdateTime(String recordTemplateUpdateTime) {
		this.recordTemplateUpdateTime = recordTemplateUpdateTime;
	}
	public String getRecordTemplateCustomerName() {
		return recordTemplateCustomerName;
	}
	public void setRecordTemplateCustomerName(String recordTemplateCustomerName) {
		this.recordTemplateCustomerName = recordTemplateCustomerName;
	}
	public String getRecordTemplateResponsibleName() {
		return recordTemplateResponsibleName;
	}
	public void setRecordTemplateResponsibleName(
			String recordTemplateResponsibleName) {
		this.recordTemplateResponsibleName = recordTemplateResponsibleName;
	}
	public boolean isRecordTemplateIsVisible() {
		return recordTemplateIsVisible;
	}
	public void setRecordTemplateIsVisible(boolean recordTemplateIsVisible) {
		this.recordTemplateIsVisible = recordTemplateIsVisible;
	}
	public List<CustomerVocation> getCustomerVocationList() {
		return customerVocationList;
	}
	public void setCustomerVocationList(List<CustomerVocation> customerVocationList) {
		this.customerVocationList = customerVocationList;
	}
	public boolean isRecordTemplateIsEditable() {
		return recordTemplateIsEditable;
	}
	public void setRecordTemplateIsEditable(boolean recordTemplateIsEditable) {
		this.recordTemplateIsEditable = recordTemplateIsEditable;
	}
	public int getGroupID() {
		return groupID;
	}
	public void setGroupID(int groupID) {
		this.groupID = groupID;
	}
	public int getCustomerID() {
		return customerID;
	}
	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	public boolean isTemp() {
		return isTemp;
	}
	public void setTemp(boolean isTemp) {
		this.isTemp = isTemp;
	}
}
