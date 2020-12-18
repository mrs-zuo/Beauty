package cn.com.antika.adapter;

import java.util.List;

import cn.com.antika.bean.TreatmentImage;
import cn.com.antika.view.OrigianlImageView;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.view.View.OnClickListener;

public class TreatmentBeforeViewPagerAdapter extends PagerAdapter{

	private List<View> mViewList;
	private List<TreatmentImage> treatmentImageBeforeList;
	private Context              mContext;
	public TreatmentBeforeViewPagerAdapter(List<View> mViewList,List<TreatmentImage> treatmentImageBeforeList,Context context)
	{
		this.mViewList=mViewList;
		this.treatmentImageBeforeList=treatmentImageBeforeList;
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
				//DialogUtil.createShortDialog(mContext,treatmentImageBeforeList.get(pos).getOrigianlImageURL());
				new OrigianlImageView(mContext,mViewList.get(pos),treatmentImageBeforeList.get(pos).getOrigianlImageURL()).showOrigianlImage();
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

