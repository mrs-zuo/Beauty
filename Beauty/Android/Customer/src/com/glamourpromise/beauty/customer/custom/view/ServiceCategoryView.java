package com.glamourpromise.beauty.customer.custom.view;

import java.util.List;
import java.util.Stack;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CategoryListAdapter;
import com.glamourpromise.beauty.customer.bean.CategoryInformation;
import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

public class ServiceCategoryView {
	private static final String TAG = "ServiceCategoryView";
	private String ALL_SERVICE;
	private Activity mContext;
	private ImageButton backButton;
	private ListView categoryListView;
	private List<CategoryInformation> mCategoryInformationList;
	private Stack<List<CategoryInformation>> categoryInformationListStack;
	
	private OnListViewItemClickListener onListViewItemClickListener;
	
	public interface OnListViewItemClickListener{
		public static final int BACK_BUTTON_GONE  = View.GONE;
		public static final int BACK_BUTTON_VISIBLE  = View.VISIBLE;
		
		public void BackButtonStatus(int backButtonStatus);
		public void TurnToServiceActivity(String categoryID, String categoryName);
		public void TurnToNextCategory(String nextCategoryID, String categoryName);
	}
	
	public ServiceCategoryView(Context context){
		mContext = (Activity) context;
		ALL_SERVICE = mContext.getString(R.string.all_service);
		categoryInformationListStack = new Stack<List<CategoryInformation>>();
		//返回按钮事件处理
		backButton = (ImageButton) mContext.findViewById(R.id.btn_main_back);
		backButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				mContext.finish();
			}
		});
		
		categoryListView = (ListView) mContext.findViewById(R.id.category_listview);
		categoryListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				// TODO Auto-generated method stub
				String categoryID = String.valueOf(0);
				String categoryName = ALL_SERVICE;
				if (position == 0) {
					categoryName = mCategoryInformationList.get(position).getParentCategoryName();
					categoryID = String.valueOf(mCategoryInformationList.get(position).getParentCategoryID());
					onListViewItemClickListener.TurnToServiceActivity(categoryID, categoryName);
				}
				else {
					if (Integer.parseInt(mCategoryInformationList.get(position).getNextCategoryCount()) != 0) {
						categoryInformationListStack.push(mCategoryInformationList);
						onListViewItemClickListener.TurnToNextCategory(mCategoryInformationList.get(position).getCategoryID(), mCategoryInformationList.get(position).getCategoryName());
					} else {
						if (Integer.parseInt(mCategoryInformationList.get(position).getCommodityCount()) != 0) {
							categoryID = String.valueOf(mCategoryInformationList.get(position).getCategoryID());
							categoryName = mCategoryInformationList.get(position).getCategoryName();
							onListViewItemClickListener.TurnToServiceActivity(categoryID, categoryName);
						}
					}
				}
			}
		});
	}
	
	public void categoryNotify(List<CategoryInformation> categoryInformationList){
		mCategoryInformationList = categoryInformationList;
		adapterDataSetChanged();
	}
	
	public Boolean backKeyDown(){
		if (categoryInformationListStack.size() >= 1) {
			mCategoryInformationList = categoryInformationListStack.pop();
			adapterDataSetChanged();
		}
		if (categoryInformationListStack.size() <= 1){
			mContext.finish();
			return false;
		}
		else
			return true;
	}
	
	private void adapterDataSetChanged(){
		categoryListView.setAdapter(new CategoryListAdapter(mContext, mCategoryInformationList));
	}
	
	public void setOnListViewItemClickListener(OnListViewItemClickListener onListViewItemClickListener){
		this.onListViewItemClickListener = onListViewItemClickListener;
	}
}
