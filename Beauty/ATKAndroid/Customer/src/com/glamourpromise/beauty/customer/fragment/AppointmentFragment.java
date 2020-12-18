package com.glamourpromise.beauty.customer.fragment;
import java.util.ArrayList;
import android.app.LocalActivityManager;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.AppointmentStatusModleActivity;
import com.glamourpromise.beauty.customer.adapter.CustomerInfoPagerAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseFragment;

public class AppointmentFragment extends BaseFragment{
	private UserInfoApplication userInfo;
	private ViewPager customerAppointmentViewPager;
	private CustomerInfoPagerAdapter customerInfoFragmentAdapter;
	private  LinearLayout appointmentStatus2Layout,appointmentStatus1Layout,appointmentStatus3Layout,appointmentStatus4Layout;
	private  View appointmentStatus2DivideView,appointmentStatus1DivideView,appointmentStatus3DivideView,appointmentStatus4DivideView;
	LocalActivityManager manager = null;
	int fromSource=0;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		super.onCreateView(inflater, container, savedInstanceState);
		View   appointmentView=inflater.inflate(R.xml.appointment_fragment,container,false);
		manager = new LocalActivityManager(getActivity(),true);
        manager.dispatchCreate(savedInstanceState);
		userInfo = (UserInfoApplication)getActivity().getApplication();
		fromSource=getActivity().getIntent().getIntExtra("FROM_SOURCE", 0);
		initView(appointmentView);
		return appointmentView;
	}

	private void initView(View   appointmentView){
		customerAppointmentViewPager = (ViewPager)appointmentView.findViewById(R.id.customer_appointment_view_pager);
		ArrayList<View> viewList=new ArrayList<View>();
		Intent it0=new Intent(getActivity(),AppointmentStatusModleActivity.class);
		it0.putExtra("Status",2);
		viewList.add(getView("AppointmentStatus2Activity", it0));
		
		Intent it1=new Intent(getActivity(),AppointmentStatusModleActivity.class);
		it1.putExtra("Status",1);
		viewList.add(getView("AppointmentStatus1Activity", it1));
		
		Intent it2=new Intent(getActivity(),AppointmentStatusModleActivity.class);
		it2.putExtra("Status",3);
		viewList.add(getView("AppointmentStatus3Activity", it2));
		
		Intent it3=new Intent(getActivity(),AppointmentStatusModleActivity.class);
		it3.putExtra("Status",4);
		viewList.add(getView("AppointmentStatus4Activity", it3));		
		appointmentStatus2Layout=(LinearLayout)appointmentView.findViewById(R.id.appointment_status_2_layout);
		appointmentStatus2DivideView=appointmentView.findViewById(R.id.appointment_status_2_divide_view);
		appointmentStatus1Layout=(LinearLayout)appointmentView.findViewById(R.id.appointment_status_1_layout);
		appointmentStatus1DivideView=appointmentView.findViewById(R.id.appointment_status_1_divide_view);
		appointmentStatus3Layout=(LinearLayout)appointmentView.findViewById(R.id.appointment_status_3_layout);
		appointmentStatus3DivideView=appointmentView.findViewById(R.id.appointment_status_3_divide_view);
		appointmentStatus4Layout=(LinearLayout)appointmentView.findViewById(R.id.appointment_status_4_layout);
		appointmentStatus4DivideView=appointmentView.findViewById(R.id.appointment_status_4_divide_view);
		customerInfoFragmentAdapter = new CustomerInfoPagerAdapter(viewList);
		customerAppointmentViewPager.setAdapter(customerInfoFragmentAdapter);
		customerAppointmentViewPager.setCurrentItem(fromSource);
		appointmentStatus2Layout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentViewPager.setCurrentItem(0,false);
			}
		});
		appointmentStatus1Layout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentViewPager.setCurrentItem(1,false);
			}
		});
		appointmentStatus3Layout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentViewPager.setCurrentItem(2,false);
			}
		});
		appointmentStatus4Layout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentViewPager.setCurrentItem(3,false);
			}
		});
		customerAppointmentViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			@Override
			public void onPageSelected(int state) {
			}
			@Override
			public void onPageScrolled(int position, float offset,int offsetPiexls) {
				resetAllItem();
				switch (position) {
				case 0:
					setCurrentItemBackground(appointmentStatus2DivideView);
					break;
				case 1:
					setCurrentItemBackground(appointmentStatus1DivideView);
					break;
				case 2:
					setCurrentItemBackground(appointmentStatus3DivideView);
					break;
				case 3:
					setCurrentItemBackground(appointmentStatus4DivideView);
					break;
				}
			}
			@Override
			public void onPageScrollStateChanged(int position) {
			}
		});
	}
	
	protected void setCurrentItemBackground(View currentDivideView){
		currentDivideView.setVisibility(View.VISIBLE);
	}
	protected void resetAllItem() {
		appointmentStatus1DivideView.setVisibility(View.GONE);
		appointmentStatus2DivideView.setVisibility(View.GONE);
		appointmentStatus3DivideView.setVisibility(View.GONE);
		appointmentStatus4DivideView.setVisibility(View.GONE);
	}
	 private View getView(String id, Intent intent) {
	        return manager.startActivity(id, intent).getDecorView();
	 }

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
	}
}
