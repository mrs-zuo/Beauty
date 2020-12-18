package com.glamourpromise.beauty.customer.bean;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
public class TGPhotoAlbum implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String serviceCode;
	private String serviceName;
	private String tgStartTime;
	private int    branchID;
	private String branchName;
	private String comments;
	private String groupNo;
	private List<String> imageURLs;
	private List<RecordImage> recordImageList;
	public String getTgStartTime() {
		return tgStartTime;
	}
	public void setTgStartTime(String tgStartTime) {
		this.tgStartTime = tgStartTime;
	}
	public int getBranchID() {
		return branchID;
	}
	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}
	public String getBranchName() {
		return branchName;
	}
	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}
	public String getComments() {
		return comments;
	}
	public void setComments(String comments) {
		this.comments = comments;
	}
	public String getGroupNo() {
		return groupNo;
	}
	public void setGroupNo(String groupNo) {
		this.groupNo = groupNo;
	}
	public List<String> getImageURLs() {
		return imageURLs;
	}
	public void setImageURLs(List<String> imageURLs) {
		this.imageURLs = imageURLs;
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
	public List<RecordImage> getRecordImageList() {
		return recordImageList;
	}
	public void setRecordImageList(List<RecordImage> recordImageList) {
		this.recordImageList = recordImageList;
	}
	
	public  void parseByJson(String src) {
		try {
			JSONObject jsSrc =new JSONObject(src);
			if(jsSrc.has("ServiceName")){
				setServiceName(jsSrc.getString("ServiceName"));
			}
			if (jsSrc.has("ServiceCode")) {
				setServiceCode(jsSrc.getString("ServiceCode"));
			}
			if(jsSrc.has("BranchID")){
				setBranchID(jsSrc.getInt("BranchID"));
			}	
			if(jsSrc.has("BranchName")){
				setBranchName(jsSrc.getString("BranchName"));
			}
			if(jsSrc.has("GroupNo")){
				setGroupNo(jsSrc.getString("GroupNo"));
			}
			if(jsSrc.has("TGStartTime"))
				setTgStartTime(jsSrc.getString("TGStartTime"));
			if(jsSrc.has("Comments"))
				setComments(jsSrc.getString("Comments"));
			List<RecordImage> recordImageList=new ArrayList<RecordImage>();
			if(jsSrc.has("TGPicList") && !jsSrc.isNull("TGPicList")){
				JSONArray recordImageArray=jsSrc.getJSONArray("TGPicList");
				
				for(int i=0;i<recordImageArray.length();i++){
					JSONObject  recordImageJson=recordImageArray.getJSONObject(i);
					RecordImage recordImage=new RecordImage();
					if(recordImageJson.has("RecordImgID"))
						recordImage.setRecordImageID(recordImageJson.getString("RecordImgID"));
					if(recordImageJson.has("ImageTag") && !recordImageJson.isNull("ImageTag"))
						recordImage.setRecordImageTag(recordImageJson.getString("ImageTag"));
					if(recordImageJson.has("ImageURL"))
						recordImage.setRecordImageUrl(recordImageJson.getString("ImageURL"));
					recordImageList.add(recordImage);
				}
			}
			RecordImage defaultRecordImage=new RecordImage();
			defaultRecordImage.setRecordImageID("");
			defaultRecordImage.setRecordImageTag("");
			recordImageList.add(defaultRecordImage);
			setRecordImageList(recordImageList);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
