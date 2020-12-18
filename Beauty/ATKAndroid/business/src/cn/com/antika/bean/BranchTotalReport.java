/**
 * BranchTotalReport.java
 * cn.com.antika.bean
 * tim.zhang@bizapper.com
 * 2015年7月20日 下午5:24:47
 * @version V1.0
 */
package cn.com.antika.bean;

import java.io.Serializable;

/**
 *BranchTotalReport
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月20日 下午5:24:47
 */
public class BranchTotalReport implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int  customerCount;//到店顾客数
	private int  tgExecutingCount;//正在做的服务
	private int  tgFinishedCount;//完成的服务
	private int  tgUnConfirmedCount;//待确认的服务
	private int  serviceOrderCount;//服务订单数
	private int  commodityOrderCount;//商品订单数
	private int  cancelServiceOrderCount;//取消服务订单数
	private int  cancelCommodityOrderCount;//取消商品订单数
	private String saleAmount;//今日营业额
	public int getCustomerCount() {
		return customerCount;
	}
	public void setCustomerCount(int customerCount) {
		this.customerCount = customerCount;
	}
	public int getTgExecutingCount() {
		return tgExecutingCount;
	}
	public void setTgExecutingCount(int tgExecutingCount) {
		this.tgExecutingCount = tgExecutingCount;
	}
	public int getTgFinishedCount() {
		return tgFinishedCount;
	}
	public void setTgFinishedCount(int tgFinishedCount) {
		this.tgFinishedCount = tgFinishedCount;
	}
	public int getServiceOrderCount() {
		return serviceOrderCount;
	}
	public void setServiceOrderCount(int serviceOrderCount) {
		this.serviceOrderCount = serviceOrderCount;
	}
	public int getCommodityOrderCount() {
		return commodityOrderCount;
	}
	public void setCommodityOrderCount(int commodityOrderCount) {
		this.commodityOrderCount = commodityOrderCount;
	}
	public String getSaleAmount() {
		return saleAmount;
	}
	public void setSaleAmount(String saleAmount) {
		this.saleAmount = saleAmount;
	}
	public int getTgUnConfirmedCount() {
		return tgUnConfirmedCount;
	}
	public void setTgUnConfirmedCount(int tgUnConfirmedCount) {
		this.tgUnConfirmedCount = tgUnConfirmedCount;
	}
	public int getCancelServiceOrderCount() {
		return cancelServiceOrderCount;
	}
	public void setCancelServiceOrderCount(int cancelServiceOrderCount) {
		this.cancelServiceOrderCount = cancelServiceOrderCount;
	}
	public int getCancelCommodityOrderCount() {
		return cancelCommodityOrderCount;
	}
	public void setCancelCommodityOrderCount(int cancelCommodityOrderCount) {
		this.cancelCommodityOrderCount = cancelCommodityOrderCount;
	}
}
