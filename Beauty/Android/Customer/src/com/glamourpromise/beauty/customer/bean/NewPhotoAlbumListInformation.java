package com.glamourpromise.beauty.customer.bean;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class NewPhotoAlbumListInformation {
	private String serviceCode;
	private String serviceName;
	private List<String> imageURLs;

	public NewPhotoAlbumListInformation() {
		
	}
	
	public static ArrayList<NewPhotoAlbumListInformation> parseListByJson(String src){
		ArrayList<NewPhotoAlbumListInformation> list = new ArrayList<NewPhotoAlbumListInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			NewPhotoAlbumListInformation item;
			for(int i = 0; i < count; i++){
				item = new NewPhotoAlbumListInformation();
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
			if(jsSrc.has("ServiceName")){
				setServiceName(jsSrc.getString("ServiceName"));
			}
			if (jsSrc.has("ServiceCode")) {
				setServiceCode(jsSrc.getString("ServiceCode"));
			}
			if(jsSrc.has("ImageURL") && !jsSrc.isNull("ImageURL")){
				JSONArray imageArray=jsSrc.getJSONArray("ImageURL");
				List<String> imageURLList=new ArrayList<String>();
				for(int i=0;i<imageArray.length();i++){
					String imageUrl=imageArray.getString(i);
					imageURLList.add(imageUrl);
				}
				setImageURLs(imageURLList);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getServiceCode() {
		return serviceCode;
	}

	public void setServiceCode(String serviceCode) {
		this.serviceCode = serviceCode;
	}

	public String getServiceName() {
		return serviceName;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public List<String> getImageURLs() {
		return imageURLs;
	}

	public void setImageURLs(List<String> imageURLs) {
		this.imageURLs = imageURLs;
	}

}
