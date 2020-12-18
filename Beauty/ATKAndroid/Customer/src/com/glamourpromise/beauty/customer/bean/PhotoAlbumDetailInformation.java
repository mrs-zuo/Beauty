package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PhotoAlbumDetailInformation {

	String imageID;
	String thumbnailImageURL="";
	String originalImageURL="";
	String name="";

	public PhotoAlbumDetailInformation() {

	}
	
	public static ArrayList<PhotoAlbumDetailInformation> parseListByJson(String src){
		ArrayList<PhotoAlbumDetailInformation> list = new ArrayList<PhotoAlbumDetailInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			PhotoAlbumDetailInformation item;
			for(int i = 0; i < count; i++){
				item = new PhotoAlbumDetailInformation();
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
			if(jsSrc.has("ThumbnailURL")){
				setThumbnailImageURL(jsSrc.getString("ThumbnailURL"));
			}
			if (jsSrc.has("OriginalImageURL")) {
				setOriginalImageURL(jsSrc.getString("OriginalImageURL"));
			}
			if (jsSrc.has("ImageID")) {
				setImageID(jsSrc.getString("ImageID"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getImageID() {
		return this.imageID;
	}

	public void setImageID(String imageID) {
		this.imageID = imageID;
	}

	public String getThumbnailImageURL() {
		return this.thumbnailImageURL;
	}

	public void setThumbnailImageURL(String thumbnailImageURL) {
		if(thumbnailImageURL == null || thumbnailImageURL.equals("null"))
			this.thumbnailImageURL = "";
		else
			this.thumbnailImageURL = thumbnailImageURL;
	}

	public String getOriginalImageURL() {
		return this.originalImageURL;
	}

	public void setOriginalImageURL(String originalImageURL) {
		if(originalImageURL == null || originalImageURL.equals("null"))
			this.originalImageURL = "";
		else{
			this.originalImageURL = originalImageURL;
			String[] tmps = originalImageURL.split("/");
			name = tmps[tmps.length-1];
			tmps = name.split("&");
			name = tmps[0];
		}
	}
	
	public String getName(){
		return name;
	}
}
