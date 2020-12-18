package com.GlamourPromise.Beauty.bean;
import java.io.Serializable;
public class PersonSchedule implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private String scdlStartTime;
	private String scdlEndTime;
	public  PersonSchedule(){
		
	}
	public String getScdlStartTime() {
		return scdlStartTime;
	}
	public void setScdlStartTime(String scdlStartTime) {
		this.scdlStartTime = scdlStartTime;
	}
	public String getScdlEndTime() {
		return scdlEndTime;
	}
	public void setScdlEndTime(String scdlEndTime) {
		this.scdlEndTime = scdlEndTime;
	}
}
