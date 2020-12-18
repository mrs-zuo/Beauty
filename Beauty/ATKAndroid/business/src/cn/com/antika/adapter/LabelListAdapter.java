package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.HashMap;

import cn.com.antika.bean.LabelInfo;
import cn.com.antika.business.R;
import cn.com.antika.util.DialogUtil;

@SuppressLint("ResourceType")
public class LabelListAdapter extends BaseAdapter{
	private ArrayList<LabelInfo> mLabelList;
	private ArrayList<Boolean> selectFlagList;
	private String overLimitNumPrompt;
	private int mLimitNum;
	private int currentSelectNum;
	private Context mContext;
	private LayoutInflater layoutInflater;
	
	public LabelListAdapter(Context context, ArrayList<LabelInfo> labelList, ArrayList<Integer> lastSelectIDList, int limitNum){
		mLabelList = labelList;
		mContext = context;
		mLimitNum = limitNum;
		overLimitNumPrompt = "只能选择" + String.valueOf(mLimitNum) + "个标签";
		layoutInflater = LayoutInflater.from(mContext);
		selectFlagList = new ArrayList<Boolean>();
		currentSelectNum = 0;
		for(int i = 0; i < mLabelList.size(); i++){
			selectFlagList.add(false);
			if(lastSelectIDList == null || lastSelectIDList.size() < 1)
				continue;
			for(int j =0; j < lastSelectIDList.size(); j++){
				if(mLabelList.get(i).getID().equals(String.valueOf(lastSelectIDList.get(j)))){
					selectFlagList.add(i, true);
					currentSelectNum++;
					break;
				}
			}
			
		}
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mLabelList.size();
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
	public void notifyDataSetChanged(){
		super.notifyDataSetChanged();
	}
	
	public void setLimitNum(int limitNum){
		mLimitNum = limitNum;
	}

	public ArrayList<LabelInfo> getSelectLabelList(){
		ArrayList<LabelInfo> selectLabelList = new ArrayList<LabelInfo>();
		for(int i = 0; i< selectFlagList.size(); i++){
			if(selectFlagList.get(i)){
				selectLabelList.add(mLabelList.get(i));
			}
		}
		return selectLabelList;
		
	}
	
	@SuppressLint("UseSparseArrays")
	public HashMap<Integer, LabelInfo> getSelectLabelHashMap(){
		HashMap<Integer, LabelInfo> selectLabelHashMap = new HashMap<Integer, LabelInfo>();
		int pos = 0;
		for(int i = 0; i< selectFlagList.size(); i++){
			if(selectFlagList.get(i)){
				selectLabelHashMap.put(pos, mLabelList.get(i));
				pos++;
			}
		}
		return selectLabelHashMap;
		
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		LabelItem labelItem = null;
		if (convertView == null) {
			labelItem = new LabelItem();
			convertView = layoutInflater.inflate(R.xml.label_list_item, null);
			labelItem.labelName = (TextView) convertView.findViewById(R.id.label_name);
			labelItem.selectButton = (ImageButton) convertView.findViewById(R.id.select_button);
			convertView.setTag(labelItem);
		}else {
			labelItem = (LabelItem) convertView.getTag();
		}
		labelItem.labelName.setText(mLabelList.get(position).getLabelName());
		if(selectFlagList.get(position)){
			labelItem.selectButton.setBackgroundResource(R.drawable.select_btn);
		}else{
			labelItem.selectButton.setBackgroundResource(R.drawable.no_select_btn);
		}
		final int finalPosition = position;
		labelItem.selectButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if(selectFlagList.get(finalPosition)){
					selectFlagList.set(finalPosition, false);
					arg0.setBackgroundResource(R.drawable.no_select_btn);
					currentSelectNum--;
				}else if(!selectFlagList.get(finalPosition) && (mLimitNum < 0 || (mLimitNum > 0 && currentSelectNum < mLimitNum))){
					selectFlagList.set(finalPosition, true);
					arg0.setBackgroundResource(R.drawable.select_btn);
					currentSelectNum++;
				}else{
					DialogUtil.createShortDialog(mContext, overLimitNumPrompt);
				}
				
			}
		});
		return convertView;
	}
	
	public final class LabelItem {
		public ImageButton selectButton;
		public TextView labelName;
	}
}
