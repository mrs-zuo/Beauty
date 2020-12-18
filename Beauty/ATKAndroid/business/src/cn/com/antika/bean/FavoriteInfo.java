package cn.com.antika.bean;

import java.io.Serializable;

public class FavoriteInfo implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private String      favoriteID;
	private String      productID;
	private String      productCode;
	private String      productName;
	private int         productType;
	private String      sortID;
	private int         marketingPolicy;
	private String      unitPrice;
	private String      promotionPrice;
	private String      fileUrl;
	private Boolean     isSelect;
	private boolean     available;
	private String      expirationDate;//服务过期日期
	private String      specification;
	public FavoriteInfo(){
		marketingPolicy =0;
		unitPrice = "0.00";
		promotionPrice = "0.00";
		isSelect = false;
		productID = "0";
		available=true;
		specification="";
	}
	public String getFavoriteID() {
		return favoriteID;
	}
	public void setFavoriteID(String favoriteID) {
		this.favoriteID = favoriteID;
	}
	
	public String getProductID() {
		return productID;
	}
	public void setProductID(String productID) {
		this.productID = productID;
	}
	public String getProductCode() {
		return productCode;
	}
	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}
	public int getProductType() {
		return productType;
	}
	public void setProductType(int productType) {
		this.productType = productType;
	}
	public String getSortID() {
		return sortID;
	}
	public void setSortID(String sortID) {
		this.sortID = sortID;
	}
	public int getMarketingPolicy() {
		return marketingPolicy;
	}
	public void setMarketingPolicy(int marketingPolicy) {
		this.marketingPolicy = marketingPolicy;
	}
	public String getUnitPrice() {
		return unitPrice;
	}
	public void setUnitPrice(String unitPrice) {
		this.unitPrice = unitPrice;
	}
	public String getPromotionPrice() {
		return promotionPrice;
	}
	public void setPromotionPrice(String promotionPrice) {
		this.promotionPrice = promotionPrice;
	}
	public String getFileUrl() {
		return fileUrl;
	}
	public void setFileUrl(String fileUrl) {
		this.fileUrl = fileUrl;
	}
	public Boolean getIsSelect() {
		return isSelect;
	}
	public void setIsSelect(Boolean isSelect) {
		this.isSelect = isSelect;
	}
	public boolean isAvailable() {
		return available;
	}
	public void setAvailable(boolean available) {
		this.available = available;
	}
	public String getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}
	public String getSpecification() {
		return specification;
	}
	public void setSpecification(String specification) {
		this.specification = specification;
	}
}
