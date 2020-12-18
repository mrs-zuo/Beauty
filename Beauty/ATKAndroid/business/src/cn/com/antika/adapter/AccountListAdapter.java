package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.ArrayList;

import cn.com.antika.bean.AccountDetailInfo;
import cn.com.antika.business.R;
import cn.com.antika.util.ImageLoaderUtil;

@SuppressLint("ResourceType")
public class AccountListAdapter extends BaseAdapter{
	private LayoutInflater layoutInflater;
	private Context mContext;
	private ArrayList<AccountDetailInfo> accountList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	public AccountListAdapter(Context context, ArrayList<AccountDetailInfo> accountList) {
		this.mContext = context;
		this.accountList = accountList;
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return accountList.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		AccountItem AccountItem = null;
		if (convertView == null) {
			AccountItem = new AccountItem();
			convertView = layoutInflater.inflate(R.xml.account_list_item, null);
			AccountItem.accountHeadImage = (ImageView) convertView.findViewById(R.id.account_headimage);
			AccountItem.accountName = (TextView) convertView.findViewById(R.id.account_name);
			AccountItem.accountTitle = (TextView) convertView.findViewById(R.id.account_title);
			AccountItem.accountDepartment = (TextView) convertView.findViewById(R.id.account_department);
			convertView.setTag(AccountItem);
		} else {
			AccountItem = (AccountItem) convertView.getTag();
		}
		imageLoader.displayImage(accountList.get(position).getHeadImageURL(),AccountItem.accountHeadImage,displayImageOptions);
		//设置AccountName
		if (!accountList.get(position).getAccountName().equals("")) {
			AccountItem.accountName.setText((String) accountList.get(position).getAccountName());
		}else{
			AccountItem.accountName.setText("无");
		}
		
		//设置Title
		if (!accountList.get(position).getTitle().equals("")) {
			AccountItem.accountTitle.setText((String) (accountList.get(position).getTitle()));
		}else{
			AccountItem.accountTitle.setText("");
		}
		//设置Department
		if (!accountList.get(position).getDepartment().equals("")) {
			AccountItem.accountDepartment.setText((String) accountList.get(position).getDepartment());
		}else{
			AccountItem.accountDepartment.setText("");
		}

		return convertView;
	}
	public final class AccountItem {
		public ImageView accountHeadImage;
		public TextView  accountName;
		public TextView  accountTitle;
		public TextView  accountDepartment;
	}
}
