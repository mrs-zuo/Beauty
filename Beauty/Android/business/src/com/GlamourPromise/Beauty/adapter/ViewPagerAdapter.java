package com.GlamourPromise.Beauty.adapter;

import java.util.List;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;

public class ViewPagerAdapter extends PagerAdapter{

	private List<View> mViewList;
	public ViewPagerAdapter(List<View> mViewList)
	{
		this.mViewList=mViewList;
	}
    @Override
    public int getCount() {
           return mViewList .size();
   }
    @Override
    public Object instantiateItem(View container, int position) {
           ((ViewPager) container).addView( mViewList.get(position),0);
           return mViewList .get(position);
   }
   
    @Override
    public void destroyItem(View container, int position, Object object) {
          ((ViewPager) container).removeView( mViewList.get(position)); 
   }
   
    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
           return arg0 == arg1;
   }
}

