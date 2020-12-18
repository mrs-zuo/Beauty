package cn.com.antika.bean;

import java.io.Serializable;
/*
 * 门店的累计数据报表
 *
 * */
public class ReportTotal implements Serializable {
	private static final long serialVersionUID = 1L;
	private int    totalCustomerNumber;//有效顾客数量
	private int    totalCustomerApp;//顾客端用户
	private int    totalCustomerTouch;//公众号用户
	private int totalCompleteOrderNumber;//完成订单数量
	private int totalEffectOrderNumber;//有效订单数量
	private double totalSales;//订单总金额
	
	public int getTotalCustomerNumber() {
		return totalCustomerNumber;
	}
	public void setTotalCustomerNumber(int totalCustomerNumber) {
		this.totalCustomerNumber = totalCustomerNumber;
	}
	public int getTotalCompleteOrderNumber() {
		return totalCompleteOrderNumber;
	}
	public void setTotalCompleteOrderNumber(int totalCompleteOrderNumber) {
		this.totalCompleteOrderNumber = totalCompleteOrderNumber;
	}
	public int getTotalEffectOrderNumber() {
		return totalEffectOrderNumber;
	}
	public void setTotalEffectOrderNumber(int totalEffectOrderNumber) {
		this.totalEffectOrderNumber = totalEffectOrderNumber;
	}
	public double getTotalSales() {
		return totalSales;
	}
	public void setTotalSales(double totalSales) {
		this.totalSales = totalSales;
	}
	public int getTotalCustomerApp() {
		return totalCustomerApp;
	}
	public void setTotalCustomerApp(int totalCustomerApp) {
		this.totalCustomerApp = totalCustomerApp;
	}
	public int getTotalCustomerTouch() {
		return totalCustomerTouch;
	}
	public void setTotalCustomerTouch(int totalCustomerTouch) {
		this.totalCustomerTouch = totalCustomerTouch;
	}
}
