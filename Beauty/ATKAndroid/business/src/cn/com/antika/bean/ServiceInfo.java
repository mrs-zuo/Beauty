package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;

public class ServiceInfo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private long    serviceCode;
	private int     serviceID;
	private String  serviceName;//服务名称
	private int     marketingPolicy;//优惠政策 0:无优惠  1:按等级打折  2：固定会员价
	private String  unitPrice;//单价
	private String  promotionPrice;//促销价格
	private String  thumbnail;//服务图片
	private String  serviceDescribe;//服务简介
	private int     serviceCourseFrequency;//服务次数
	private int     serviceSpendTime;//服务时间
	private int     serviceIsChecked;//0:未被选中  1:选中
	private int     favoriteID;
	private String  expirationDate;//服务过期日期
	private String  searchField;//用于搜索的属性
	private boolean hasSubService;//是否有子服务
	private List<SubService> subServiceList;//子服务集合
	public long getServiceCode() {
		return serviceCode;
	}
	public int getServiceID() {
		return serviceID;
	}
	public String getServiceName() {
		return serviceName;
	}
	public int getMarketingPolicy() {
		return marketingPolicy;
	}
	public String getThumbnail() {
		return thumbnail;
	}
	public void setServiceCode(long serviceCode) {
		this.serviceCode = serviceCode;
	}
	public void setServiceID(int serviceID) {
		this.serviceID = serviceID;
	}
	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}
	public void setMarketingPolicy(int marketingPolicy) {
		this.marketingPolicy = marketingPolicy;
	}
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}
	public String getServiceDescribe() {
		return serviceDescribe;
	}
	public int getServiceCourseFrequency() {
		return serviceCourseFrequency;
	}
	public int getServiceSpendTime() {
		return serviceSpendTime;
	}
	public void setServiceDescribe(String serviceDescribe) {
		this.serviceDescribe = serviceDescribe;
	}
	public void setServiceCourseFrequency(int serviceCourseFrequency) {
		this.serviceCourseFrequency = serviceCourseFrequency;
	}
	public void setServiceSpendTime(int serviceSpendTime) {
		this.serviceSpendTime = serviceSpendTime;
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
	public int getServiceIsChecked() {
		return serviceIsChecked;
	}
	public void setServiceIsChecked(int serviceIsChecked) {
		this.serviceIsChecked = serviceIsChecked;
	}
	public int getFavoriteID() {
		return favoriteID;
	}
	public void setFavoriteID(int favoriteID) {
		this.favoriteID = favoriteID;
	}
	public String getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}
	public boolean isHasSubService() {
		return hasSubService;
	}
	public void setHasSubService(boolean hasSubService) {
		this.hasSubService = hasSubService;
	}
	public List<SubService> getSubServiceList() {
		return subServiceList;
	}
	public void setSubServiceList(List<SubService> subServiceList) {
		this.subServiceList = subServiceList;
	}
	public String getSearchField() {
		return searchField;
	}
	public void setSearchField(String searchField) {
		this.searchField = searchField;
	}
}
