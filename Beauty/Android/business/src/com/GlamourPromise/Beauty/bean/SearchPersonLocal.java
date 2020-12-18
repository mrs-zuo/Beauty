/**
 * SearchPersonLocal.java
 * com.GlamourPromise.Beauty.bean
 * tim.zhang@bizapper.com
 * 2015年7月17日 下午5:58:53
 * @version V1.0
 */
package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

/**
 *SearchPersonLocal
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月17日 下午5:58:53
 */
public class SearchPersonLocal implements Serializable{
	private int  personID;
	private String personName;
	public int getPersonID() {
		return personID;
	}
	public void setPersonID(int personID) {
		this.personID = personID;
	}
	public String getPersonName() {
		return personName;
	}
	public void setPersonName(String personName) {
		this.personName = personName;
	}
	@Override
	public boolean equals(Object obj) {
		// TODO Auto-generated method stub
		if(obj instanceof SearchPersonLocal){
			SearchPersonLocal spl=(SearchPersonLocal)obj;
			return this.personID==spl.personID && this.personName.equals(spl.personName);
		}
		return super.equals(obj);
	}
}
