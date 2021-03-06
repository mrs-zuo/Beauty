package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import cn.com.antika.bean.Customer;

import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.business.R;

/*
 * author:zts
 * */
@SuppressLint("ResourceType")
public class ChoosePersonListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	public List<Customer> personList;
	public ImageLoader    imageLoader;
	public List<Customer> checkedPerson;
	private int checkMode;
	// 用来控制CheckBox的选中状况
	private static HashMap<Integer,Integer> isSelected;
	private String  selectPersonIDs;
	private JSONArray selectPersonArray;
	private DisplayImageOptions displayImageOptions;
	public ChoosePersonListAdapter(Context context, List<Customer> personList,int checkMode,String selectPersonIDs) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		this.personList = personList;
		isSelected = new HashMap<Integer,Integer>();
		this.selectPersonIDs=selectPersonIDs;
		if(selectPersonIDs!=null && !selectPersonIDs.equals("")){
			try {
				selectPersonArray=new JSONArray(this.selectPersonIDs);
			} catch (JSONException e) {
				
			}
		}
		initData();
		this.checkMode = checkMode;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return personList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		PersonItem personItem = null;
		if (convertView == null) {
			personItem = new PersonItem();
			convertView = layoutInflater.inflate(R.xml.person_list_item,null);
			personItem.personHeadImage = (ImageView) convertView.findViewById(R.id.person_headImage);
			personItem.personNameText = (TextView) convertView.findViewById(R.id.person_name);
			personItem.personTypeText=(TextView) convertView.findViewById(R.id.account_type_text);
			personItem.personCodeText = (TextView) convertView.findViewById(R.id.person_code);
			personItem.choosePersonCheckbox = (ImageButton) convertView.findViewById(R.id.choose_person_check_box);
			convertView.setTag(personItem);
		} else {
			personItem = (PersonItem) convertView.getTag();
		}
		final int p = position;
		personItem.choosePersonCheckbox.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Customer clickPerson = personList.get(p);
						if (getIsSelected().get(p)==0) {
							view.setBackgroundResource(R.drawable.select_btn);
							checkedPerson.add(clickPerson);
							getIsSelected().put(p,1);
							if (checkMode == 0) {
								for (int i = 0; i < personList.size(); i++) {
									if (i != p)
										getIsSelected().put(i,0);
								}
								Iterator<Customer> iterator = checkedPerson.iterator();
								while (iterator.hasNext()) {
									Customer removeCustomer = iterator.next();
									if (removeCustomer.getCustomerId() != clickPerson.getCustomerId())
										iterator.remove();
								}
							}

						} else if (getIsSelected().get(p)==1) {
							view.setBackgroundResource(R.drawable.no_select_btn);
							checkedPerson.remove(clickPerson);
							getIsSelected().put(p,0);
						}
						ChoosePersonListAdapter.this.notifyDataSetChanged();
					}
				});
		
		if (getIsSelected().get(position)==1)
			personItem.choosePersonCheckbox.setBackgroundResource(R.drawable.select_btn);
		else if (getIsSelected().get(position)==0)
			personItem.choosePersonCheckbox.setBackgroundResource(R.drawable.no_select_btn);
		personItem.personNameText.setText(personList.get(position).getCustomerName());
		//accountType=0 专属顾问   accountType==1  销售顾问  2：普通账户
		int accountType=personList.get(position).getAccountType();
		if(accountType==0){
			personItem.personTypeText.setText("(专属顾问)");
		}
		else if(accountType==1){
			personItem.personTypeText.setText("(销售顾问)");
		}
		else
			personItem.personTypeText.setText("");
		imageLoader.displayImage(personList.get(position).getHeadImageUrl(),personItem.personHeadImage,displayImageOptions);
		personItem.personCodeText.setText(personList.get(position).getAccountCode());
		if (checkedPerson.size() != personList.size()) {
			((Activity) context).findViewById(R.id.select_all_person_checkbox).setBackgroundResource(R.drawable.no_select_all_btn);
		} else if(checkedPerson.size()== personList.size()){
			((Activity) context).findViewById(R.id.select_all_person_checkbox).setBackgroundResource(R.drawable.select_all_btn);
		}
		return convertView;
	}

	// 初始化isSelected的数据
	private void initData() {
		checkedPerson = new ArrayList<Customer>();
		for (int i = 0; i < personList.size(); i++) {
			int accountID=personList.get(i).getCustomerId();
			if(selectPersonArray!=null && selectPersonArray.length()>0){
				for(int j=0;j<selectPersonArray.length();j++){
					int personID=0;
					try {
						personID=selectPersonArray.getInt(j);
					} catch (JSONException e) {
						e.printStackTrace();
					}
					if(personID!=0 && personID==accountID){
							checkedPerson.add(personList.get(i));
							getIsSelected().put(i,1);
					}
					else{
						if(!getIsSelected().containsKey(i))
							getIsSelected().put(i,0);
					}
				}
			}
			else{
				getIsSelected().put(i,0);
			}
		}
	}

	public static HashMap<Integer,Integer> getIsSelected() {
		return isSelected;
	}

	public static void setIsSelected(HashMap<Integer,Integer> isSelected) {
		ChoosePersonListAdapter.isSelected = isSelected;
	}

	public final class PersonItem {
		public ImageView personHeadImage;
		public TextView personNameText;
		public TextView personTypeText;
		public TextView personCodeText;
		public ImageButton choosePersonCheckbox;
	}

}
