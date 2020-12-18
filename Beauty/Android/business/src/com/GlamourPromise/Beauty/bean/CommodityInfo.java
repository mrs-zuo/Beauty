package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class CommodityInfo implements Serializable{
	private String commodityID;
	private String commodityName;// 商品名
	private String unitPrice;// 原来价格
	private String promotionPrice;// 促销价格
	private String isNew;// 是否是新的商品
	private String recommended;
	private String thumbnailUrl;// 产品图片
	private long   commodityCode;//
	private String describe;//商品描述
	private String specification;
	private String commodityImageURL;
	private String stockQuantity;
	private int    imageCount;//产品图片数量
	private int    marketingPolicy;
	private int    commodityIsChecked;
	private int    favoriteID;
	private int    stockCalcType;//库存类型  1.普通库存  2.不计库存  3.超卖库存
	private String searchField;//用于搜索的属性
	public CommodityInfo() {

	}

	public String getCommodityID() {
		return commodityID;
	}

	public String getCommodityName() {
		return commodityName;
	}
	public String getIsNew() {
		return isNew;
	}

	public String getRecommended() {
		return recommended;
	}

	public String getThumbnailUrl() {
		return thumbnailUrl;
	}

	public void setCommodityID(String commodityID) {
		this.commodityID = commodityID;
	}

	public void setCommodityName(String commodityName) {
		this.commodityName = commodityName;
	}
	public void setIsNew(String isNew) {
		this.isNew = isNew;
	}

	public void setRecommended(String recommended) {
		this.recommended = recommended;
	}

	public void setThumbnailUrl(String thumbnailUrl) {
		this.thumbnailUrl = thumbnailUrl;
	}
	public String getDescribe() {
		return describe;
	}

	public String getSpecification() {
		return specification;
	}

	public String getCommodityImageURL() {
		return commodityImageURL;
	}
	public long getCommodityCode() {
		return commodityCode;
	}

	public void setCommodityCode(long commodityCode) {
		this.commodityCode = commodityCode;
	}

	public void setDescribe(String describe) {
		this.describe = describe;
	}

	public void setSpecification(String specification) {
		this.specification = specification;
	}

	public void setCommodityImageURL(String commodityImageURL) {
		this.commodityImageURL = commodityImageURL;
	}

	public String getStockQuantity() {
		return stockQuantity;
	}

	public void setStockQuantity(String stockQuantity) {
		this.stockQuantity = stockQuantity;
	}

	public int getImageCount() {
		return imageCount;
	}

	public void setImageCount(int imageCount) {
		this.imageCount = imageCount;
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

	public int getMarketingPolicy() {
		return marketingPolicy;
	}

	public void setMarketingPolicy(int marketingPolicy) {
		this.marketingPolicy = marketingPolicy;
	}

	public int getCommodityIsChecked() {
		return commodityIsChecked;
	}

	public void setCommodityIsChecked(int commodityIsChecked) {
		this.commodityIsChecked = commodityIsChecked;
	}

	public int getFavoriteID() {
		return favoriteID;
	}

	public void setFavoriteID(int favoriteID) {
		this.favoriteID = favoriteID;
	}

	public int getStockCalcType() {
		return stockCalcType;
	}

	public void setStockCalcType(int stockCalcType) {
		this.stockCalcType = stockCalcType;
	}

	public String getSearchField() {
		return searchField;
	}

	public void setSearchField(String searchField) {
		this.searchField = searchField;
	}
}
