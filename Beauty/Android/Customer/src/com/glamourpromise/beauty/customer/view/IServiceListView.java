package com.glamourpromise.beauty.customer.view;

import java.util.ArrayList;

import com.glamourpromise.beauty.customer.bean.ServiceInformation;

public interface IServiceListView extends IBaseView{
	public void renderView(ArrayList<ServiceInformation> serviceList);
	public void renderError(String message);
}
