package cn.com.antika.bean;
import java.io.Serializable;
import java.util.List;
public class CustomerBenefit implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String   benefitID;
	private String benefitName;//券名
	private String benefitRule;//券规则说明
	private String benefitDescription;//券描述
	private String grantDate;//开始日期
	private String validDate;//失效日期
	private List<BranchInfo>  branchList;//适用门店
	private int    benefitStatus;//券状态   1：未使用  2：已过期  3：已使用
	private String prcode;//6  满多少减多少
	private double prValue1;//满多少
	private double prValue2;//减多少	
	public String getBenefitID() {
		return benefitID;
	}
	public void setBenefitID(String benefitID) {
		this.benefitID = benefitID;
	}
	public String getBenefitName() {
		return benefitName;
	}
	public void setBenefitName(String benefitName) {
		this.benefitName = benefitName;
	}
	public String getBenefitRule() {
		return benefitRule;
	}
	public void setBenefitRule(String benefitRule) {
		this.benefitRule = benefitRule;
	}
	public String getBenefitDescription() {
		return benefitDescription;
	}
	public void setBenefitDescription(String benefitDescription) {
		this.benefitDescription = benefitDescription;
	}
	public List<BranchInfo> getBranchList() {
		return branchList;
	}
	public void setBranchList(List<BranchInfo> branchList) {
		this.branchList = branchList;
	}
	public int getBenefitStatus() {
		return benefitStatus;
	}
	public void setBenefitStatus(int benefitStatus) {
		this.benefitStatus = benefitStatus;
	}
	public String getGrantDate() {
		return grantDate;
	}
	public void setGrantDate(String grantDate) {
		this.grantDate = grantDate;
	}
	public String getValidDate() {
		return validDate;
	}
	public void setValidDate(String validDate) {
		this.validDate = validDate;
	}
	public String getPrcode() {
		return prcode;
	}
	public void setPrcode(String prcode) {
		this.prcode = prcode;
	}
	public double getPrValue1() {
		return prValue1;
	}
	public void setPrValue1(double prValue1) {
		this.prValue1 = prValue1;
	}
	public double getPrValue2() {
		return prValue2;
	}
	public void setPrValue2(double prValue2) {
		this.prValue2 = prValue2;
	}
}
