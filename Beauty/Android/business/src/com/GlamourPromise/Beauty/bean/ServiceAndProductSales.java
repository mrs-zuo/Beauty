/**
 * ServiceAndProductSales.java
 * com.GlamourPromise.Beauty.bean
 * tim.zhang@bizapper.com
 * 2015年3月25日 下午4:24:40
 * @version V1.0
 */
package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

/**
 *ServiceAndProductSales
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年3月25日 下午4:24:40
 */
public class ServiceAndProductSales implements Serializable{
	private String objectName;//服务或者商品名称
	private int    quantity;//服务或者商品数量
	private String   quantityScale;//服务或者商品的数量百分比
	private double   totalPrice;//服务或者商品的价格
	private String   totalPriceScale;//服务或者商品的价格百分比
	private double   totalProfitRatePrice;//业绩额
	public String getObjectName() {
		return objectName;
	}
	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}
	public int getQuantity() {
		return quantity;
	}
	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}
	public String getQuantityScale() {
		return quantityScale;
	}
	public void setQuantityScale(String quantityScale) {
		this.quantityScale = quantityScale;
	}
	public double getTotalPrice() {
		return totalPrice;
	}
	public void setTotalPrice(double totalPrice) {
		this.totalPrice = totalPrice;
	}
	public String getTotalPriceScale() {
		return totalPriceScale;
	}
	public void setTotalPriceScale(String totalPriceScale) {
		this.totalPriceScale = totalPriceScale;
	}
	public double getTotalProfitRatePrice() {
		return totalProfitRatePrice;
	}
	public void setTotalProfitRatePrice(double totalProfitRatePrice) {
		this.totalProfitRatePrice = totalProfitRatePrice;
	}
}
