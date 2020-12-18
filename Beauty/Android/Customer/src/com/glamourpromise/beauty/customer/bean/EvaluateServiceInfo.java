package com.glamourpromise.beauty.customer.bean;
import java.io.Serializable;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
public class EvaluateServiceInfo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int    orderObejctID;
	private String serviceName;
	private String tgEndTime;
	private int tgFinishedCount;
	private int    tgTotalCount;
	private int   satisfaction;
	private String    responsiblePersonName;
	private String  comment;
	private long groupNo;
	
	private ArrayList<EvaluateServiceListTMInfo> listTM;
	
	public ArrayList<EvaluateServiceListTMInfo> getListTM() {
		return listTM;
	}
	
	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public void setListTM(ArrayList<EvaluateServiceListTMInfo> listTM) {
		this.listTM = listTM;
	}

	public int getSatisfaction() {
		return satisfaction;
	}

	public void setSatisfaction(int satisfaction) {
		this.satisfaction = satisfaction;
	}

	public static ArrayList<EvaluateServiceInfo> parseListByJson(String stringJson){
		ArrayList<EvaluateServiceInfo> evaluateServiceList=new ArrayList<EvaluateServiceInfo>();
		JSONArray evaluateServiceArray = null;
		try {
			evaluateServiceArray = new JSONArray(stringJson);
		} catch (JSONException e) {
		}
		try{
			if (evaluateServiceArray != null && evaluateServiceArray.length()>0) {
				for (int i = 0; i < evaluateServiceArray.length(); i++) {
					JSONObject evaluateServiceJson = null;
					evaluateServiceJson = (JSONObject) evaluateServiceArray.get(i);
					EvaluateServiceInfo evaluateServiceInfo=new EvaluateServiceInfo();
					if (evaluateServiceJson.has("OrderObjectID")) {
						evaluateServiceInfo.setOrderObejctID(evaluateServiceJson.getInt("OrderObjectID"));
					}
					if (evaluateServiceJson.has("ServiceName")) {
						evaluateServiceInfo.setServiceName(evaluateServiceJson.getString("ServiceName"));
					}
					if (evaluateServiceJson.has("TGEndTime")) {
						evaluateServiceInfo.setTgEndTime(evaluateServiceJson.getString("TGEndTime"));
					}
					if (evaluateServiceJson.has("TGFinishedCount")) {
						evaluateServiceInfo.setTgFinishedCount(evaluateServiceJson.getInt("TGFinishedCount"));
					}
					if (evaluateServiceJson.has("TGTotalCount")) {
						evaluateServiceInfo.setTgTotalCount(evaluateServiceJson.getInt("TGTotalCount"));
					}
					if (evaluateServiceJson.has("ResponsiblePersonName")) {
						evaluateServiceInfo.setResponsiblePersonName(evaluateServiceJson.getString("ResponsiblePersonName"));
					}
					if (evaluateServiceJson.has("GroupNo")) {
						evaluateServiceInfo.setGroupNo(evaluateServiceJson.getLong("GroupNo"));
					}
					evaluateServiceList.add(evaluateServiceInfo);
				}
			}
		}catch(JSONException e){
		}
		return evaluateServiceList;
	}

	public static EvaluateServiceInfo parseListTMByJson(String stringJson){
		ArrayList<EvaluateServiceListTMInfo> listTM = new ArrayList<EvaluateServiceListTMInfo>();
		EvaluateServiceInfo evaluateServiceInfo=new EvaluateServiceInfo();
		JSONObject evaluateServiceObject = null;
		try {
			evaluateServiceObject = new JSONObject(stringJson);
		} catch (JSONException e) {
		}
		try{
			if (evaluateServiceObject != null) {
				if (evaluateServiceObject.has("ServiceName")) {
					evaluateServiceInfo.setServiceName(evaluateServiceObject.getString("ServiceName"));
				}
				if (evaluateServiceObject.has("Satisfaction")) {
					evaluateServiceInfo.setSatisfaction(evaluateServiceObject.getInt("Satisfaction"));
				}
				if (evaluateServiceObject.has("TGEndTime")) {
					evaluateServiceInfo.setTgEndTime(evaluateServiceObject.getString("TGEndTime"));
				}
				if (evaluateServiceObject.has("TGFinishedCount")) {
					evaluateServiceInfo.setTgFinishedCount(evaluateServiceObject.getInt("TGFinishedCount"));
				}
				if (evaluateServiceObject.has("TGTotalCount")) {
					evaluateServiceInfo.setTgTotalCount(evaluateServiceObject.getInt("TGTotalCount"));
				}
				if (evaluateServiceObject.has("ResponsiblePersonName")) {
					evaluateServiceInfo.setResponsiblePersonName(evaluateServiceObject.getString("ResponsiblePersonName"));
				}
				if (evaluateServiceObject.has("GroupNo")) {
					evaluateServiceInfo.setGroupNo(evaluateServiceObject.getLong("GroupNo"));
				}
				if (evaluateServiceObject.has("Comment")) {
					evaluateServiceInfo.setComment(evaluateServiceObject.getString("Comment"));
				}
				if(evaluateServiceObject.has("listTM") && !evaluateServiceObject.isNull("listTM")){
					JSONArray listTMArray=new JSONArray();
					listTMArray=evaluateServiceObject.getJSONArray("listTM");
					if(listTMArray.length()>0){
						for (int i = 0; i < listTMArray.length(); i++) {
							JSONObject listTMObject = null;
							listTMObject = (JSONObject) listTMArray.get(i);
							EvaluateServiceListTMInfo evaluateServiceListTMInfo = new EvaluateServiceListTMInfo();
							if (listTMObject.has("TMExectorName")) {
								evaluateServiceListTMInfo.setTmExectorName(listTMObject.getString("TMExectorName"));
							}
							if (listTMObject.has("SubServiceName")) {
								evaluateServiceListTMInfo.setSubServiceName(listTMObject.getString("SubServiceName"));
							}
							if (listTMObject.has("Comment")) {
								evaluateServiceListTMInfo.setComment(listTMObject.getString("Comment"));
							}
							if (listTMObject.has("Satisfaction")) {
								evaluateServiceListTMInfo.setSatisfaction(listTMObject.getInt("Satisfaction"));
							}
							if (listTMObject.has("TreatmentID")) {
								evaluateServiceListTMInfo.setTreatmentID(listTMObject.getInt("TreatmentID"));
							}
							listTM.add(evaluateServiceListTMInfo);
						}
						evaluateServiceInfo.setListTM(listTM);
					}
				}
				
			}
		}catch(JSONException e){
		}
		return evaluateServiceInfo;
	}
	
	
	public String getServiceName() {
		return serviceName;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public String getTgEndTime() {
		return tgEndTime;
	}

	public void setTgEndTime(String tgEndTime) {
		this.tgEndTime = tgEndTime;
	}

	public int getTgFinishedCount() {
		return tgFinishedCount;
	}

	public void setTgFinishedCount(int tgFinishedCount) {
		this.tgFinishedCount = tgFinishedCount;
	}

	public int getTgTotalCount() {
		return tgTotalCount;
	}

	public void setTgTotalCount(int tgTotalCount) {
		this.tgTotalCount = tgTotalCount;
	}

	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}

	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}

	public long getGroupNo() {
		return groupNo;
	}

	public void setGroupNo(long groupNo) {
		this.groupNo = groupNo;
	}

	public int getOrderObejctID() {
		return orderObejctID;
	}

	public void setOrderObejctID(int orderObejctID) {
		this.orderObejctID = orderObejctID;
	}
}
