package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Parcel;
import android.os.Parcelable;

public class CourseInformation implements Parcelable{

	private String courseID;
	private String executorID;
	private String executorName;
	private ArrayList<Group> mArrLiGroup;

	public CourseInformation() {
		
	}
	public CourseInformation(Parcel source) {
		courseID = source.readString();
		executorID = source.readString();
		executorName = source.readString();
		source.readList(mArrLiGroup, null);;
	}
	
	public static ArrayList<CourseInformation> parseListByJson(String src){
		ArrayList<CourseInformation> list = new ArrayList<CourseInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CourseInformation item;
			for(int i = 0; i < count; i++){
				item = new CourseInformation();
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
			if (jsSrc.has("CourseID"))
				setCourseID(jsSrc.getString("CourseID"));
			if (jsSrc.has("GroupList")){
				ArrayList<Group> list = Group.parseListByJson(jsSrc.getString("GroupList"));
				setArrLiGroup(list);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setCourseID(String courseID) {
		this.courseID = courseID;
	}

	public String getCourseID() {
		return this.courseID;
	}

	public void setExecutorID(String executorID) {
		this.executorID = executorID;
	}

	public String getExecutorID() {
		return this.executorID;
	}

	public void setExecutorName(String executorName) {
		this.executorName = executorName;
	}

	public String getExecutorName() {
		return this.executorName;
	}
	
//	public void setTreatmentList(List<TreatmentInformation> treatmentList) {
//		this.treatmentList = treatmentList;
//	}
//
//	public List<TreatmentInformation> getTreatmentList() {
//		return this.treatmentList;
//	}
	
	public ArrayList<Group> getArrLiGroup() {
		return mArrLiGroup;
	}

	public void setArrLiGroup(ArrayList<Group> arrLiGroup) {
		mArrLiGroup = arrLiGroup;
	}

	public static class Group implements Parcelable{
		private int mGroupNo;
		private ArrayList<TreatmentInformation> mArrLiTreatment;
		public Group(){
			
		}
		public Group(Parcel source) {
			mGroupNo = source.readInt();
			source.readList(mArrLiTreatment, null);;
		}
		
		public static ArrayList<Group> parseListByJson(String src){
			ArrayList<Group> list = new ArrayList<Group>();
			try {
				JSONArray jarrList = new JSONArray(src);
				int count = jarrList.length();
				Group item;
				for(int i = 0; i < count; i++){
					item = new Group();
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
				int subServiceName = 0;
				if (jsSrc.has("GroupNo"))
					subServiceName = jsSrc.getInt("GroupNo");
				setGroupNo(subServiceName);
				if (jsSrc.has("TreatmentList")){
					ArrayList<TreatmentInformation> list = TreatmentInformation.parseListByJson(jsSrc.getString("TreatmentList"));
					setArrLiTreatment(list);
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return false;
			}
			return true;
		}
		
		public int getGroupNo() {
			return mGroupNo;
		}
		public void setGroupNo(int groupNo) {
			mGroupNo = groupNo;
		}
		public ArrayList<TreatmentInformation> getArrLiTreatment() {
			return mArrLiTreatment;
		}
		public void setArrLiTreatment(ArrayList<TreatmentInformation> arrLiTreatment) {
			mArrLiTreatment = arrLiTreatment;
		}
		@Override
		public int describeContents() {
			// TODO Auto-generated method stub
			return 0;
		}
		@Override
		public void writeToParcel(Parcel dest, int flags) {
			// TODO Auto-generated method stub
			dest.writeInt(mGroupNo);
			dest.writeTypedList(mArrLiTreatment);
		}
		
		//实例化静态内部对象CREATOR实现接口Parcelable.Creator  
	    public static final Parcelable.Creator<Group> CREATOR = new Creator<Group>() {  
	          
	        @Override  
	        public Group[] newArray(int size) {  
	            return new Group[size];  
	        }  
	          
	        //将Parcel对象反序列化为ParcelableDate  
	        @Override  
	        public Group createFromParcel(Parcel source) {  
	            return new Group(source);  
	        }  
	    };  
		
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeString(courseID);
		dest.writeString(executorID);
		dest.writeString(executorName);
		dest.writeTypedList(mArrLiGroup);
	}
	//实例化静态内部对象CREATOR实现接口Parcelable.Creator  
    public static final Parcelable.Creator<CourseInformation> CREATOR = new Creator<CourseInformation>() {  
          
        @Override  
        public CourseInformation[] newArray(int size) {  
            return new CourseInformation[size];  
        }  
          
        //将Parcel对象反序列化为ParcelableDate  
        @Override  
        public CourseInformation createFromParcel(Parcel source) {  
            return new CourseInformation(source);  
        }  
    };  

}
