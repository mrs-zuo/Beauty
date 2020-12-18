package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;

public class CustomerVocationEditAnswer implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private  String answerContent;
	private  int    isAnswer;
	private  int    isQuestionDescription;
	public String getAnswerContent() {
		return answerContent;
	}
	public void setAnswerContent(String answerContent) {
		this.answerContent = answerContent;
	}
	public int getIsAnswer() {
		return isAnswer;
	}
	public void setIsAnswer(int isAnswer) {
		this.isAnswer = isAnswer;
	}
	public int getIsQuestionDescription() {
		return isQuestionDescription;
	}
	public void setIsQuestionDescription(int isQuestionDescription) {
		this.isQuestionDescription = isQuestionDescription;
	}
}
