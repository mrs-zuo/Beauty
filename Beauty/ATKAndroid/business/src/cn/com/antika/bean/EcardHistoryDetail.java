package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;

public class EcardHistoryDetail implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String ecardHistoryDetailNo;//交易编号
	private String ecardHistoryDetailCreateTime;//交易时间
	private String ecardHistoryDetailBranchName;//交易门店
	private String ecardHistoryDetailActionModeName;//交易类型
	private String ecardHistoryDetailRemark;//交易备注
	private String ecardHistoryDetailOperator;//交易操作人
	private String ecardHistoryDetailAmount;//交易总金额
	private List<BenefitPerson> ecardHistoryDetailProfitList;//交易业绩参与人及其比例
	private List<OrderInfo>  ecardHistoryOrderList;//交易订单列表
	private List<EcardActionMode> ecardActionModeList;//发生交易的动作列表
	public String getEcardHistoryDetailNo() {
		return ecardHistoryDetailNo;
	}
	public void setEcardHistoryDetailNo(String ecardHistoryDetailNo) {
		this.ecardHistoryDetailNo = ecardHistoryDetailNo;
	}
	public String getEcardHistoryDetailCreateTime() {
		return ecardHistoryDetailCreateTime;
	}
	public void setEcardHistoryDetailCreateTime(String ecardHistoryDetailCreateTime) {
		this.ecardHistoryDetailCreateTime = ecardHistoryDetailCreateTime;
	}
	public String getEcardHistoryDetailBranchName() {
		return ecardHistoryDetailBranchName;
	}
	public void setEcardHistoryDetailBranchName(String ecardHistoryDetailBranchName) {
		this.ecardHistoryDetailBranchName = ecardHistoryDetailBranchName;
	}
	public String getEcardHistoryDetailActionModeName() {
		return ecardHistoryDetailActionModeName;
	}
	public void setEcardHistoryDetailActionModeName(
			String ecardHistoryDetailActionModeName) {
		this.ecardHistoryDetailActionModeName = ecardHistoryDetailActionModeName;
	}
	public String getEcardHistoryDetailRemark() {
		return ecardHistoryDetailRemark;
	}
	public void setEcardHistoryDetailRemark(String ecardHistoryDetailRemark) {
		this.ecardHistoryDetailRemark = ecardHistoryDetailRemark;
	}
	public String getEcardHistoryDetailOperator() {
		return ecardHistoryDetailOperator;
	}
	public void setEcardHistoryDetailOperator(String ecardHistoryDetailOperator) {
		this.ecardHistoryDetailOperator = ecardHistoryDetailOperator;
	}
	public List<BenefitPerson> getEcardHistoryDetailProfitList() {
		return ecardHistoryDetailProfitList;
	}
	public void setEcardHistoryDetailProfitList(
			List<BenefitPerson> ecardHistoryDetailProfitList) {
		this.ecardHistoryDetailProfitList = ecardHistoryDetailProfitList;
	}
	public List<OrderInfo> getEcardHistoryOrderList() {
		return ecardHistoryOrderList;
	}
	public void setEcardHistoryOrderList(List<OrderInfo> ecardHistoryOrderList) {
		this.ecardHistoryOrderList = ecardHistoryOrderList;
	}
	public List<EcardActionMode> getEcardActionModeList() {
		return ecardActionModeList;
	}
	public void setEcardActionModeList(List<EcardActionMode> ecardActionModeList) {
		this.ecardActionModeList = ecardActionModeList;
	}
	public String getEcardHistoryDetailAmount() {
		return ecardHistoryDetailAmount;
	}
	public void setEcardHistoryDetailAmount(String ecardHistoryDetailAmount) {
		this.ecardHistoryDetailAmount = ecardHistoryDetailAmount;
	}
}
