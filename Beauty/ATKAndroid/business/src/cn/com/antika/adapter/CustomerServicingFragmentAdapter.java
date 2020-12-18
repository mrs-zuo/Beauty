/**
 * CustomerServicingFragmentAdapter.java
 * cn.com.antika.adapter
 * tim.zhang@bizapper.com
 * 2015年7月6日 下午2:07:29
 * @version V1.0
 */
package cn.com.antika.adapter;

import java.util.List;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

/**
 *CustomerServicingFragmentAdapter
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月6日 下午2:07:29
 */
public class CustomerServicingFragmentAdapter extends FragmentPagerAdapter{
	private List<Fragment> mFragmentList;
	public CustomerServicingFragmentAdapter(FragmentManager fm,List<Fragment> fragmentList) {
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
