package cn.com.antika.bean;

import java.io.Serializable;
public class OpportunityProgressHistory implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private  int    progressHistoryID;
	private  int    progress;
	private  String description;
	private  String createTime;
	private  String progressName;
	public  OpportunityProgressHistory(){
		
	}
	public int getProgressHistoryID() {
		return progressHistoryID;
	}
	public int getProgress() {
		return progress;
	}
	public String getDescription() {
		return description;
	}
	public String getCreateTime() {
		return createTime;
	}
	public void setProgressHistoryID(int progressHistoryID) {
		this.progressHistoryID = progressHistoryID;
	}
	public void setProgress(int progress) {
		this.progress = progress;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}
	public String getProgressName() {
		return progressName;
	}
	public void setProgressName(String progressName) {
		this.progressName = progressName;
	}
}
