package cn.com.antika.bean;

public class NoteInfo {
	private String createName;
	private String createTime;
	private String content;
	private int    noteID;
	private String label = "";
	private String tagIDs = "";
	private String customerName;
	private StringBuilder labelTemp;
	
	public String getCreateName() {
		return createName;
	}
	public void setCreateName(String createName) {
		this.createName = createName;
	}
	public String getCreateTime() {
		return createTime;
	}
	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		String[] labelList = label.split("\\|");
		labelTemp = new StringBuilder();
		for(int i = 0; i < labelList.length; i++){
			labelTemp.append(labelList[i]);
			if(i != labelList.length - 1)
				labelTemp.append("、");
		}
		
		this.label = labelTemp.toString();
	}
	public String getTagIDs() {
		return tagIDs;
	}
	public void setTagIDs(String tagIDs) {
		this.tagIDs = tagIDs;
	}
	public int getNoteID() {
		return noteID;
	}
	public void setNoteID(int noteID) {
		this.noteID = noteID;
	}
	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
}
