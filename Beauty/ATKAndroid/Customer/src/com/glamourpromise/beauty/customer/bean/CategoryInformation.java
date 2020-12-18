package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CategoryInformation 
{
	private String totalCommodityCount="";
	private String parentCategoryName="";
	private int parentCategoryID;
	private String CategoryID="0";
	private String CategoryName="";
	private String CommodityCount="0";
	private String NextCategoryCount="0";
	
	public CategoryInformation ()
	{
		parentCategoryID = 0;
	}
	
	public static ArrayList<CategoryInformation> parseListByJson(String src){
		ArrayList<CategoryInformation> list = new ArrayList<CategoryInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CategoryInformation item;
			for(int i = 0; i < count; i++){
				item = new CategoryInformation();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	
	public boolean parseByJson(String src){
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
			if(jsSrc.has("NextCategoryCount")){
				setNextCategoryCount(jsSrc.getString("NextCategoryCount"));
			}
			if (jsSrc.has("CategoryName")) {
				setCategoryName(jsSrc.getString("CategoryName"));
			}
			if (jsSrc.has("CategoryID")) {
				setCategoryID(jsSrc.getString("CategoryID"));
			}
			if (jsSrc.has("ProductCount")) {
				setCommodityCount(jsSrc.getString("ProductCount"));
			}
		
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
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
		return CategoryID;
	}
	public void setCategoryID(String CategoryID) {
		this.CategoryID = CategoryID;
	}
	
	public String getCategoryName() {
		return CategoryName;
	}
	public void setCategoryName(String CategoryName) {
		if(!CategoryName.equals("null"))
			this.CategoryName = CategoryName;
	}
	
	public String getCommodityCount() {
		return CommodityCount;
	}
	public void setCommodityCount(String CommodityCount) {
		this.CommodityCount = CommodityCount;
	}
	
	public String getNextCategoryCount() {
		return NextCategoryCount;
	}
	public void setNextCategoryCount(String NextCategoryCount) {
		this.NextCategoryCount = NextCategoryCount;
	}
}
