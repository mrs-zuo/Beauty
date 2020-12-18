/**
 * StepTemplate.java
 * com.GlamourPromise.Beauty.bean
 * tim.zhang@bizapper.com
 * 2015年5月15日 上午9:57:44
 * @version V1.0
 */
package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

/**
 *商机模板
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年5月15日 上午9:57:44
 */
public class StepTemplate implements Serializable {

	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private  int   stepTemplateID;//商机模板ID
	private  String stepTemplateName;//商机模板名称
	public int getStepTemplateID() {
		return stepTemplateID;
	}
	public void setStepTemplateID(int stepTemplateID) {
		this.stepTemplateID = stepTemplateID;
	}
	public String getStepTemplateName() {
		return stepTemplateName;
	}
	public void setStepTemplateName(String stepTemplateName) {
		this.stepTemplateName = stepTemplateName;
	}
}
