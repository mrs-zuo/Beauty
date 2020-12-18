package cn.com.antika.bean;

import java.io.Serializable;

public class Opportunity implements Serializable{
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么)
	 */
	private static final long serialVersionUID = 1L;
	private String  customerName = "";//需求的顾客姓名
	private Integer customerID = 0;//需求的顾客ID
	private Integer opportunityID = 0;//需求ID
	private String  productName = "";//需求的商品名称
	private Integer productID = 0;//商品或者服务的ID
	private Integer productType = 0;//类型  是服务还是商品
	private Integer quantity = 0;//商品或者服务的数量
	private String  totalPrice ="0";//总计
	private String  totalSalePrice ="0";//最终销售价
	private String  creatTime = "";//需求的建立时间
	private Integer progress = 0;
	private String  progressRate = "";
	private String  stepContent = "";
	private String  unitPrice ="0";
	private String  promotionPrice ="0";
	private Integer marketingPolicy = 0;
	private long    productCode=0;
	private String  expirationDate;
	private int     responsiblePersonID=0;
	private double  discount;
	private String  responsiblePersonName="";
	private int     branchID=0;//建立需求的分店ID
	private boolean available;//商机是否有效
	public Opportunity() {

	}

	public String getCustomerName() {
		return customerName;
	}

	public Integer getCustomerID() {
		return customerID;
	}

	public Integer getOpportunityID() {
		return opportunityID;
	}

	public String getProductName() {
		return productName;
	}

	public Integer getProductID() {
		return productID;
	}

	public Integer getProductType() {
		return productType;
	}

	public Integer getQuantity() {
		return quantity;
	}

	public String getCreatTime() {
		return creatTime;
	}

	public Integer getProgress() {
		return progress;
	}

	public String getProgressRate() {
		return progressRate;
	}

	public String getStepContent() {
		return stepContent;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public void setCustomerID(Integer customerID) {
		this.customerID = customerID;
	}

	public void setOpportunityID(Integer opportunityID) {
		this.opportunityID = opportunityID;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public void setProductID(Integer productID) {
		this.productID = productID;
	}

	public void setProductType(Integer productType) {
		this.productType = productType;
	}

	public void setQuantity(Integer quantity) {
		this.quantity = quantity;
	}

	public void setCreatTime(String creatTime) {
		this.creatTime = creatTime;
	}

	public void setProgress(Integer progress) {
		this.progress = progress;
	}

	public void setProgressRate(String progressRate) {
		this.progressRate = progressRate;
	}

	public void setStepContent(String stepContent) {
		this.stepContent = stepContent;
	}
	public Integer getMarketingPolicy() {
		return marketingPolicy;
	}
	public void setMarketingPolicy(Integer marketingPolicy) {
		this.marketingPolicy = marketingPolicy;
	}

	public double getDiscount() {
		return discount;
	}

	public void setDiscount(double discount) {
		this.discount = discount;
	}
	public String getTotalPrice() {
		return totalPrice;
	}
	public String getTotalSalePrice() {
		return totalSalePrice;
	}
	public void setTotalPrice(String totalPrice) {
		this.totalPrice = totalPrice;
	}
	public void setTotalSalePrice(String totalSalePrice) {
		this.totalSalePrice = totalSalePrice;
	}
	public String getUnitPrice() {
		return unitPrice;
	}

	public String getPromotionPrice() {
		return promotionPrice;
	}

	public void setUnitPrice(String unitPrice) {
		this.unitPrice = unitPrice;
	}

	public void setPromotionPrice(String promotionPrice) {
		this.promotionPrice = promotionPrice;
	}

	public long getProductCode() {
		return productCode;
	}

	public void setProductCode(long productCode) {
		this.productCode = productCode;
	}

	public String getExpirationDate() {
		return expirationDate;
	}

	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}

	public int getResponsiblePersonID() {
		return responsiblePersonID;
	}

	public void setResponsiblePersonID(int responsiblePersonID) {
		this.responsiblePersonID = responsiblePersonID;
	}

	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}

	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}

	public int getBranchID() {
		return branchID;
	}

	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}

	public boolean isAvailable() {
		return available;
	}

	public void setAvailable(boolean available) {
		this.available = available;
	}
}
