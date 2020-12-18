package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PhotoAlbumListInformation {

	private String imageURL;
	private String time;

	public PhotoAlbumListInformation() {
		imageURL = "";
	}
	
	public static ArrayList<PhotoAlbumListInformation> parseListByJson(String src){
		ArrayList<PhotoAlbumListInformation> list = new ArrayList<PhotoAlbumListInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			PhotoAlbumListInformation item;
			for(int i = 0; i < count; i++){
				item = new PhotoAlbumListInformation();
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
			if(jsSrc.has("ImageURL")){
				setImageURL(jsSrc.getString("ImageURL"));
			}
			if (jsSrc.has("CreateTime")) {
				setTime(jsSrc.getString("CreateTime"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getImageURL() {
		return imageURL;
	}

	public void setImageURL(String imageURL) {
		if(!imageURL.equals("null"))
			this.imageURL = imageURL;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}
}
