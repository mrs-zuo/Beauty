package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;

import android.os.Parcel;
import android.os.Parcelable;

/*
 * 专业信息
 * */
public class CustomerVocation implements Serializable {
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么)
	 */
	private static final long serialVersionUID = 1L;
	private int    questionId;
	private int    questionType; // 0:文本 1：单项选择 2:多项选择
	private String questionName;
	private String questionDescription;//问题的描述
	private String questionContent;
	private int    answerId;
	private String answerContent;
	private boolean isAnswered;//这个问题是否被显示到界面上过，但是不考虑一定要有答案
	private List<CustomerVocationEditAnswer> customerVocationEditAnswer;
	public CustomerVocation() {

	}

	public String getQuestionName() {
		return questionName;
	}

	public void setQuestionName(String questionName) {
		this.questionName = questionName;
	}

	public String getQuestionContent() {
		return questionContent;
	}

	public void setQuestionContent(String questionContent) {
		this.questionContent = questionContent;
	}

	public String getAnswerContent() {
		return answerContent;
	}

	public void setAnswerContent(String answerContent) {
		this.answerContent = answerContent;
	}

	public int getQuestionId() {
		return questionId;
	}

	public int getQuestionType() {
		return questionType;
	}

	public int getAnswerId() {
		return answerId;
	}

	public void setQuestionId(int questionId) {
		this.questionId = questionId;
	}

	public void setQuestionType(int questionType) {
		this.questionType = questionType;
	}

	public void setAnswerId(int answerId) {
		this.answerId = answerId;
	}
	
	public List<CustomerVocationEditAnswer> getCustomerVocationEditAnswer() {
		return customerVocationEditAnswer;
	}

	public void setCustomerVocationEditAnswer(List<CustomerVocationEditAnswer> customerVocationEditAnswer) {
		this.customerVocationEditAnswer = customerVocationEditAnswer;
	}

	public boolean isAnswered() {
		return isAnswered;
	}

	public void setAnswered(boolean isAnswered) {
		this.isAnswered = isAnswered;
	}

	public String getQuestionDescription() {
		return questionDescription;
	}

	public void setQuestionDescription(String questionDescription) {
		this.questionDescription = questionDescription;
	}
}
