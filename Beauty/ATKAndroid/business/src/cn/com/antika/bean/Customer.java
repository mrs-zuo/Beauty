package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;

/*
 * customer信息类
 * */
public class Customer implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Integer    customerId;
	private String     customerName;
	private String     customerSex;
	private String     headImageUrl;
	private String     pinYin;
	private String     loginMobile;//用于显示的授权登陆号码
	private String     originalLoginMobile;//用于搜索的授权登陆号码
	private String     accountCode;
	private String     department;
	private String     title;
	private String     expert;
	private String     authorizeID;
	private int        gender;
	private String     birthday;
	private String     height;
	private String     weight;
	private String     bloodType;
	private String     marriage;
	private String     profession;
	private String     remark;
	private List<PersonSchedule> personScheduleList;
	private String    discount;
	private int       isSelected;
	private int       responsiblePersonID;
	private String    responsiblePersonName,salesName;
	private float     customerEcardBalanceValue;
	private boolean   isMyCustomer;//false:不是我的顾客  true:是我的顾客
	private String    phone;//顾客的号码字符串 用于可以通过其他的电话（非授权登陆号码）号码可以搜索到顾客
	private List<PhoneInfo> phoneInfoList;
	private List<EmailInfo> emailInfoList;
	private List<AddressInfo> addressInfoList;
	private boolean   isImport;//是否是导入顾客 false：不是导入顾客  true：是导入顾客
	private int       accountType;//获取员工时，表示该员工相对于某一个顾客时的身份    0:专属顾问 1:销售顾问  2:普通员工
	private int       registFrom;//顾客来源      0：商家注册 1：顾客导入 2：自助注册(T站)
	private SourceType sourceType;
	private String   ComeTime;//null:未上门  其他：显示上门时间
	
    public Customer()
    {
    	originalLoginMobile = "";
    	isImport=false;
    	accountType=2;
    }
	public Integer getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Integer customerId) {
		this.customerId = customerId;
	}

	public String getCustomerName() {
		return customerName;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public String getHeadImageUrl() {
		return headImageUrl;
	}

	public void setHeadImageUrl(String headImageUrl) {
		this.headImageUrl = headImageUrl;
	}

	public String getPinYin() {
		return pinYin;
	}

	public void setPinYin(String pinYin) {
		this.pinYin = pinYin;
	}
	public List<PhoneInfo> getPhoneInfoList() {
		return phoneInfoList;
	}

	public void setPhoneInfoList(List<PhoneInfo> phoneInfoList) {
		this.phoneInfoList = phoneInfoList;
	}

	public List<EmailInfo> getEmailInfoList() {
		return emailInfoList;
	}

	public void setEmailInfoList(List<EmailInfo> emailInfoList) {
		this.emailInfoList = emailInfoList;
	}

	public List<AddressInfo> getAddressInfoList() {
		return addressInfoList;
	}

	public void setAddressInfoList(List<AddressInfo> addressInfoList) {
		this.addressInfoList = addressInfoList;
	}

	public String getAuthorizeID() {
		return authorizeID;
	}

	public void setAuthorizeID(String authorizeID) {
		this.authorizeID = authorizeID;
	}

	public String getCustomerSex() {
		return customerSex;
	}

	public void setCustomerSex(String customerSex) {
		this.customerSex = customerSex;
	}
	public int getGender() {
		return gender;
	}
	public void setGender(int gender) {
		this.gender = gender;
	}
	public String getBirthday() {
		return birthday;
	}
	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}
	public String getHeight() {
		return height;
	}
	public void setHeight(String height) {
		this.height = height;
	}
	public String getWeight() {
		return weight;
	}
	public void setWeight(String weight) {
		this.weight = weight;
	}
	public String getBloodType() {
		return bloodType;
	}
	public void setBloodType(String bloodType) {
		this.bloodType = bloodType;
	}
	public String getMarriage() {
		return marriage;
	}
	public void setMarriage(String marriage) {
		this.marriage = marriage;
	}
	public String getProfession() {
		return profession;
	}
	public void setProfession(String profession) {
		this.profession = profession;
	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	
	public String getAccountCode() {
		return accountCode;
	}
	public String getDepartment() {
		return department;
	}
	public String getTitle() {
		return title;
	}
	public String getExpert() {
		return expert;
	}
	public void setAccountCode(String accountCode) {
		this.accountCode = accountCode;
	}
	public void setDepartment(String department) {
		this.department = department;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public void setExpert(String expert) {
		this.expert = expert;
	}
	public List<PersonSchedule> getPersonScheduleList() {
		return personScheduleList;
	}
	public void setPersonScheduleList(List<PersonSchedule> personScheduleList) {
		this.personScheduleList = personScheduleList;
	}
	
	public String getDiscount() {
		return discount;
	}
	public void setDiscount(String discount) {
		this.discount = discount;
	}
	public String getLoginMobile() {
		return loginMobile;
	}
	public void setLoginMobile(String loginMobile) {
		this.loginMobile = loginMobile;
	}
	
	public String getOriginalLoginMobile() {
		return originalLoginMobile;
	}
	public void setOriginalLoginMobile(String originalLoginMobile) {
		this.originalLoginMobile = originalLoginMobile;
	}
	public int getIsSelected() {
		return isSelected;
	}
	public void setIsSelected(int isSelected) {
		this.isSelected = isSelected;
	}
	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}
	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}
	public float getCustomerEcardBalanceValue() {
		return customerEcardBalanceValue;
	}
	public void setCustomerEcardBalanceValue(float customerEcardBalanceValue) {
		this.customerEcardBalanceValue = customerEcardBalanceValue;
	}
	public boolean getIsMyCustomer() {
		return isMyCustomer;
	}
	public void setIsMyCustomer(boolean isMyCustomer) {
		this.isMyCustomer = isMyCustomer;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public boolean isImport() {
		return isImport;
	}
	public void setImport(boolean isImport) {
		this.isImport = isImport;
	}
	public String getSalesName() {
		return salesName;
	}
	public void setSalesName(String salesName) {
		this.salesName = salesName;
	}
	public int getAccountType() {
		return accountType;
	}
	public void setAccountType(int accountType) {
		this.accountType = accountType;
	}
	public void setMyCustomer(boolean isMyCustomer) {
		this.isMyCustomer = isMyCustomer;
	}
	public int getResponsiblePersonID() {
		return responsiblePersonID;
	}
	public void setResponsiblePersonID(int responsiblePersonID) {
		this.responsiblePersonID = responsiblePersonID;
	}
	public int getRegistFrom() {
		return registFrom;
	}
	public void setRegistFrom(int registFrom) {
		this.registFrom = registFrom;
	}
	public SourceType getSourceType() {
		return sourceType;
	}
	public void setSourceType(SourceType sourceType) {
		this.sourceType = sourceType;
	}
	public String getComeTime() {
		return ComeTime;
	}
	public void setComeTime(String comeTime) {
		ComeTime = comeTime;
	}
}
