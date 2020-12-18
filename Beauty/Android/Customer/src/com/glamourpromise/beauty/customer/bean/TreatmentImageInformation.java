package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Parcel;
import android.os.Parcelable;

public class TreatmentImageInformation implements Serializable, Parcelable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String treatmentImageID;
	private String treatmentImageURL;

	public TreatmentImageInformation() {

	}
	
	public static ArrayList<TreatmentImageInformation> parseListByJson(String src){
		ArrayList<TreatmentImageInformation> list = new ArrayList<TreatmentImageInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			TreatmentImageInformation item;
			for(int i = 0; i < count; i++){
				item = new TreatmentImageInformation();
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
			if(jsSrc.has("TreatmentImageID")){
				setTreatmentImageID(jsSrc.getString("TreatmentImageID"));
			}
			if (jsSrc.has("ThumbnailURL")) {
				setTreatmentImageURL(jsSrc.getString("ThumbnailURL"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getTreatmentImageID() {
		return treatmentImageID;
	}

	public String getTreatmentImageURL() {
		return treatmentImageURL;
	}

	public void setTreatmentImageID(String treatmentImageID) {
		this.treatmentImageID = treatmentImageID;
	}

	public void setTreatmentImageURL(String treatmentImageURL) {
		this.treatmentImageURL = treatmentImageURL;
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeString(treatmentImageID);
		dest.writeString(treatmentImageURL);
	}

	public static final Parcelable.Creator<TreatmentImageInformation> CREATOR = new Parcelable.Creator<TreatmentImageInformation>() {
		public TreatmentImageInformation createFromParcel(Parcel in) {
			return new TreatmentImageInformation(in);
		}

		public TreatmentImageInformation[] newArray(int size) {
			return new TreatmentImageInformation[size];
		}
	};

	private TreatmentImageInformation(Parcel in) {
		treatmentImageID = in.readString();
		treatmentImageURL = in.readString();
	}

}
