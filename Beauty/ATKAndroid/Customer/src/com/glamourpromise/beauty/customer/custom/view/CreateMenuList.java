package com.glamourpromise.beauty.customer.custom.view;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.MenuInformation;

public class CreateMenuList {

	private static CreateMenuList singleton = null;
	private int menuIcons[];

	public static CreateMenuList getInstance() {
		Log.v("getInstance", "start");
		if (singleton == null) {
			synchronized (CreateMenuList.class) {
				if (singleton == null) {
					singleton = new CreateMenuList();
					Log.v("getInstance", "ok");
				}
			}
		}
		return singleton;
	}

	private CreateMenuList() {
		menuIcons = new int[] { R.drawable.menu_homepage_icon,
				R.drawable.menu_company_icon, R.drawable.menu_branch_icon,
				R.drawable.menu_account_icon, R.drawable.menu_commodity_icon,
				R.drawable.menu_cart_icon, R.drawable.menu_order_icon,
				R.drawable.menu_ecard_icon, R.drawable.menu_record_icon,
				R.drawable.menu_message_icon, R.drawable.menu_photo_album_icon,
				R.drawable.menu_setting_icon, R.drawable.menu_quit_icon };

	}

	public List<MenuInformation> getMenuList(Context context) {
		List<MenuInformation> menuList;
		SharedPreferences sharedata = ((Activity) context)
				.getSharedPreferences("customerInformation",
						Context.MODE_PRIVATE);

		String menuItems[] = new String[] {
				context.getString(R.string.left_menu_homepage).toString(),
				sharedata.getString("companyAbbreviation", null),
				context.getString(R.string.left_menu_title_13),
				context.getString(R.string.left_menu_title_3).toString(),
				context.getString(R.string.left_menu_commodity).toString(),
				context.getString(R.string.left_menu_cart).toString(),
				context.getString(R.string.left_menu_order).toString(),
				context.getString(R.string.left_menu_ecard).toString(),
				context.getString(R.string.left_menu_record).toString(),
				context.getString(R.string.left_menu_message).toString(),
				context.getString(R.string.left_menu_photo_album).toString(),
				context.getString(R.string.left_menu_setting).toString(),
				context.getString(R.string.left_menu_title_12).toString() };

		if (!sharedata.getString("cartCount", null).equals("0")) {
			menuItems[5] = context.getString(R.string.left_menu_cart)
					.toString()
					+ "<font color=\"#ff0000\">"
					+ "   ("
					+ sharedata.getString("cartCount", null) + ")" + "</font>";
		}
		if (!sharedata.getString("newMessageCount", null).equals("0")) {
			menuItems[9] = context.getString(R.string.left_menu_message)
					.toString()
					+ "<font color=\"#ff0000\">"
					+ "   ("
					+ sharedata.getString("newMessageCount", null)
					+ ")"
					+ "</font>";
		}
		menuList = new ArrayList<MenuInformation>();
		for (int i = 0; i < menuItems.length; i++) {
			MenuInformation menuItem = new MenuInformation();
			menuItem.setMenuIcon(menuIcons[i]);
			menuItem.setMenuItems(menuItems[i]);
			menuList.add(menuItem);
		}
		return menuList;
	}
}
