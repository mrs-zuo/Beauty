package com.glamourpromise.beauty.customer.bean;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ServicePhotoAlbum{
	private String serviceCode;
	private String serviceName;
	private List<TGPhotoAlbum> tgPhotolAlbumList;
	public ServicePhotoAlbum() {
		
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
			if(jsSrc.has("ServicePicList") && !jsSrc.isNull("ServicePicList")){
				JSONArray tgPhotoAlbumArray=jsSrc.getJSONArray("ServicePicList");
				List<TGPhotoAlbum> tgPhotoAlbumList=new ArrayList<TGPhotoAlbum>();
				for(int i=0;i<tgPhotoAlbumArray.length();i++){
					JSONObject tgPhotoAlbumJson=tgPhotoAlbumArray.getJSONObject(i);
					TGPhotoAlbum tgPhotoAlbum=new TGPhotoAlbum();
					if(tgPhotoAlbumJson.has("TGStartTime"))
						tgPhotoAlbum.setTgStartTime(tgPhotoAlbumJson.getString("TGStartTime"));
					if(tgPhotoAlbumJson.has("BranchID"))
						tgPhotoAlbum.setBranchID(tgPhotoAlbumJson.getInt("BranchID"));
					if(tgPhotoAlbumJson.has("BranchName"))
						tgPhotoAlbum.setBranchName(tgPhotoAlbumJson.getString("BranchName"));
					if(tgPhotoAlbumJson.has("Comments"))
						tgPhotoAlbum.setComments(tgPhotoAlbumJson.getString("Comments"));
					if(tgPhotoAlbumJson.has("GroupNo"))
						tgPhotoAlbum.setGroupNo(tgPhotoAlbumJson.getString("GroupNo"));
					if(tgPhotoAlbumJson.has("ImageURL") && !tgPhotoAlbumJson.isNull("ImageURL")){
						JSONArray imageArray=tgPhotoAlbumJson.getJSONArray("ImageURL");
						List<String> imageURLList=new ArrayList<String>();
						for(int j=0;j<imageArray.length();j++){
							String imageUrl=imageArray.getString(j);
							imageURLList.add(imageUrl);
						}
						tgPhotoAlbum.setImageURLs(imageURLList);
					}
					tgPhotoAlbumList.add(tgPhotoAlbum);
				}
				setTgPhotlAlbumList(tgPhotoAlbumList);
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			
		}
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

	public List<TGPhotoAlbum> getTgPhotolAlbumList() {
		return tgPhotolAlbumList;
	}

	public void setTgPhotlAlbumList(List<TGPhotoAlbum> tgPhotolAlbumList) {
		this.tgPhotolAlbumList = tgPhotolAlbumList;
	}
}
