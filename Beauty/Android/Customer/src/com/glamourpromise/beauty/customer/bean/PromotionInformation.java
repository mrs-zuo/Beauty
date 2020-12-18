package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.ksoap2.serialization.PropertyInfo;
import org.ksoap2.serialization.SoapObject;

import com.glamourpromise.beauty.customer.util.DateUtil;

public class PromotionInformation {
	private String promotionType;
	private String promotionContent;
	private String promotionBranchInfo = "";
	private String promotionTime = "";
	private String promotionTitle = "";
	private String promotionCode;
	private String promotionImageURL="";
	public static ArrayList<PromotionInformation> parseListByJson(String src) {
		ArrayList<PromotionInformation> list = new ArrayList<PromotionInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			PromotionInformation item;
			for (int i = 0; i < count; i++) {
				item = new PromotionInformation();
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
			if(jsSrc.has("PromotionPictureURL"))
				setPromotionImageURL(jsSrc.getString("PromotionPictureURL"));
			if(jsSrc.has("PromotionContent"))
				setPromotionContent(jsSrc.getString("PromotionContent"));
			if (jsSrc.has("Title"))
				setPromotionTitle(jsSrc.getString("Title"));
			if (jsSrc.has("StartDate")) {
				setPromotionTime(DateUtil.getFormateDateByString(jsSrc.getString("StartDate"))+"至"+DateUtil.getFormateDateByString(jsSrc.getString("EndDate")));
			}
			if (jsSrc.has("Description"))
				setPromotionContent(jsSrc.getString("Description"));
			if (jsSrc.has("BranchList")) {
				JSONArray branchListArray = jsSrc.getJSONArray("BranchList");
				JSONObject branchObject;
				for (int j = 0; j < branchListArray.length(); j++) {
					branchObject = branchListArray.getJSONObject(j);
					if (j != 0) {
						setPromotionBranchInfo("，");
					}
					setPromotionBranchInfo(branchObject.getString("BranchName"));
				}
			}
			if(jsSrc.has("PromotionCode"))
				setPromotionCode(jsSrc.getString("PromotionCode"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setPromotionCode(String promotionCode) {
		this.promotionCode = promotionCode;
	}

	public String getPromotionCode(){
		return promotionCode;
	}
	public String getPromotionType() {
		return promotionType;
	}

	public void setPromotionType(String promotionType) {
		this.promotionType = promotionType;
	}

	public String getPromotionContent() {
		return promotionContent;
	}

	public void setPromotionContent(String promotionContent) {
			this.promotionContent = promotionContent;
	}

	public String getPromotionBranchInfo() {
		return promotionBranchInfo;
	}

	public void setPromotionBranchInfo(String promotionBranchInfo) {
		this.promotionBranchInfo += promotionBranchInfo;
	}

	public String getPromotionTime() {
		return promotionTime;
	}

	public void setPromotionTime(String promotionTime) {
		this.promotionTime=promotionTime;
	}

	public String getPromotionTitle() {
		return promotionTitle;
	}

	public void setPromotionTitle(String promotionTitle) {
		this.promotionTitle = promotionTitle;
	}
	public String getPromotionImageURL() {
		return promotionImageURL;
	}

	public void setPromotionImageURL(String promotionImageURL) {
		this.promotionImageURL = promotionImageURL;
	}

	public void setInfoBySoapObject(SoapObject contentSoapObject) {
		PropertyInfo propertyInfo = new PropertyInfo();
		String propertyName;
		String propertyValue;

		for (int i = 0; i < contentSoapObject.getPropertyCount(); i++) {
			contentSoapObject.getPropertyInfo(i, propertyInfo);
			propertyName = propertyInfo.getName();
			propertyValue = String.valueOf(propertyInfo.getValue());

			if (propertyName.equals("PromotionType")) {
				promotionType = propertyValue;
			} else if (propertyName.equals("PromotionPictureURL")) {
				promotionContent = propertyValue;
			} else if (propertyName.equals("PromotionContent")) {
				promotionContent = propertyValue;
			}
		}
	}
}
