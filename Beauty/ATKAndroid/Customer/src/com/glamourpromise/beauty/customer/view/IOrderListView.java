package com.glamourpromise.beauty.customer.view;

import java.util.ArrayList;

import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;

public interface IOrderListView extends IBaseView{
	public void renderView(ArrayList<OrderBaseInfo> orderList);
	public void renderError(String message);
}
