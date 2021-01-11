package com.GlamourPromise.Beauty.Business;

import android.app.LocalActivityManager;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.RelatedOrderPagerAdapter;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.util.ArrayList;

public class TaskListTabActivity extends BaseActivity {
    private ArrayList<View> tabViewList = new ArrayList<View>();//保存Activity的集合
    private ViewPager taskListViewPager;//显示服务预约任务和回访任务
    private TextView tabAppointmentTaskTitle, tabVisitTaskTitle;
    private LinearLayout tabAppointmentTaskll, tabVisitTaskll;
    private LocalActivityManager manager;
    private RelatedOrderPagerAdapter taskListPagerAdapter;
    private int currentItem;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_task_list_tab);
        manager = new LocalActivityManager(this, true);
        manager.dispatchCreate(savedInstanceState);
        initTabView();
    }

    //初始化选项卡数据
    protected void initTabView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        currentItem = getIntent().getIntExtra("currentItem", 0);
        taskListViewPager = (ViewPager) findViewById(R.id.task_list_tab_view_pager);
        Intent appointmentTaskIntent = new Intent(this, AppointmentTaskListActivity.class);
        tabViewList.add(getView("AppointmentTaskListActivity", appointmentTaskIntent));
        Intent visitTaskIntent = new Intent(this, VisitTaskListActivity.class);
        tabViewList.add(getView("VisitTaskListActivity", visitTaskIntent));
        tabAppointmentTaskTitle = (TextView) findViewById(R.id.appointment_task_tab_title);
        tabAppointmentTaskll = (LinearLayout) findViewById(R.id.appointment_task_tab_ll);
        tabVisitTaskTitle = (TextView) findViewById(R.id.visit_task_tab_title);
        tabVisitTaskll = (LinearLayout) findViewById(R.id.visit_task_tab_ll);
        taskListPagerAdapter = new RelatedOrderPagerAdapter(tabViewList);
        taskListViewPager.setAdapter(taskListPagerAdapter);
        taskListViewPager.setCurrentItem(currentItem);
        tabAppointmentTaskll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                taskListViewPager.setCurrentItem(0, false);
            }
        });
        tabVisitTaskll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                taskListViewPager.setCurrentItem(1, false);
            }
        });
        taskListViewPager.setOnPageChangeListener(new OnPageChangeListener() {
            @Override
            public void onPageSelected(int state) {
            }

            @Override
            public void onPageScrolled(int position, float offset, int offsetPiexls) {
                resetAllItem();
                switch (position) {
                    case 0:
                        tabAppointmentTaskTitle.setTextColor(getResources().getColor(R.color.blue));
                        break;
                    case 1:
                        tabVisitTaskTitle.setTextColor(getResources().getColor(R.color.blue));
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int position) {
            }
        });
    }

    private View getView(String id, Intent intent) {
        return manager.startActivity(id, intent).getDecorView();
    }

    protected void resetAllItem() {
        tabAppointmentTaskTitle.setTextColor(getResources().getColor(R.color.white));
        tabVisitTaskTitle.setTextColor(getResources().getColor(R.color.white));
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);
        if (taskListViewPager.getCurrentItem() == 0) {
            AppointmentTaskListActivity appointmentTaskListActivity = (AppointmentTaskListActivity) manager.getActivity("AppointmentTaskListActivity");
            appointmentTaskListActivity.onActivityResult(requestCode, resultCode, data);
        } else if (taskListViewPager.getCurrentItem() == 1) {
            VisitTaskListActivity visitTaskListActivity = (VisitTaskListActivity) manager.getActivity("VisitTaskListActivity");
            visitTaskListActivity.onActivityResult(requestCode, resultCode, data);
        }
    }
}
