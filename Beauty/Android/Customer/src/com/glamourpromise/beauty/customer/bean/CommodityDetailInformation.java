package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
/*
 * 商品详情 继承于ProductInfo
 * */
public class CommodityDetailInformation extends ProductInfo{
	private String describe;//商品描述
	private String specification;//商品规格
	private String stockQuantity;//商品库存
	private String stockCalcType;
	private int imageCount=0;
	private ArrayList<String> commodityImageURLList;
	private ArrayList<HashMap<String, String>> productEnalbeInfoMap;

	public CommodityDetailInformation() {
		describe = "";
		specification = "";
		stockQuantity = "-1";
		stockCalcType = "0";
		commodityImageURLList = new ArrayList<String>();
		productEnalbeInfoMap = new ArrayList<HashMap<String,String>>();
	}
	
	public void parseByJson(String data){
		try {
			JSONObject resultJson = new JSONObject(data);
			if (resultJson.has("CommodityCode")) {
				setCode(resultJson.getString("CommodityCode"));
			}
			if (resultJson.has("CommodityName")) {
				setName(resultJson.getString("CommodityName"));
			}
			if (resultJson.has("Describe")) {
				setDescribe(resultJson.getString("Describe"));
			}
			if (resultJson.has("PromotionPrice")) {
				setDiscountPrice(resultJson.getString("PromotionPrice"));
			}
			if (resultJson.has("Specification")) {
				setSpecification(resultJson.getString("Specification"));
			}
			if (resultJson.has("StockQuantity")) {
				setStockQuantity(resultJson.getString("StockQuantity"));
			}
			if (resultJson.has("UnitPrice")) {
				setUnitPrice(resultJson.getString("UnitPrice"));
			}
			if (resultJson.has("UnitPrice")) {
				setUnitPrice(resultJson.getString("UnitPrice"));
			}
			if (resultJson.has("MarketingPolicy")) {
				setMarketingPolicy(resultJson.getInt("MarketingPolicy"));
			}
			if (resultJson.has("StockCalcType")) {
				setStockCalcType(resultJson.getString("StockCalcType"));
			}
			if(resultJson.has("FavoriteID") && !resultJson.isNull("FavoriteID")){
				setmFavoriteID(resultJson.getString("FavoriteID"));
			}
			HashMap<String, String> productEnalbeInfoMap;
			if(resultJson.has("ProductEnalbeInfo")){
				JSONArray enalbeArray = resultJson.getJSONArray("ProductEnalbeInfo");
				JSONObject tmp;
				for(int j = 0; j < enalbeArray.length(); j++){
					productEnalbeInfoMap = new HashMap<String, String>();
					tmp = enalbeArray.getJSONObject(j);
					if(tmp.has("BranchID")){
						productEnalbeInfoMap.put("BranchID", tmp.getString("BranchID"));
					}
					if(tmp.has("BranchName")){
						productEnalbeInfoMap.put("BranchName", tmp.getString("BranchName"));
					}
					if(tmp.has("Quantity")){
						productEnalbeInfoMap.put("Quantity", tmp.getString("Quantity"));
					}
					if(tmp.has("StockCalcType")){
						productEnalbeInfoMap.put("StockCalcType", tmp.getString("StockCalcType"));
					}
					addProductEnalbeInfoMap(productEnalbeInfoMap);
				}
				
			}
			ArrayList<String> imageURLList = new ArrayList<String>();
			if (resultJson.has("ImageCount")) {
				int count = resultJson.getInt("ImageCount");
				setImageCount(count);
				if (count > 0) {
					JSONArray commodityImageObject = resultJson.getJSONArray("CommodityImage");
					for (int i = 0; i < commodityImageObject.length(); i++) {
						imageURLList.add(i,commodityImageObject.getString(i));
					}
					setCommodityImageURLList(imageURLList);
				}
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public String getDescribe() {
		return describe;
	}

	public void setDescribe(String describe) {
		this.describe = describe;
	}

	public String getSpecification() {
		return specification;
	}

	public void setSpecification(String specification) {
		this.specification = specification;
	}

	public String getStockQuantity() {
		return stockQuantity;
	}

	public void setStockQuantity(String stockQuantity) {
		this.stockQuantity = stockQuantity;
	}
	
	public int getImageCount() {
		return imageCount;
	}

	public void setImageCount(int imageCount) {
		this.imageCount = imageCount;
	}

	public ArrayList<String> getCommodityImageURLList() {
		return commodityImageURLList;
	}

	public void setCommodityImageURLList(ArrayList<String> commodityImageURLList) {
		this.commodityImageURLList = commodityImageURLList;
	}

	public String getStockCalcType() {
		return stockCalcType;
	}

	public void setStockCalcType(String stockCalcType) {
		this.stockCalcType = stockCalcType;
	}

	public ArrayList<HashMap<String, String>> getProductEnalbeInfoMap() {
		return productEnalbeInfoMap;
	}

	public void addProductEnalbeInfoMap(HashMap<String, String> productEnalbeInfoMap) {
		this.productEnalbeInfoMap.add(productEnalbeInfoMap);
	}
	
}
