package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Parcel;
import android.os.Parcelable;

public class TreatmentInformation implements Serializable, Parcelable {
	private static final long serialVersionUID = 1L;
	private String mTreatmentCode="";
	private String treatmentID;
	private String time;
	private String scheduleID;
	private String imageCount;
	private int    isComplete;
	private String remark;
	private String executorID;
	private String executorName="";
	private boolean isReviewed;
	private boolean isRemarked;
	private boolean isUploadedImage;
	private String  subServiceName="";
	public TreatmentInformation() {
		remark = "";
		time = "";
	}
	public TreatmentInformation(Parcel source) {
		mTreatmentCode = source.readString();
		treatmentID = source.readString();
		time = source.readString();
		scheduleID = source.readString();
		imageCount = source.readString();
		isComplete = source.readInt();
		remark = source.readString();
		executorID = source.readString();
		executorName = source.readString();
		subServiceName = source.readString();
	}
	public static ArrayList<TreatmentInformation> parseListByJson(String src){
		ArrayList<TreatmentInformation> list = new ArrayList<TreatmentInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			TreatmentInformation item;
			for(int i = 0; i < count; i++){
				item = new TreatmentInformation();
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
			String subServiceName = "";
			if (jsSrc.has("TreatmentCode")){
				setTreatmentCode(jsSrc.getString("TreatmentCode"));
			}
			if (jsSrc.has("SubServiceName"))
				subServiceName = jsSrc.getString("SubServiceName");
			setSubServiceName(subServiceName);
			int executorID = 0;
			if (jsSrc.has("ExecutorID"))
				executorID = jsSrc.getInt("ExecutorID");
			setExecutorID(String.valueOf(executorID));
			String executorName = "";
			if (jsSrc.has("ExecutorName"))
				executorName = jsSrc.getString("ExecutorName");
			setExecutorName(executorName);
			boolean isUploadedImage = false;
			if (jsSrc.has("IsUploadedImage"))
				isUploadedImage = jsSrc.getBoolean("IsUploadedImage");
			setUploadedImage(isUploadedImage);
			int treatmentID = 0;
			if (jsSrc.has("TreatmentID"))
				treatmentID = jsSrc.getInt("TreatmentID");
			setTreatmentID(String.valueOf(treatmentID));
			String time = "";
			if (jsSrc.has("Time"))
				time = jsSrc.getString("Time");
			setTime(time);
			int scheduleID = 0;
			if (jsSrc.has("ScheduleID"))
				scheduleID = jsSrc.getInt("ScheduleID");
			setScheduleID(String.valueOf(scheduleID));
			int isCompleted = 0;
			if (jsSrc.has("Status"))
				isCompleted = jsSrc.getInt("Status");
			setIsComplete(isCompleted);
			boolean isRemarked = false;
			if (jsSrc.has("IsRemarked"))
				isRemarked = jsSrc.getBoolean("IsRemarked");
			setRemarked(isRemarked);
			boolean isReviewed = false;
			if (jsSrc.has("IsReviewed"))
				isReviewed = jsSrc.getBoolean("IsReviewed");
			setReviewed(isReviewed);
			if (jsSrc.has("Remark")) {
				setRemark(jsSrc.getString("Remark"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	
	public String getTreatmentCode() {
		return mTreatmentCode;
	}

	public void setTreatmentCode(String treatmentCode) {
		mTreatmentCode = treatmentCode;
	}

	public void setTreatmentID(String treatmentID) {
		this.treatmentID = treatmentID;
	}

	public String getTreatmentID() {
		return this.treatmentID;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public String getTime() {
		return this.time;
	}

	public void setScheduleID(String scheduleID) {
		this.scheduleID = scheduleID;
	}

	public String getScheduleID() {
		return this.scheduleID;
	}

	public void setImageCount(String imageCount) {
		this.imageCount = imageCount;
	}

	public String getImageCount() {
		return this.imageCount;
	}
	
	public void setRemark(String remark){
		this.remark = remark;
	}
	
	public String getRemark(){
		return remark;
	}
	public void setExecutorID(String executorID) {
		this.executorID = executorID;
	}

	public String getExecutorID() {
		return executorID;
	}

	public void setExecutorName(String executorName) {
		this.executorName = executorName;
	}

	public String getExecutorName() {
		return executorName;
	}

	public int getIsComplete() {
		return isComplete;
	}

	public void setIsComplete(int isComplete) {
		this.isComplete = isComplete;
	}

	public boolean isReviewed() {
		return isReviewed;
	}

	public void setReviewed(boolean isReviewed) {
		this.isReviewed = isReviewed;
	}

	public boolean isRemarked() {
		return isRemarked;
	}

	public void setRemarked(boolean isRemarked) {
		this.isRemarked = isRemarked;
	}

	public boolean isUploadedImage() {
		return isUploadedImage;
	}

	public void setUploadedImage(boolean isUploadedImage) {
		this.isUploadedImage = isUploadedImage;
	}

	public String getSubServiceName() {
		return subServiceName;
	}

	public void setSubServiceName(String subServiceName) {
		this.subServiceName = subServiceName;
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeString(mTreatmentCode);
		dest.writeString(treatmentID);
		dest.writeString(time);
		dest.writeString(scheduleID);
		dest.writeString(imageCount);
		dest.writeInt(isComplete);
		dest.writeString(remark);
		dest.writeString(executorID);
		dest.writeString(executorName);
		dest.writeString(subServiceName);
	}
	//实例化静态内部对象CREATOR实现接口Parcelable.Creator  
    public static final Parcelable.Creator<TreatmentInformation> CREATOR = new Creator<TreatmentInformation>() {  
          
        @Override  
        public TreatmentInformation[] newArray(int size) {  
            return new TreatmentInformation[size];  
        }  
          
        //将Parcel对象反序列化为ParcelableDate  
        @Override  
        public TreatmentInformation createFromParcel(Parcel source) {  
            return new TreatmentInformation(source);  
        }  
    };  

}
