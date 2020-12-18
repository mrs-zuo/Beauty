package com.GlamourPromise.Beauty.view;
import com.GlamourPromise.Beauty.Business.ChooseServicePeopleActivity;
import com.GlamourPromise.Beauty.Business.R;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.HorizontalScrollView;
import android.widget.TextView;

public class SyncHorizontalScrollView extends HorizontalScrollView {
	private View mView;
	private Activity mActivity;
	public SyncHorizontalScrollView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public SyncHorizontalScrollView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	protected void onScrollChanged(int l, int t, int oldl, int oldt) {
		super.onScrollChanged(l, t,oldl, oldt);
		if (mView != null) {
			
			mView.scrollTo(l,t);
			int scollViewX=this.getScrollX();
			if(ChooseServicePeopleActivity.clockIconLeft!=0)
				scollViewX=scollViewX+ChooseServicePeopleActivity.clockIconLeft;
			int hour=scollViewX/60;
			int minutes=scollViewX%60;
			String hourStr="";
			String minutesStr="";
			if(hour<10)
				hourStr="0"+hour;
			else
				hourStr=String.valueOf(hour);
			if(minutes<10)
				minutesStr="0"+minutes;
			else
				minutesStr=String.valueOf(minutes);
			String nowTime=hourStr+":"+minutesStr;
			TextView personScheduleDateText=(TextView)mActivity.findViewById(R.id.person_schedule_date);
			TextView chooseServicePersonScheduleInfoText=(TextView)mActivity.findViewById(R.id.choose_service_person_schedule_info_text);
			chooseServicePersonScheduleInfoText
					.setText(personScheduleDateText.getText().toString()
							+"\t"+nowTime);
			
		}
	}
	public void setScrollView(View view,Activity activity) {
		mView = view;
		this.mActivity=activity;
	}

}