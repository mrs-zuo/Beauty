package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

/*
 * 商品目录信息
 * */
public class CategoryInfo implements Serializable{
	private String totalCommodityCount;
	private String parentCategoryName;
	private int    parentCategoryID;
	private String categoryID;
	private String categoryName;
	private String commodityCount;
	private String nextCategoryCount;
	
	public CategoryInfo()
	{
		parentCategoryID = 0;
	}
	
	public String getParentCategoryName() {
		return parentCategoryName;
	}
	public void setParentCategoryName(String parentCategoryName) {
		this.parentCategoryName = parentCategoryName;
	}
	
	public int getParentCategoryID() {
		return parentCategoryID;
	}
	public void setParentCategoryID(int parentCategoryID) {
		this.parentCategoryID = parentCategoryID;
	}
	
	public String getTotalCommodityCount() {
		return totalCommodityCount;
	}
	public void setTotalCommodityCount(String totalCommodityCount) {
		this.totalCommodityCount = totalCommodityCount;
	}

	public String getCategoryID() {
		return categoryID;
	}

	public void setCategoryID(String categoryID) {
		this.categoryID = categoryID;
	}

	public String getCategoryName() {
		return categoryName;
	}

	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}

	public String getCommodityCount() {
		return commodityCount;
	}

	public void setCommodityCount(String commodityCount) {
		this.commodityCount = commodityCount;
	}

	public String getNextCategoryCount() {
		return nextCategoryCount;
	}

	public void setNextCategoryCount(String nextCategoryCount) {
		this.nextCategoryCount = nextCategoryCount;
	}
}
