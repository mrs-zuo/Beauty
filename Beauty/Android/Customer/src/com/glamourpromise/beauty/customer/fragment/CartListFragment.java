package com.glamourpromise.beauty.customer.fragment;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.OrderConfirmActivity;
import com.glamourpromise.beauty.customer.adapter.CartListAdapter;
import com.glamourpromise.beauty.customer.adapter.CartListAdapter.ListItemClick;
import com.glamourpromise.beauty.customer.base.BaseFragment;
import com.glamourpromise.beauty.customer.bean.BranchCartInfo;
import com.glamourpromise.beauty.customer.bean.CartInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class CartListFragment extends BaseFragment implements OnClickListener, IConnectTask{
	private static final String CATEGORY_NAME = "Cart";
	private static final String GET_CART_LIST = "getCartList";
	private static final String DELETE_CART = "deleteCart";
	private static final String UPDATE_CART = "UpdateCart";
	private static final int GET_LIST_TASK_FLAG = 1;
	private static final int DELETE_TASK_FLAG = 2;
	private static final int UPDATE_TASK_FLAG = 3;
	private int taskFlag;
	//购物车列表
	private List<CartInformation> cartInformationList;
	//需要删除的列表
	private List<CartInformation> deleteCartList;
	//转成订单时，选择的ID
	private ArrayList<String> selectIDList;
	//列表显示的控件
	private ListView cartListView;
	//适配器
	private CartListAdapter cartListAdapter;
	//结算或者删除按钮
	private Button      estimateView;
	//listView点击的回掉方法
	private ListItemClick listItemClick;
	private int updateQuantityPosition;
	private int newCount;
	private List<Boolean> deleteItemSelectFlag;
	public  double totalPrice;
	private JSONArray mNeededDeleteIds;
	private String mNeededUpdateCartID;
	private int mNeededUpdateCartBranchID;
	private String mNeededUpdateCommodityCode;
	//编辑数量的弹出框
	private AlertDialog editQuantityDialog;
	private int currentOnClickCount;
	//当处于结算状态时，则显示所选购物的总价格
	private TextView cartTotalSalePriceText;
	private int      editOrDeleteFlag;//处于结算还是删除状态  1：结算  2：删除
	private Boolean isAllItemSelect;//全选标记
	private ImageView selectAllBtn;
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		super.onCreateView(inflater, container, savedInstanceState);
		View cartView = inflater.inflate(R.xml.cart_list_fragment_layout,container,false);
		cartListView = (ListView)cartView.findViewById(R.id.cart_list);
		estimateView = (Button)cartView.findViewById(R.id.estimate);
		cartTotalSalePriceText=(TextView)cartView.findViewById(R.id.cart_total_sale_price_text);
		selectAllBtn=(ImageView)cartView.findViewById(R.id.cart_list_select_all);
		selectAllBtn.setBackgroundResource(R.drawable.one_unselect_icon);
		isAllItemSelect = false;
		//全选按钮
		selectAllBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				totalPrice = 0;
				if (isAllItemSelect) {
					isAllItemSelect = false;
					view.setBackgroundResource(R.drawable.one_unselect_icon);
				} else {
					isAllItemSelect = true;
					view.setBackgroundResource(R.drawable.one_select_icon);
					// 计算所有价格
					for (int i = 0; i < cartInformationList.size(); i++) {
						totalPrice += getCommoditySalePrice(i);
					}
				}
				if (cartListAdapter != null)
					cartListAdapter.setAllItemSelectStatus(isAllItemSelect);
				cartListAdapter.notifyDataSetChanged();
				if(editOrDeleteFlag==1){
					estimateView.setText("结算"+"("+cartListAdapter.getCurrentSelectCount()+")");
					cartTotalSalePriceText.setText("合计:"+NumberFormatUtil.currencyFormat(getActivity(),totalPrice));
				}
				else if(editOrDeleteFlag==2){
					estimateView.setText("删除"+"("+cartListAdapter.getCurrentSelectCount()+")");
				}
			}
		});
		initActivity();
		editOrDeleteFlag=1;
		submitTask(GET_LIST_TASK_FLAG);
		return cartView;
	}
	private void submitTask(int flag) {
		taskFlag = flag;
		super.asyncRefrshView(this);
	}
	
	/**
	 * 取消全选
	 */
	private void cancelSelectAllCart(){
		totalPrice = 0;
	}
	
	/**
	 * 初始化数据
	 */
	private void initActivity(){
		cancelSelectAllCart();
		estimateView.setOnClickListener(this);
		cartInformationList = new ArrayList<CartInformation>();
		deleteCartList = new ArrayList<CartInformation>();
		selectIDList = new ArrayList<String>();
		listItemClick = new ListItemClick() {
			@Override
			public void onClick(View clickView, int position) {
				switch (clickView.getId()) {
				case R.id.edit_commodity_count:
					updateQuantityPosition = position;
					UpdateCommodityCount(position);
					break;
				case R.id.commodity_item_select:
					updateTotalPrice(position);
					break;
				default:
					break;
				}
			}
			@Override
			public void branchCartSelect(double branchCartTotalPrice) {
				// TODO Auto-generated method stub
				calculateMoney(branchCartTotalPrice);
			}
			@Override
			public void allCommoditySelectProcess(int currentSelectCount) {
				// TODO Auto-generated method stub
				//判断是否全选，若全部已选择则更新全选按钮的图标
				if(currentSelectCount == cartInformationList.size()){
					selectAllBtn.setBackgroundResource(R.drawable.one_select_icon);
					isAllItemSelect = true;
				}else{
					selectAllBtn.setBackgroundResource(R.drawable.one_unselect_icon);
					isAllItemSelect = false;
				}
				if(editOrDeleteFlag==1){
					estimateView.setText("结算"+"("+cartListAdapter.getCurrentSelectCount()+")");
					cartTotalSalePriceText.setText("合计:"+NumberFormatUtil.currencyFormat(getActivity(),totalPrice));
				}
				else if(editOrDeleteFlag==2){
					estimateView.setText("删除"+"("+cartListAdapter.getCurrentSelectCount()+")");
				}
			}
		};
	}

	//获取每个商品的最终售价
	private double getCommoditySalePrice(int position){
		double price = cartInformationList.get(position).getTotalSalePrice().doubleValue();
		return price;
	}
	
	/**
	 * 
	 * @param cartList
	 * @return
	 */
	@SuppressLint("UseSparseArrays")
	private HashMap<Integer, BranchCartInfo> createBranchInfoList(List<CartInformation> cartList){
		//按branchID分组
		HashMap<Integer, ArrayList<CartInformation>> branchCartList = new HashMap<Integer, ArrayList<CartInformation>>();
		HashSet<Integer> branchIDSet = new HashSet<Integer>();
		//保存分公司的订单信息
		HashMap<Integer, BranchCartInfo> branchCartInfoList = new HashMap<Integer, BranchCartInfo>();
		
		
		ArrayList<CartInformation> tmpArrayList;
		BranchCartInfo tmpBranchCartInfo;
		CartInformation currentCart;
		int currentBranchID;
		Iterator<Integer> branchIDIterator;
		for(int i = 0; i < cartList.size(); i++){
			currentCart = cartList.get(i);
			currentBranchID = currentCart.getBranchID();
			branchIDSet.add(currentBranchID);
			tmpArrayList = branchCartList.get(currentBranchID);
			if(tmpArrayList == null){
				tmpArrayList = new ArrayList<CartInformation>();
				branchCartList.put(currentBranchID, tmpArrayList);
			}
			tmpArrayList.add(currentCart);
		}
		
		cartList.clear();
		branchIDIterator = branchIDSet.iterator();
		Integer branchID;
		int pos=0;
		while (branchIDIterator.hasNext()) {
			branchID = (Integer) branchIDIterator.next();
			tmpArrayList = branchCartList.get(branchID);
			tmpBranchCartInfo = new BranchCartInfo();
			tmpBranchCartInfo.setBranchID(branchID);
			tmpBranchCartInfo.setCartListPostion(pos);
			pos += tmpArrayList.size();
			tmpBranchCartInfo.setSize(tmpArrayList.size());
			for(CartInformation cartItem:tmpArrayList){
				if(cartItem.getAvailableFlag()){
					tmpBranchCartInfo.addAvailableSize();
				}
			}
			branchCartInfoList.put(branchID, tmpBranchCartInfo);
			cartList.addAll(tmpArrayList);
		}
		return branchCartInfoList;
	}

	/**
	 * 显示修改数量的对话框
	 * @param position
	 */
	private void UpdateCommodityCount(int position) {
		currentOnClickCount = position;
		if(editQuantityDialog == null){
			final EditText editText = new EditText(getActivity());
			editText.setInputType(InputType.TYPE_CLASS_NUMBER);
			editText.setSingleLine();
			editQuantityDialog = new AlertDialog.Builder(getActivity())
					.setTitle("请输入商品数量")
					.setIcon(android.R.drawable.ic_dialog_info)
					.setView(editText)
					.setPositiveButton("确定",
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub
									String input = editText.getText().toString();
									editText.setText("");
									handleUpdateCount(input);
								}
							})
					.setNegativeButton("取消", null)
					.create();
		}
		
		editQuantityDialog.show();
	}
	
	/**
	 * 处理修改数量的输入
	 * @param input
	 */
	private void handleUpdateCount(String input){
		//输入不为0， 向服务器提交新数量
		if(!input.equals("") && !input.equals("0")){
			newCount = Integer.valueOf(input);
			mNeededUpdateCartID = cartInformationList.get(currentOnClickCount).getCartID();
			mNeededUpdateCartBranchID = cartInformationList.get(currentOnClickCount).getBranchID();
			mNeededUpdateCommodityCode = cartInformationList.get(currentOnClickCount).getProductCode();
			submitTask(UPDATE_TASK_FLAG);
		}
		//输入为0，提示是否删除该商品
		else if(!input.equals("") && input.equals("0"))
			createDeleteCommodityDialog(currentOnClickCount);
	}
	
	/**
	 * 提示是否删除商品
	 * @param position
	 */
	private void createDeleteCommodityDialog(int position){
		final int ps = position;
		new AlertDialog.Builder(getActivity()).setTitle("是否删除该服务/商品？")
		.setIcon(android.R.drawable.ic_dialog_info)
		.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				// TODO Auto-generated method stub
				cartListAdapter.getIsSelected().set(ps, true);
				deleteCartList();
			}
		}).setNegativeButton("取消", null).show();
	}


	private void calculateMoney(double unitPrice) {
		totalPrice += unitPrice;
		if(editOrDeleteFlag==1){
			estimateView.setText("结算"+"("+cartListAdapter.getCurrentSelectCount()+")");
			cartTotalSalePriceText.setText("合计:"+NumberFormatUtil.currencyFormat(getActivity(),totalPrice));
		}
		else if(editOrDeleteFlag==2){
			estimateView.setText("删除"+"("+cartListAdapter.getCurrentSelectCount()+")");
		}
	}
	//flag 1:设置成编辑状态  即出现删除按钮  2：设置完成状态  即出现结算按钮
	public void  setEditStatus(int flag){
		if(flag==1){
			cartTotalSalePriceText.setVisibility(View.GONE);
			estimateView.setBackgroundResource(R.drawable.cancel_btn_red);
			estimateView.setText("删除"+"("+cartListAdapter.getCurrentSelectCount()+")");
			editOrDeleteFlag=2;
		}
		else if(flag==2){
			estimateView.setBackgroundResource(R.drawable.shape_btn);
			estimateView.setText("结算"+"("+cartListAdapter.getCurrentSelectCount()+")");
			cartTotalSalePriceText.setVisibility(View.VISIBLE);
			cartTotalSalePriceText.setText("合计:"+NumberFormatUtil.currencyFormat(getActivity(),totalPrice));
			editOrDeleteFlag=1;
		}
	}
	@SuppressLint("CommitPrefEdits")
	@Override
	public void onClick(View view) {
		Animation aniClick = AnimationUtils.loadAnimation(getActivity(),R.anim.anim_button_click);
		view.startAnimation(aniClick);
		switch (view.getId()) {
		case R.id.estimate:
			if(editOrDeleteFlag==1){
				taskFlag=UPDATE_TASK_FLAG;
			}
			else if(editOrDeleteFlag==2){
				taskFlag=DELETE_TASK_FLAG;
			}
			if(taskFlag==UPDATE_TASK_FLAG){
				List<CartInformation> selectCartList = new ArrayList<CartInformation>();
				selectIDList = new ArrayList<String>();
				for (int i = 0; i < cartInformationList.size(); i++) {
					if (cartListAdapter.getIsSelected().get(i)){
						selectIDList.add(cartInformationList.get(i).getCartID());
						selectCartList.add(cartInformationList.get(i));
					}	
				}
				
				if (selectCartList.size() == 0)
					DialogUtil.createShortDialog(getActivity(),"服务/商品不能为空");
				else {
					Intent destIntent = new Intent(getActivity(),OrderConfirmActivity.class);
					Bundle mBundle = new Bundle();
					mBundle.putSerializable("selectCartList",(Serializable) selectCartList);
					destIntent.putExtras(mBundle);
					startActivity(destIntent);
				}
			}
			else if(taskFlag==DELETE_TASK_FLAG){
				int count = cartListAdapter.getCurrentSelectCount();
				if(count == 0){
					DialogUtil.createShortDialog(getActivity(),"请先选择需要删除的服务/商品！");
				}else{
					AlertDialog paymentDialog = new AlertDialog.Builder(getActivity())
					.setTitle("是否删除已选择的商品")
					.setPositiveButton(getString(R.string.confirm),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface arg0,int arg1) {
									// TODO Auto-generated method stub
									deleteCartList();
								}
							})
					.setNegativeButton(getString(R.string.cancel), null).show();
					paymentDialog.setCancelable(false);
				}
			}
			break;
		}
	}
	/**
	 * 删除商品处理
	 */
	private void deleteCartList(){
		boolean hasDeleteCart = false;
		if(deleteCartList != null)
			deleteCartList.clear();
		if(deleteItemSelectFlag != null)
			deleteItemSelectFlag.clear();
		else
			deleteItemSelectFlag = new ArrayList<Boolean>();

		mNeededDeleteIds = new JSONArray();
		JSONObject id;
		for (int i = 0; i < cartInformationList.size(); i++) {
			if (cartListAdapter.getIsSelected().get(i)) {
				try {
					
					mNeededDeleteIds.put(cartInformationList.get(i).getCartID());
					hasDeleteCart = true;
					deleteCartList.add(cartInformationList.get(i));
					deleteItemSelectFlag.add(cartListAdapter.getIsSelected().get(i));
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}

		if (hasDeleteCart){
			submitTask(DELETE_TASK_FLAG);
		}
	}

	
	public void updateTotalPrice(int position){
		double price = getCommoditySalePrice(position);
		//取消选择时，将价格变成负数
		if(!cartListAdapter.getIsSelected().get(position)){
			price = -price;
		}
		calculateMoney(price);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		String catoryName = CATEGORY_NAME;
		String methodName = "";
		String strPara = "";
		if(taskFlag == GET_LIST_TASK_FLAG){
			methodName = GET_CART_LIST;
			strPara = "";
		}else if(taskFlag == DELETE_TASK_FLAG){
			methodName = DELETE_CART;
			
			try {
				para.put("CartIDList",mNeededDeleteIds);
				strPara = para.toString();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(taskFlag == UPDATE_TASK_FLAG){
			methodName = UPDATE_CART;
			try {
				para.put("CommodityCode", mNeededUpdateCommodityCode);
				para.put("CartID", mNeededUpdateCartID);
				para.put("Quantity", newCount);
				para.put("BranchID", mNeededUpdateCartBranchID);
				strPara = para.toString();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, strPara);
		WebApiRequest request = new WebApiRequest(catoryName, methodName, strPara, header);
		return request;	
		}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == GET_LIST_TASK_FLAG){
					handleListTask(response);
					taskFlag=UPDATE_TASK_FLAG;
				}else if(taskFlag == DELETE_TASK_FLAG){
					handleDeleteTask(response.getMessage());
				}else if(taskFlag == UPDATE_TASK_FLAG){
					
					handleUpdateTask(response.getMessage());
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case 2:
				DialogUtil.createShortDialog(getActivity(),response.getMessage());
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getActivity(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getActivity(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
	}

	private void handleUpdateTask(String message) {
		// TODO Auto-generated method stub
		cartInformationList.get(updateQuantityPosition).setQuantity(newCount);
		cartListAdapter.changeCommodityCount(updateQuantityPosition, newCount);
		cartListAdapter.notifyDataSetChanged();
		// 修改结算
		totalPrice = 0;
		for (int i = 0; i < cartInformationList.size(); i++) {
			if (cartListAdapter.getIsSelected().get(i)){
				totalPrice += getCommoditySalePrice(i);
			}
		}
		if(editOrDeleteFlag==1){
			estimateView.setText("结算"+"("+cartListAdapter.getCurrentSelectCount()+")");
			cartTotalSalePriceText.setText("合计:"+NumberFormatUtil.currencyFormat(getActivity(),totalPrice));
		}
		else if(editOrDeleteFlag==2){
			estimateView.setText("删除"+"("+cartListAdapter.getCurrentSelectCount()+")");
		}
		DialogUtil.createShortDialog(getActivity(),message);
	}

	private void handleDeleteTask(String data) {
		// TODO Auto-generated method stub
		//移除已经删除的商品
		cartInformationList.removeAll(deleteCartList);
		//生成新的分店商品信息
		HashMap<Integer, BranchCartInfo> branchCartInfoList = createBranchInfoList(cartInformationList);
		cartListAdapter.setBranchCartInfoList(branchCartInfoList);
		deleteCartList.clear();
		//移除已经删除商品的选择信息
		cartListAdapter.getIsSelected().removeAll(deleteItemSelectFlag);
		cartListAdapter.setCurrentSelectCount();
		cartListAdapter.notifyDataSetChanged();
		totalPrice = 0;
		calculateMoney(0);
		DialogUtil.createShortDialog(getActivity(),data);
		super.dismissProgressDialog();
	}

	private void handleListTask(WebApiResponse response) {
		// TODO Auto-generated method stub
		//服务器的数据
		List<CartInformation> cartList = (List<CartInformation>) response.mData;		
		//保存分公司的订单信息
		HashMap<Integer, BranchCartInfo> branchCartInfoList = createBranchInfoList(cartList);
		//从新加入分组后的数据
		cartInformationList.clear();
		cartInformationList.addAll(cartList);
		//生成新的适配器
		cartListAdapter = new CartListAdapter(getActivity(),cartInformationList,listItemClick,branchCartInfoList);
		selectIDList.clear();
		cartListView.setAdapter(cartListAdapter);
		estimateView.setText("结算"+"("+0+")");
		cartTotalSalePriceText.setText("合计:"+NumberFormatUtil.currencyFormat(getActivity(),0));
		super.dismissProgressDialog();
	}
	private List<CartInformation> parseCartList(String data) {
		List<CartInformation> cartList = CartInformation.parseListByJson(data);
		return cartList;
	}
	@Override
	public void parseData(WebApiResponse response) {
		if(taskFlag == GET_LIST_TASK_FLAG){
			response.mData = parseCartList(response.getStringData());
		}
	}
}
