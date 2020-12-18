package cn.com.antika.bean;
import java.io.Serializable;

public class MessageTemplate implements Serializable{
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么) 
	 */
	private static final long serialVersionUID = 1L;
	private int     templateID;
	private String  templateContent;
	private String  subject;
	private int     templateType;
	private int     creatorID;
	private String  creatorName;
	private String  lastEditName;
	private String  time;
	public MessageTemplate(){
		
	}
	public int getTemplateID() {
		return templateID;
	}
	public String getTemplateContent() {
		return templateContent;
	}
	public String getSubject() {
		return subject;
	}
	public int getTemplateType() {
		return templateType;
	}
	public int getCreatorID() {
		return creatorID;
	}
	public String getCreatorName() {
		return creatorName;
	}
	public String getTime() {
		return time;
	}
	public void setTemplateID(int templateID) {
		this.templateID = templateID;
	}
	public void setTemplateContent(String templateContent) {
		this.templateContent = templateContent;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public void setTemplateType(int templateType) {
		this.templateType = templateType;
	}
	public void setCreatorID(int creatorID) {
		this.creatorID = creatorID;
	}
	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}
	public void setTime(String time) {
		this.time = time;
	}
	public String getLastEditName() {
		return lastEditName;
	}
	public void setLastEditName(String lastEditName) {
		this.lastEditName = lastEditName;
	}
}
