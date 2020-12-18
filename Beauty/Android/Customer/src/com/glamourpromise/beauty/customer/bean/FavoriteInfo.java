package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class FavoriteInfo implements Serializable{
	private static final long serialVersionUID = 1L;
	private  String favoriteID;//收藏ID
	private  long   productCode;//服务/商品Code
	private  int    productType;//服务/商品类型
	private  String productName;//服务/商品名称
	private  String specification;//商品规格
	private  String imageURL;//服务/商品图片路径
	private  String unitPrice;//服务/商品单价
	public FavoriteInfo() {
		super();
		specification="";
	}
	public String getFavoriteID() {
		return favoriteID;
	}
	public void setFavoriteID(String favoriteID) {
		this.favoriteID = favoriteID;
	}
	public long getProductCode() {
		return productCode;
	}
	public void setProductCode(long productCode) {
		this.productCode = productCode;
	}
	public int getProductType() {
		return productType;
	}
	public void setProductType(int productType) {
		this.productType = productType;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}
	public String getSpecification() {
		return specification;
	}
	public void setSpecification(String specification) {
		this.specification = specification;
	}
	public String getImageURL() {
		return imageURL;
	}
	public void setImageURL(String imageURL) {
		this.imageURL = imageURL;
	}
	public String getUnitPrice() {
		return unitPrice;
	}
	public void setUnitPrice(String unitPrice) {
		this.unitPrice = unitPrice;
	}
	//解析收藏List
	public static ArrayList<FavoriteInfo> parseFavoriteListByJson(String stringJson){
		ArrayList<FavoriteInfo> favoriteList=new ArrayList<FavoriteInfo>();
		JSONArray favoriteJsonArray = null;
		try {
			favoriteJsonArray = new JSONArray(stringJson);
		} catch (JSONException e) {
		}
		try{
			if (favoriteJsonArray != null && favoriteJsonArray.length()>0) {
				for (int i = 0; i < favoriteJsonArray.length(); i++) {
					JSONObject favoriteJson = null;
					favoriteJson = (JSONObject) favoriteJsonArray.get(i);
					FavoriteInfo favoriteInfo=new FavoriteInfo();
					if (favoriteJson.has("UserFavoriteID")) {
						favoriteInfo.setFavoriteID(favoriteJson.getString("UserFavoriteID"));
					}
					if (favoriteJson.has("ProductCode")) {
						favoriteInfo.setProductCode(favoriteJson.getLong("ProductCode"));
					}
					if (favoriteJson.has("ProductType")) {
						favoriteInfo.setProductType(favoriteJson.getInt("ProductType"));
					}
					if (favoriteJson.has("ProductName")) {
						favoriteInfo.setProductName(favoriteJson.getString("ProductName"));
					}
					if (favoriteJson.has("Specification") && !favoriteJson.isNull("Specification")) {
						favoriteInfo.setSpecification(favoriteJson.getString("Specification"));
					}
					if (favoriteJson.has("ImgUrl")) {
						favoriteInfo.setImageURL(favoriteJson.getString("ImgUrl"));
					}
					if (favoriteJson.has("UnitPrice")) {
						favoriteInfo.setUnitPrice(favoriteJson.getString("UnitPrice"));
					}
					favoriteList.add(favoriteInfo);
				}
			}
		}catch(JSONException e){
			e.printStackTrace();
		}
		return favoriteList;
	}
}
