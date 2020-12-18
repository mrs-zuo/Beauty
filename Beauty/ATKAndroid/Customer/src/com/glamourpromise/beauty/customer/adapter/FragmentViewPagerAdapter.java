package com.glamourpromise.beauty.customer.adapter;
import java.util.List;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

public class FragmentViewPagerAdapter extends FragmentPagerAdapter{
	private List<Fragment> mFragmentList;
	public FragmentViewPagerAdapter(FragmentManager fm,List<Fragment> fragmentList) {
		super(fm);
		this.mFragmentList=fragmentList;
	}
	@Override
	public Fragment getItem(int position) {
		// TODO Auto-generated method stub
		return mFragmentList.get(position);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mFragmentList.size();
	}

}
