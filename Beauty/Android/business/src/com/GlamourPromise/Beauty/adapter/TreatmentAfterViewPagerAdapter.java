package com.GlamourPromise.Beauty.adapter;

import java.util.List;

import com.GlamourPromise.Beauty.bean.TreatmentImage;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.view.OrigianlImageView;

import android.app.Dialog;
import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.View.OnClickListener;

public class TreatmentAfterViewPagerAdapter extends PagerAdapter{

	private List<View> mViewList;
	private List<TreatmentImage> treatmentImageAfterList;
	private Context              mContext;
	public TreatmentAfterViewPagerAdapter(List<View> mViewList,List<TreatmentImage> treatmentImageAfterList,Context context)
	{
		this.mViewList=mViewList;
		this.treatmentImageAfterList=treatmentImageAfterList;
		this.mContext=context;
	}
    @Override
    public int getCount() {
           return mViewList.size();
   }
    @Override
    public Object instantiateItem(View container, int position) {
    		final int pos=position;
           ((ViewPager) container).addView( mViewList.get(position),0);
           mViewList.get(position).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				new OrigianlImageView(mContext,mViewList.get(pos),treatmentImageAfterList.get(pos).getOrigianlImageURL()).showOrigianlImage();
			}
		});
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

