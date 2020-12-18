package cn.com.antika.bean;

import java.io.Serializable;
import java.util.List;

public class Level implements Serializable{
	private static final long serialVersionUID = 1L;
	private int levelID;
	private String levelName;
	private boolean isDefault;//设置会员默认等级
	private List<DiscountDetail> discountDetailList;
	public int getLevelID() {
		return levelID;
	}
	public String getLevelName() {
		return levelName;
	}
	public void setLevelID(int levelID) {
		this.levelID = levelID;
	}

	public void setLevelName(String levelName) {
		this.levelName = levelName;
	}
	public List<DiscountDetail> getDiscountDetailList() {
		return discountDetailList;
	}

	public void setDiscountDetailList(List<DiscountDetail> discountDetailList) {
		this.discountDetailList = discountDetailList;
	}
	public boolean isDefault() {
		return isDefault;
	}
	public void setDefault(boolean isDefault) {
		this.isDefault = isDefault;
	}
}
