package com.GlamourPromise.Beauty.view.menu;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.GlamourPromise.Beauty.Business.AppointmentListActivity;
import com.GlamourPromise.Beauty.Business.CommodityCategoryActivity;
import com.GlamourPromise.Beauty.Business.Company;
import com.GlamourPromise.Beauty.Business.CustomerActivity;
import com.GlamourPromise.Beauty.Business.CustomerServicingActivity;
import com.GlamourPromise.Beauty.Business.DecodeQRCodeActivity;
import com.GlamourPromise.Beauty.Business.FavoriteListActivity;
import com.GlamourPromise.Beauty.Business.HomePageActivity;
import com.GlamourPromise.Beauty.Business.ServiceActivity;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.Business.UnfishTGListActivity;
import com.GlamourPromise.Beauty.Business.UnpaidCustomerListActivity;
import com.GlamourPromise.Beauty.adapter.RightMenuAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.constant.Constant;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.GlamourPromise.Beauty.view.menu.SlidingMenu.OnOpenedListener;

public class BusinessRightMenu {
    private SlidingMenu menu;
    public static RightMenuAdapter rightMenuAdapter;
    private static ListView rightMenuListView;
    private static Context mContext;
    private static SlidingMenu staticRightMenu;
    private List<OrderProduct> orderProductList;

    public SlidingMenu getMenu() {
        return menu;
    }

    public void createRightMenu(Context context) {
        mContext = context;
        menu = new SlidingMenu(mContext);
        menu.setMode(SlidingMenu.RIGHT);
        menu.setTouchModeAbove(SlidingMenu.TOUCHMODE_NONE);
        menu.setBehindOffsetRes(R.dimen.slidingmenu_offset);
        menu.setBehindWidth((int) context.getResources().getDimension(R.dimen.slidingmenu_width));
        menu.setFadeDegree(0.35f);
        // 设置阴影
        menu.setShadowWidth(30);
        menu.setShadowDrawable(R.xml.right_shadow);
        menu.attachToActivity((Activity) context, SlidingMenu.SLIDING_CONTENT);
        menu.setMenu(R.layout.business_right_menu);
        rightMenuListView = (ListView) ((Activity) context).findViewById(R.id.menu_right_listview);
        this.staticRightMenu = menu;
        menu.setOnOpenedListener(new OnOpenedListener() {
            @Override
            public void onOpened() {
                // TODO Auto-generated method stub
                //如果处于开单状态 则滚动到最底部
                UserInfoApplication userinfoApplication = UserInfoApplication.getInstance();
                final int customerID = userinfoApplication.getSelectedCustomerID();
                OrderInfo orderInfo = userinfoApplication.getOrderInfo();
                if (orderInfo != null) {
                    orderProductList = orderInfo.getOrderProductList();
                }
                if (customerID != 0 && orderProductList != null && orderProductList.size() > 0)
                    rightMenuListView.setSelection(rightMenuListView.getBottom());
            }
        });
        createMenuContent();
    }

    public static void createMenuContent() {
        final List<String> menuTetxtList = new ArrayList<String>();
        final List<Integer> menuIconList = new ArrayList<Integer>();
        AccountInfo accountInfo = UserInfoApplication.getInstance().getAccountInfo();
        //查看我的顾客权限
        int authMyCustomerRead = accountInfo.getAuthMyCustomerRead();
        int authServiceRead = accountInfo.getAuthServiceRead();
        int authCommodityRead = accountInfo.getAuthCommodityRead();
        int authMyOrderWrite = accountInfo.getAuthMyOrderWrite();
        //结账的权限
        int authPaymentUse = accountInfo.getAuthPaymentUse();
        //查看自己订单和预约的权限
        int authMyOrderRead = accountInfo.getAuthMyOrderRead();
        menuTetxtList.add("首页");
        menuIconList.add(R.drawable.menu_right_01);
        if (authMyCustomerRead == 1) {
            menuTetxtList.add("顾客");
            menuIconList.add(R.drawable.menu_right_04);
        }
        if (UserInfoApplication.getInstance().getSelectedCustomerID() != 0) {
            menuTetxtList.add(UserInfoApplication.getInstance().getSelectedCustomerName());
            menuIconList.add(R.drawable.right_menu_customer_01);
        }
        if (authServiceRead == 1) {
            menuTetxtList.add("服务");
            menuIconList.add(R.drawable.menu_right_02);
        }
        if (authCommodityRead == 1) {
            menuTetxtList.add("商品");
            menuIconList.add(R.drawable.menu_right_03);
        }
        if (authMyOrderWrite == 1) {
            menuTetxtList.add("开单");
            menuIconList.add(R.drawable.menu_right_05);
            menuTetxtList.add("结单");
            menuIconList.add(R.drawable.menu_right_complete_order_icon);
        }
        if (authMyOrderRead == 1) {
            menuTetxtList.add("预约");
            menuIconList.add(R.drawable.menu_right_appointment_icon);
        }
        if (authPaymentUse == 1) {
            menuTetxtList.add("结账");
            menuIconList.add(R.drawable.menu_left_09);
        }
        menuTetxtList.add("扫一扫");
        menuIconList.add(R.drawable.menu_right_06);
        //公司和门店信息
        menuTetxtList.add(UserInfoApplication.getInstance().getAccountInfo().getCompanyAbbreviation());
        menuIconList.add(R.drawable.menu_right_companyinfo);
        Integer menuRightIcons[] = new Integer[menuIconList.size()];
        String menuRightItems[] = new String[menuTetxtList.size()];
        menuIconList.toArray(menuRightIcons);
        menuTetxtList.toArray(menuRightItems);
        List<Map<String, Object>> menuRightList = new ArrayList<Map<String, Object>>();
        for (int i = 0; i < menuRightItems.length; i++) {
            Map<String, Object> menuItem = new HashMap<String, Object>();
            menuItem.put("menu_icon", menuRightIcons[i]);
            menuItem.put("menu_text", menuRightItems[i]);
            menuRightList.add(menuItem);
        }
        final Context mcontext = mContext;
        rightMenuAdapter = new RightMenuAdapter(mcontext, menuRightList);
        rightMenuListView.setAdapter(rightMenuAdapter);
        rightMenuListView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                Intent destIntent = null;
                if (menuTetxtList.get(position).equals("首页")) {
                    destIntent = new Intent(mcontext, HomePageActivity.class);
                    // destIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                } else if (menuTetxtList.get(position).equals("开单")) {
                    destIntent = new Intent(mcontext, CustomerServicingActivity.class);
                    //表示进入的顾客服务页是菜单进来的
                    destIntent.putExtra("fromSource", 1);
                    //每次从右侧进开单页，即顾客服务页，清楚掉当前的顾客信息
                    UserInfoApplication userInfoApplication = UserInfoApplication.getInstance();
                    userInfoApplication.setSelectedCustomerID(0);
                    userInfoApplication.setSelectedCustomerName("");
                    userInfoApplication.setSelectedCustomerHeadImageURL("");
                    userInfoApplication.setSelectedCustomerLoginMobile("");
                    OrderInfo orderInfo = userInfoApplication.getOrderInfo();
                    //清空待开列表数据
                    List<OrderProduct> orderProductList = null;
                    if (orderInfo != null)
                        orderProductList = orderInfo.getOrderProductList();
                    if (orderProductList != null && orderProductList.size() > 0) {
                        orderProductList.clear();
                        userInfoApplication.setOrderInfo(orderInfo);
                        userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
                    }
                    BusinessRightMenu.createMenuContent();
                } else if (menuTetxtList.get(position).equals("收藏"))
                    destIntent = new Intent(mcontext, FavoriteListActivity.class);
                else if (menuTetxtList.get(position).equals("服务"))
                    destIntent = new Intent(mcontext, ServiceActivity.class);
                else if (menuTetxtList.get(position).equals("商品"))
                    destIntent = new Intent(mcontext, CommodityCategoryActivity.class);
                else if (menuTetxtList.get(position).equals(UserInfoApplication.getInstance().getAccountInfo().getCompanyAbbreviation())) {
                    destIntent = new Intent(mcontext, Company.class);
                } else if (menuTetxtList.get(position).equals("顾客"))
                    destIntent = new Intent(mcontext, CustomerActivity.class);
                else if (menuTetxtList.get(position).equals("结账"))
                    destIntent = new Intent(mcontext, UnpaidCustomerListActivity.class);
                else if (menuTetxtList.get(position).equals("结单"))
                    destIntent = new Intent(mcontext, UnfishTGListActivity.class);
                else if (menuTetxtList.get(position).equals("预约")) {
                    destIntent = new Intent(mcontext, AppointmentListActivity.class);
                    destIntent.putExtra("FROM_SOURCE", "MENU_RIGHT");
                } else if (menuTetxtList.get(position).equals("扫一扫"))
                    destIntent = new Intent(mcontext, DecodeQRCodeActivity.class);
                else if (menuTetxtList.get(position).equals(UserInfoApplication.getInstance().getSelectedCustomerName())) {
                    destIntent = new Intent(mcontext, CustomerServicingActivity.class);
                }
                if (destIntent != null) {
                    destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                    mcontext.startActivity(destIntent);
                    staticRightMenu.showContent();
                }
            }
        });
    }
}
