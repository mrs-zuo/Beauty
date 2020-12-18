package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;

public class CommodityInformation extends ProductInfo {
	private boolean isNew;
	private boolean isRecommended;
	private String  stockQuantity;
	private String  specification="";
	private String  searchField;
	public CommodityInformation()
	{	
	}
	public static ArrayList<CommodityInformation> parseListByJson(String src){
		ArrayList<CommodityInformation> list = new ArrayList<CommodityInformation>();
		try {
			JSONArray jarrList =new JSONObject(src).getJSONArray("ProductList");
			int count = jarrList.length();
			CommodityInformation item;
			for(int i = 0; i < count; i++){
				item = new CommodityInformation();
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
			if(jsSrc.has("ProductCode")){
				setCode(jsSrc.getString("ProductCode"));
			}
			if (jsSrc.has("ProductID")) {
				setID(jsSrc.getInt("ProductID"));
			}
			if (jsSrc.has("ProductName")) {
				setName(jsSrc.getString("ProductName"));
			}
			if (jsSrc.has("MarketingPolicy")) {
				setMarketingPolicy(jsSrc.getInt("MarketingPolicy"));
			}
			if (jsSrc.has("UnitPrice")) {
				setUnitPrice(jsSrc.getString("UnitPrice"));
			}
			if (jsSrc.has("PromotionPrice")) {
				setDiscountPrice(jsSrc.getString("PromotionPrice"));
			}
			if (jsSrc.has("ThumbnailURL")) {
				setThumbnail(jsSrc.getString("ThumbnailURL"));
			}
			if (jsSrc.has("SearchField")) {
				setSearchField(jsSrc.getString("SearchField"));
			}
			if (jsSrc.has("Specification")) {
				setSpecification(jsSrc.getString("Specification"));
			}
			if (jsSrc.has("New")) {
				setNew(jsSrc.getBoolean("New"));
			}
			if (jsSrc.has("Recommended")) {
				setRecommended(jsSrc.getBoolean("Recommended"));
			}
			
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	
	public boolean isNew() {
		return isNew;
	}
	public void setNew(boolean isNew) {
		this.isNew = isNew;
	}
	public boolean isRecommended() {
		return isRecommended;
	}
	public void setRecommended(boolean isRecommended) {
		this.isRecommended = isRecommended;
	}
	public String getStockQuantity() {
		return stockQuantity;
	}
	public void setStockQuantity(String stockQuantity) {
		this.stockQuantity = stockQuantity;
	}
	public String getSpecification() {
		return specification;
	}

	public void setSpecification(String specification) {
		if(!specification.equals("null"))
			this.specification = specification;
	}

	public String getSearchField() {
		return searchField;
	}

	@SuppressLint("DefaultLocale")
	public void setSearchField(String searchField) {
		if(!searchField.equals(""))
			this.searchField = searchField.toLowerCase();
	}
}
