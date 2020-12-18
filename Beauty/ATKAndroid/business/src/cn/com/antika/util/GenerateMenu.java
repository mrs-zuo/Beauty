package cn.com.antika.util;

import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.menu.BusinessLeftMenu;
import cn.com.antika.view.menu.BusinessRightMenu;

import android.content.Context;

public class GenerateMenu {
	public static void generateLeftMenu(Context context, BusinessLeftImageButton bussinessLeftMenuBtn)
	{
		BusinessLeftMenu businessLeftMenu=new BusinessLeftMenu();
		businessLeftMenu.createLeftMenu(context);
		bussinessLeftMenuBtn.createBusinessLeftMenu(businessLeftMenu);
	}
	public static void generateRightMenu(Context context, BusinessRightImageButton bussinessRightMenuBtn)
	{
		BusinessRightMenu businessRightMenu=new BusinessRightMenu();
		businessRightMenu.createRightMenu(context);
		bussinessRightMenuBtn.createBusinessRightMenu(businessRightMenu);
	}
}
