package com.glamourpromise.beauty.customer.bean;

import android.view.View;
import android.widget.RelativeLayout;

public class TableRowItemInformation {

	int flag;// 0��һ����ʾ��1��������ʾ
	int type;//0����ͨ��ʾ��1����ʾ������Ǯ�ķ�� 
	String titleName;// ���еı���
	String content;// ����
	String contentTwo;
	View twoChildLineView;//��Ҫ������ʾʱʹ�õ�
	View RowLineView;
	RelativeLayout relativeLayout_one;
	RelativeLayout relativeLayout_two;

	public TableRowItemInformation() {
		twoChildLineView = null;
		RowLineView = null;
		contentTwo = "";
		type = 0;
	}

	public int getFlag() {
		return flag;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}
	
	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getTitleName() {
		return titleName;
	}

	public void setTitleName(String titleName) {
		this.titleName = titleName;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}
	
	public String getContentTwo() {
		return contentTwo;
	}

	public void setContentTwo(String contentTwo) {
		this.contentTwo = contentTwo;
	}

	public View getTwoChildLineView() {
		return twoChildLineView;
	}

	public void setTwoChildLineView(View twoChildLineView) {
		this.twoChildLineView = twoChildLineView;
	}
	
	public View getRowLineView() {
		return RowLineView;
	}

	public void setRowLineView(View RowLineView) {
		this.RowLineView = RowLineView;
	}

	public RelativeLayout getRelativeLayoutOne() {
		return relativeLayout_one;
	}

	public void setRelativeLayoutOne(RelativeLayout relativeLayout_one) {
		this.relativeLayout_one = relativeLayout_one;
	}

	public RelativeLayout getRelativeLayoutTwo() {
		return relativeLayout_two;
	}

	public void setRelativeLayoutTwo(RelativeLayout relativeLayout_two) {
		this.relativeLayout_two = relativeLayout_two;
	}
}
