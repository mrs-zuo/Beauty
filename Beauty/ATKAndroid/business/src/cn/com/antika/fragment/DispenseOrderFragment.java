/**
 * DispenseOrderFragment.java
 * cn.com.antika.fragment
 * tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 * @version V1.0
 */
package cn.com.antika.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.DispenseOrderListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.business.PrepareOrderActivity;
import cn.com.antika.business.ProductAndOldOrderListActivity;
import cn.com.antika.business.R;
import cn.com.antika.util.DialogUtil;

/**
 * DispenseOrderFragment
 * 待开单的Fragment
 *
 * @author tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 */

@SuppressLint("ResourceType")
public class DispenseOrderFragment extends Fragment implements OnClickListener{
	private ListView   dispenseOrderListView;
	private List<OrderProduct> orderProductList;
	private UserInfoApplication userinfoApplication;
	private Button              prepareOrderBtn;
	private DispenseOrderListAdapter dispenseOrderListAdapter;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreateView(inflater, container, savedInstanceState);
		View dispenseOrderView=inflater.inflate(R.xml.dispense_order_fragment_layout,container,false);
		dispenseOrderListView=(ListView) dispenseOrderView.findViewById(R.id.dispense_order_list_view);
		orderProductList=new ArrayList<OrderProduct>();
		userinfoApplication=(UserInfoApplication)getActivity().getApplication();
		if (userinfoApplication.getOrderInfo() != null) {
			orderProductList = userinfoApplication.getOrderInfo().getOrderProductList();
		}
		dispenseOrderListAdapter = new DispenseOrderListAdapter(getActivity(), orderProductList);
		dispenseOrderListView.setAdapter(dispenseOrderListAdapter);
		prepareOrderBtn=(Button) dispenseOrderView.findViewById(R.id.prepare_order_btn);
		prepareOrderBtn.setOnClickListener(this);
		((TextView)getActivity().findViewById(R.id.tab_prepare_order_title)).setText("待开"+"("+orderProductList.size()+")");
		int authMyOrderWrite=userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
		if(authMyOrderWrite==0)
			prepareOrderBtn.setVisibility(View.GONE);
		return dispenseOrderView;
	}
	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
	}
	@Override
	public void setUserVisibleHint(boolean isVisibleToUser) {
		// TODO Auto-generated method stub
		super.setUserVisibleHint(isVisibleToUser);
		if(isVisibleToUser && dispenseOrderListView!=null){
			((TextView)getActivity().findViewById(R.id.tab_prepare_order_title)).setText("待开"+"("+orderProductList.size()+")");
			dispenseOrderListAdapter.setmOrderProductList(orderProductList);
			dispenseOrderListAdapter.notifyDataSetChanged();
		}	
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if(view.getId()==R.id.prepare_order_btn){
			if(userinfoApplication.getSelectedCustomerID()==0){
				DialogUtil.createShortDialog(getActivity(),"请先选择顾客!");
			}
			else if(orderProductList==null || orderProductList.size()==0){
				DialogUtil.createShortDialog(getActivity(),"请选择订单！");
			}
			else{
				boolean hasNewAddOrder=false;
				for(OrderProduct op:orderProductList){
					if(!op.isOldOrder())
						hasNewAddOrder=true;
				}
				//如果有新单，则跳转到开新单的界面
				if(hasNewAddOrder){
					Intent destIntent=new Intent(getActivity(),PrepareOrderActivity.class);
					destIntent.putExtra("FROM_SOURCE","MENU");
					startActivity(destIntent);
				}
				//全部是老单的话 则跳转到开小单的界面
				else{
					Intent destIntent=new Intent(getActivity(),ProductAndOldOrderListActivity.class);
					Bundle bundle=new Bundle();
					ArrayList<String> orderIDsList=new ArrayList<String>();
					for(OrderProduct op:orderProductList){
						orderIDsList.add(String.valueOf(op.getOldOrderID()));
					}
					bundle.putStringArrayList("orderIdList",orderIDsList);
					destIntent.putExtras(bundle);
					startActivity(destIntent);
				}
			}
		}
	}

}
