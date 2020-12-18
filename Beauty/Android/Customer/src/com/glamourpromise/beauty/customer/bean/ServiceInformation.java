package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
public class ServiceInformation extends ProductInfo{
	private String serviceDescribe;//服务简介
	private int    serviceCourseFrequency;//服务次数
	private int    serviceSpendTime;//服务时间
	private int    serviceIsChecked;//0:未被选中  1:选中
	private boolean hasSubService;//是否有子服务
	private int imageCount=0;
	private boolean haveExpiration;//是否有服务有效期
	private int expirationDate;//过期天数  0：当天有效  非0则显示该数字
	private List<SubServiceInformation> subServiceList;//子服务集合
	private ArrayList<HashMap<String, String>> productEnalbeInfoMap;
	private String searchField;	
	private int    productType;
	public ServiceInformation(){
		serviceCourseFrequency = 0;
		serviceSpendTime = 0;
		productEnalbeInfoMap = new ArrayList<HashMap<String,String>>();
	}
	
	public static ArrayList<ServiceInformation> parseListByJson(String src){
		ArrayList<ServiceInformation> list = new ArrayList<ServiceInformation>();
		try {
			JSONArray jarrList =new JSONObject(src).getJSONArray("ProductList");
			int count = jarrList.length();
			ServiceInformation item;
			for(int i = 0; i < count; i++){
				item = new ServiceInformation();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
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
	public static ArrayList<ServiceInformation> parseListByJsonNoNode(String src){
		ArrayList<ServiceInformation> list = new ArrayList<ServiceInformation>();
		try {
			JSONArray jarrList =new JSONArray(src);
			int count = jarrList.length();
			ServiceInformation item;
			for(int i = 0; i < count; i++){
				item = new ServiceInformation();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return list;
	}
	@SuppressLint("NewApi")
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
			if (jsSrc.has("ProductType")) {
				setProductType(jsSrc.getInt("ProductType"));
			}
			if (jsSrc.has("ServiceName")) {
				setName(jsSrc.getString("ServiceName"));
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
			if (jsSrc.has("SearchField")) {
				setSearchField(jsSrc.getString("SearchField"));
			}
			if (jsSrc.has("Describe")) {
				setServiceDescribe(jsSrc.getString("Describe"));
			}
			if (jsSrc.has("ThumbnailURL")) {
				setThumbnail(jsSrc.getString("ThumbnailURL"));
			}
			if(jsSrc.has("SpendTime")){
				setServiceSpendTime(jsSrc.getInt("SpendTime"));
			}
			if(jsSrc.has("HaveExpiration")){
				setHaveExpiration(jsSrc.getBoolean("HaveExpiration"));
			}
			if(jsSrc.has("ExpirationDate")){
				setExpirationDate(jsSrc.getInt("ExpirationDate"));
			}
			if(jsSrc.has("CourseFrequency")){
				setServiceCourseFrequency(jsSrc.getInt("CourseFrequency"));
			}
			if(jsSrc.has("FavoriteID") && !jsSrc.isNull("FavoriteID")){
				setmFavoriteID(jsSrc.getString("FavoriteID"));
			}
			if (jsSrc.has("HasSubServices"))
				hasSubService = jsSrc.getBoolean("HasSubServices");
			if (jsSrc.has("SubServices")&& !jsSrc.getString("SubServices").trim().toLowerCase().equals("null") && !jsSrc.getString("SubServices").trim().equals("")) {
				JSONArray subServiceJsonArray = jsSrc.getJSONArray("SubServices");
				subServiceList = new ArrayList<SubServiceInformation>();
				for (int i = 0; i < subServiceJsonArray
						.length(); i++) {
					JSONObject subServiceObject = subServiceJsonArray.getJSONObject(i);
					SubServiceInformation subService = new SubServiceInformation();
					String subServiceName = "";
					if (subServiceObject.has("SubServiceName"))
						subServiceName = subServiceObject.getString("SubServiceName");
					int subServiceSpendTime = 0;
					if (subServiceObject.has("SpendTime"))
						subServiceSpendTime = subServiceObject.getInt("SpendTime");
					subService.setSubServiceName(subServiceName);
					subService.setSubServiceSpendTime(subServiceSpendTime);
					subServiceList.add(subService);
				}
			}
			StringBuffer serviceImageUrl = new StringBuffer();
			if (jsSrc.has("ServiceImage") && !jsSrc.getString("ServiceImage").trim().toLowerCase().equals("null") && !jsSrc.getString("ServiceImage").trim().equals("")) {
				JSONArray serviceImageJson = jsSrc.getJSONArray("ServiceImage");
				imageCount = serviceImageJson.length();
				for (int j = 0; j < serviceImageJson.length(); j++) {
					serviceImageUrl.append(serviceImageJson.get(j) + ",");
				}
				setThumbnail(serviceImageUrl.toString());
			}
			
			if(jsSrc.has("ProductEnalbeInfo")){
				JSONArray infos = new JSONArray(jsSrc.getString("ProductEnalbeInfo"));
				JSONObject item;
				HashMap<String, String> infoMap;
				int infoCount = infos.length();
				for(int i = 0; i < infoCount; i++){
					item = infos.getJSONObject(i);
					infoMap = new HashMap<String, String>();
					if(item.has("BranchName")){
						infoMap.put("BranchName", item.getString("BranchName"));
					}
					if(item.has("BranchID")){
						infoMap.put("BranchID", item.getString("BranchID"));
					}
					productEnalbeInfoMap.add(infoMap);
				}
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public String getServiceDescribe() {
		return serviceDescribe;
	}
	public int getServiceCourseFrequency() {
		return serviceCourseFrequency;
	}
	public int getServiceSpendTime() {
		return serviceSpendTime;
	}
	public void setServiceDescribe(String serviceDescribe) {
		this.serviceDescribe = serviceDescribe;
	}
	public void setServiceCourseFrequency(int serviceCourseFrequency) {
		this.serviceCourseFrequency = serviceCourseFrequency;
	}
	public void setServiceSpendTime(int serviceSpendTime) {
		this.serviceSpendTime = serviceSpendTime;
	}
	public String getUnitPrice() {
		return unitPrice;
	}
	
	public int getImageCount() {
		return imageCount;
	}

	public void setImageCount(int imageCount) {
		this.imageCount = imageCount;
	}

	public int getServiceIsChecked() {
		return serviceIsChecked;
	}
	public void setServiceIsChecked(int serviceIsChecked) {
		this.serviceIsChecked = serviceIsChecked;
	}


	public boolean isHasSubService() {
		return hasSubService;
	}

	public void setHasSubService(boolean hasSubService) {
		this.hasSubService = hasSubService;
	}

	public List<SubServiceInformation> getSubServiceList() {
		return subServiceList;
	}

	public void setSubServiceList(List<SubServiceInformation> subServiceList) {
		this.subServiceList = subServiceList;
	}
	
	public ArrayList<HashMap<String, String>> getProductEnalbeInfoMap() {
		return productEnalbeInfoMap;
	}
	public void addProductEnalbeInfoMap(HashMap<String, String> productEnalbeInfoMap) {
		this.productEnalbeInfoMap.add(productEnalbeInfoMap);
	}
	public String getSearchField() {
		return searchField;
	}
	public int getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(int expirationDate) {
		this.expirationDate = expirationDate;
	}
	public boolean isHaveExpiration() {
		return haveExpiration;
	}
	public void setHaveExpiration(boolean haveExpiration) {
		this.haveExpiration = haveExpiration;
	}

	public int getProductType() {
		return productType;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}

	@SuppressLint("DefaultLocale")
	public void setSearchField(String searchField) {
		if(!searchField.equals(""))
			this.searchField = searchField.toLowerCase();
	}
}
