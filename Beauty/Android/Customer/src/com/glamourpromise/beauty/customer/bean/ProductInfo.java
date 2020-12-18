package com.glamourpromise.beauty.customer.bean;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
/*
 * 服务与商品的基类
 * 
 * */

public class ProductInfo {
	protected int    ID=0;
	protected String code="0";
	protected String name="";
	protected String unitPrice="0.00";
	protected String discountPrice="0.00";
	protected int    marketingPolicy = 0;//优惠政策
	protected String thumbnail="";
	protected String mFavoriteID;//收藏ID
	public int getID() {
		return ID;
	}
	public void setID(int iD) {
		ID = iD;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getUnitPrice() {
		return unitPrice;
	}
	public void setUnitPrice(String unitPrice) {
		this.unitPrice = NumberFormatUtil.StringFormatToStringWithoutSingle(unitPrice);
	}
	public String getDiscountPrice() {
		return discountPrice;
	}
	public void setDiscountPrice(String discountPrice) {
		this.discountPrice = NumberFormatUtil.StringFormatToStringWithoutSingle(discountPrice);
	}
	public String getThumbnail() {
		return thumbnail;
	}
	public void setThumbnail(String thumbnail) {
			this.thumbnail = thumbnail;
	}
	public int getMarketingPolicy() {
		return marketingPolicy;
	}
	public void setMarketingPolicy(int marketingPolicy) {
		this.marketingPolicy = marketingPolicy;
	}
	public String getmFavoriteID() {
		return mFavoriteID;
	}
	public void setmFavoriteID(String mFavoriteID) {
		this.mFavoriteID = mFavoriteID;
	}
}
