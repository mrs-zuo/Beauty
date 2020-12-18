package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PromotionDetail {

	private String promotionPictureURL;
	private String description;
	private String title;
	private int type;
	private String endDate;
	private String promotionCode;
	private String startDate;
	private ArrayList<BranchList> branchList;

	public static ArrayList<PromotionDetail> parseListByJson(String src) {
		ArrayList<PromotionDetail> list = new ArrayList<PromotionDetail>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			PromotionDetail item;
			for (int i = 0; i < count; i++) {
				item = new PromotionDetail();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public boolean parseByJson(String src) {
		JSONObject jsSrc = null;
		try {
			jsSrc = new JSONObject(src);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return parseByJson(jsSrc);
	}

	public boolean parseByJson(JSONObject src) {
		try {
			JSONObject jsSrc = src;
			if (jsSrc.has("PromotionCode"))
				setPromotionCode(jsSrc.getString("PromotionCode"));

			if (jsSrc.has("StartDate"))
				setStartDate(jsSrc.getString("StartDate"));

			if (jsSrc.has("EndDate"))
				setEndDate(jsSrc.getString("EndDate"));

			if (jsSrc.has("Type"))
				setType(jsSrc.getInt("Type"));
			if (jsSrc.has("Title"))
				setTitle(jsSrc.getString("Title"));

			if (jsSrc.has("Description"))
				setDescription(jsSrc.getString("Description"));
			if (jsSrc.has("PromotionPictureURL"))
				setPromotionPictureURL(jsSrc.getString("PromotionPictureURL"));
			if (jsSrc.has("BranchList"))
				setBranchList(jsSrc.getString("BranchList"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setBranchList(String src) {

		branchList = new ArrayList<BranchList>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			BranchList item;
			for (int i = 0; i < count; i++) {
				item = new BranchList();
				item.parseByJson(jarrList.getJSONObject(i));
				branchList.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void setPromotionPictureURL(String promotionPictureURL) {
		this.promotionPictureURL = promotionPictureURL;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public void setType(int type) {
		this.type = type;
	}

	public void setEndDate(String endDate) {
			this.endDate = endDate;
	}

	public void setStartDate(String startDate) {
			this.startDate = startDate;
	}

	public void setPromotionCode(String promotionCode) {
		this.promotionCode = promotionCode;
	}

	public ArrayList<BranchList> getBranchList() {
		return branchList;
	}

	public String getPromotionPictureURL() {
		return promotionPictureURL;
	}

	public String getDescription() {
		return description;
	}

	public String getTitle() {
		return title;
	}

	public int getType() {
		return type;
	}

	public String getEndDate() {
		return endDate;
	}

	public String getStartDate() {
		return startDate;
	}

	public String getPromotionCode() {
		return promotionCode;
	}

	public class BranchList {
		private int    branchID;
		private String branchName;

		public boolean parseByJson(JSONObject src) {
			try {
				JSONObject jsSrc = src;
				if (jsSrc.has("BranchID"))
					setBranchID(jsSrc.getInt("BranchID"));
				if (jsSrc.has("BranchName"))
					setBranchName(jsSrc.getString("BranchName"));

			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return false;
			}
			return true;
		}

		public void setBranchName(String branchName) {
			this.branchName = branchName;
		}
		public int getBranchID() {
			return branchID;
		}

		public void setBranchID(int branchID) {
			this.branchID = branchID;
		}

		public String getBranchName() {
			return branchName;
		}
	}

}
