package com.GlamourPromise.Beauty.util;

import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.menu.BusinessLeftMenu;
import com.GlamourPromise.Beauty.view.menu.BusinessRightMenu;

import android.content.Context;

public class GenerateMenu {
	public static void generateLeftMenu(Context context,BusinessLeftImageButton bussinessLeftMenuBtn)
	{
		BusinessLeftMenu businessLeftMenu=new BusinessLeftMenu();
		businessLeftMenu.createLeftMenu(context);
		bussinessLeftMenuBtn.createBusinessLeftMenu(businessLeftMenu);
	}
	public static void generateRightMenu(Context context,BusinessRightImageButton bussinessRightMenuBtn)
	{
		BusinessRightMenu businessRightMenu=new BusinessRightMenu();
		businessRightMenu.createRightMenu(context);
		bussinessRightMenuBtn.createBusinessRightMenu(businessRightMenu);
	}
}
