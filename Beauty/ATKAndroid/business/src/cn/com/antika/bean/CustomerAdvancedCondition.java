package cn.com.antika.bean;

import java.io.Serializable;

/*
 * Customer高级筛选的条件
 * 
 * */
public class CustomerAdvancedCondition implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private  int     customerType;//顾客类型    0:我的顾客  1:全部顾客  2:本店顾客
	private  String  cardCode;//等级ID  null:所有等级   0:没有等级   >0:相应的等级
	private  String  accountIDs;//美丽顾问
	private  int     registFrom;//注册方式  -1:全部   0：商家注册 1：顾客导入 2：自助注册(T站)
	private  int     sourceTypeID;//顾客来源  -1：全部  其他按照选择的选项赋值
	private  int     FirstVisitType;//当日首次上门  0：全部  1:当天的日期  2:画面选择的日期
	private  String  FirstVisitDateTime;//选择首次上门 日期
	private  int     EffectiveCustomerType;//顾客状态  0：全部  1:有效顾客  2:无效顾客
	private String customerName;//顾客姓名
	private String customerTel; //顾客电话
	private boolean pageFlg;//是否分页
	private boolean loadMoreFlg;//是否还有更多
	private int pageIndex = 1;//当前页
	private int pageSize = 200;//每次加载记录数
	private String searchDateTime;//起始查询时间(分页时解决传统分页数据变更时查询数据差异问题)
	
	public int getCustomerType() {
		return customerType;
	}
	public void setCustomerType(int customerType) {
		this.customerType = customerType;
	}
	public String getCardCode() {
		return cardCode;
	}
	public void setCardCode(String cardCode) {
		this.cardCode = cardCode;
	}
	public String getAccountIDs() {
		return accountIDs;
	}
	public void setAccountIDs(String accountIDs) {
		this.accountIDs = accountIDs;
	}
	public int getRegistFrom() {
		return registFrom;
	}
	public void setRegistFrom(int registFrom) {
		this.registFrom = registFrom;
	}
	public int getSourceTypeID() {
		return sourceTypeID;
	}
	public void setSourceTypeID(int sourceTypeID) {
		this.sourceTypeID = sourceTypeID;
	}

	public int getFirstVisitType() {
		return FirstVisitType;
	}
	public void setFirstVisitType(int firstVisitType) {
		FirstVisitType = firstVisitType;
	}
	public String getFirstVisitDateTime() {
		return FirstVisitDateTime;
	}
	public void setFirstVisitDateTime(String firstVisitDateTime) {
		FirstVisitDateTime = firstVisitDateTime;
	}
	public int getEffectiveCustomerType() {
		return EffectiveCustomerType;
	}
	public void setEffectiveCustomerType(int effectiveCustomerType) {
		EffectiveCustomerType = effectiveCustomerType;
	}
	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	public String getCustomerTel() {
		return customerTel;
	}
	public void setCustomerTel(String customerTel) {
		this.customerTel = customerTel;
	}
	public boolean isPageFlg() {
		return pageFlg;
	}
	public void setPageFlg(boolean pageFlg) {
		this.pageFlg = pageFlg;
	}
	public boolean isLoadMoreFlg() {
		return loadMoreFlg;
	}
	public void setLoadMoreFlg(boolean loadMoreFlg) {
		this.loadMoreFlg = loadMoreFlg;
	}
	public int getPageIndex() {
		return pageIndex;
	}
	public void setPageIndex(int pageIndex) {
		this.pageIndex = pageIndex;
	}
	public int getPageSize() {
		return pageSize;
	}
	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}
	public String getSearchDateTime() {
		return searchDateTime;
	}
	public void setSearchDateTime(String searchDateTime) {
		this.searchDateTime = searchDateTime;
	}
}
