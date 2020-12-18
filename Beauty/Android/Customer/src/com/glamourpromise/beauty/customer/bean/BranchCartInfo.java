package com.glamourpromise.beauty.customer.bean;

public class BranchCartInfo {
	private int branchID;
	private int cartListPostion;
	private Boolean isSelect=false;
	private int currentSelectSize=0;
	private int size;
	private int availableSize=0;
	public int getBranchID() {
		return branchID;
	}
	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}
	public int getCartListPostion() {
		return cartListPostion;
	}
	public void setCartListPostion(int cartListPostion) {
		this.cartListPostion = cartListPostion;
	}
	public Boolean getIsSelect() {
		return isSelect;
	}
	public void setIsSelect(Boolean isSelect) {
		this.isSelect = isSelect;
	}
	
	public int getCurrentSelectSize() {
		return currentSelectSize;
	}
	
	public void setCurrentSelectSize(int currentSelectSize) {
		this.currentSelectSize = currentSelectSize;
	}
	public void subCurrentSelectSize() {
		currentSelectSize--;
	}
	public void addCurrentSelectSize(){
		this.currentSelectSize++;
	}
	public int getSize() {
		return size;
	}
	public void setSize(int size) {
		this.size = size;
	}
	public void subSize(int count) {
		this.size -= count;
	}
	public int getAvailableSize() {
		return availableSize;
	}
	public void setAvailableSize(int availableSize) {
		this.availableSize = availableSize;
	}
	public void addAvailableSize() {
		this.availableSize++;
	}
	
}
