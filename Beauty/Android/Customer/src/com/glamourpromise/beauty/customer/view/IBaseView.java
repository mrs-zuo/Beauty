package com.glamourpromise.beauty.customer.view;

public interface IBaseView {
	public void handleHttpError_401(int httpCode);
	public void handleLoginException();
	public void promptUpdate();
}
