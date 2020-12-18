package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.ViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CommodityDetailInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.OrigianlImageView;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.presenter.LeftMenuPresenter;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;
public class CommodityDetailActivity extends BaseActivity implements OnClickListener, IConnectTask{
	private static final String CATEGORY_NAME = "Cart";
	private static final String ADD_CART = "addCart";
	private static final String COMMODITY_CATEGORY_NAME = "Commodity";
	private static final String GET_COMMODITY_DETAIL = "getCommodityDetailByCommodityCode";
	private static final String ADD_FAVORITE_CATEGORY_NAME = "Customer";
	private static final String ADD_FAVORITE = "AddFavorite";
	private static final String CANCEL_FAVORITE = "DelFavorite";
	private static final int GET_COMMODITY_TASK_FLAG = 1;
	private static final int ADD_CART_FLAG = 2;
	private static final int ADD_FAVORITE_FLAG = 3;
	private static final int CANCEL_FAVORITE_FLAG = 4;
	private static final int ADD_ORDER_FLAG = 5;
	private int taskFlag;
	private String commodityCode;
	private LayoutInflater mLayoutInflater;
	private CommodityDetailInformation commodityInformation;
	private List<View> mViewList = new ArrayList<View>();
	private HashMap<String, Boolean> branchSelectFlagMap;
	private String lastSelectBranchID;
	private View childView;
	private ViewPager viewPager;
	private ViewPagerAdapter PagerAdapter;
	private ImageView arrowRight;
	private ImageView arrowLeft;
	private Button      addCommodityToCart,addCommodityToOrder;
	private TableLayout productEnalbeInfoLayout;
	private int imageCount;
	private ProgressDialog progressDialog;
	private ImageButton  addCommodityToFavoriteBtn;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_commodity_detail);
		super.setTitle(getString(R.string.title_commodity_detail));
		Intent intent = getIntent();
		commodityCode = intent.getStringExtra("CommodityCode");
		mLayoutInflater = getLayoutInflater();
		arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
		arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
		addCommodityToCart = (Button) findViewById(R.id.add_cart_button);
		addCommodityToCart.setOnClickListener(this);
		productEnalbeInfoLayout = (TableLayout) findViewById(R.id.product_enalbe_info_layout);
		addCommodityToFavoriteBtn=(ImageButton)findViewById(R.id.add_favorite_button);
		addCommodityToFavoriteBtn.setOnClickListener(this);
		findViewById(R.id.add_favorite_relativelayout).setOnClickListener(this);
		addCommodityToOrder=(Button)findViewById(R.id.add_order_button);
		addCommodityToOrder.setOnClickListener(this);
		super.showProgressDialog();
		taskFlag = GET_COMMODITY_TASK_FLAG;
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	
	private void createProductEnalbeInfoLayout(ArrayList<HashMap<String, String>> productEnalbeInfoList){
		productEnalbeInfoLayout.removeViews(1,productEnalbeInfoLayout.getChildCount()-1);
		TextView branchNameView;
		TextView stockCalcTypeView;
		for(HashMap<String, String> item:productEnalbeInfoList){
			RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.commodity_in_branch_detail_item, null);
			branchNameView = (TextView) contentLayout.findViewById(R.id.branch_name);
			branchNameView.setText(item.get("BranchName"));
			stockCalcTypeView = (TextView) contentLayout.findViewById(R.id.stock_calc_type);
			ImageButton selectButton = (ImageButton) contentLayout.findViewById(R.id.branch_select);
			selectButton.setTag(item.get("BranchID"));
			OnClickListener clickListener = getBranchSelectListener();
			String stockType = item.get("StockCalcType");
			//正常库存
			if(stockType.equals("1")){
				int quantity = Integer.valueOf(item.get("Quantity"));
				//库存小于1
				if(quantity <= 0){
					stockCalcTypeView.setText("暂无库存");
					selectButton.setVisibility(View.INVISIBLE);
				}
				//库存大于0
				else{
					stockCalcTypeView.setText("库存" + item.get("Quantity") + "件");
					//只有一家分店提供该商品
					if(productEnalbeInfoList.size() == 1){
						selectButton.setBackgroundResource(R.drawable.one_select_icon);
						lastSelectBranchID = (String) selectButton.getTag();
					}else if(productEnalbeInfoList.size() > 1){
						selectButton.setOnClickListener(clickListener);
					}
				}
			}
			//不计库存
			else if(stockType.equals("2")){
				stockCalcTypeView.setText("可售");
				selectButton.setOnClickListener(clickListener);
				if(productEnalbeInfoList.size() == 1){
					selectButton.setBackgroundResource(R.drawable.one_select_icon);
					selectButton.setOnClickListener(null);
					lastSelectBranchID = (String) selectButton.getTag();
				}
			}
			//允许超卖
			else if(stockType.equals("3")){
				stockCalcTypeView.setText("可售");
				selectButton.setOnClickListener(clickListener);
				if(productEnalbeInfoList.size() == 1){
					selectButton.setBackgroundResource(R.drawable.one_select_icon);
					selectButton.setOnClickListener(null);
					lastSelectBranchID = (String) selectButton.getTag();
				}
			}
			
			
			productEnalbeInfoLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			productEnalbeInfoLayout.addView(contentLayout);
		}
	}
	
	private OnClickListener getBranchSelectListener(){
		OnClickListener clickListener = new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				String branchID = (String) v.getTag();
				if(branchSelectFlagMap.get(branchID) == null || !branchSelectFlagMap.get(branchID)){
					branchSelectFlagMap.put(branchID, true);
					v.setBackgroundResource(R.drawable.one_select_icon);
					if(!lastSelectBranchID.equals("0") && lastSelectBranchID != branchID){
						branchSelectFlagMap.put(lastSelectBranchID, false);
						int size = productEnalbeInfoLayout.getChildCount();
						View view;
						View button;
						for(int i = 0; i <size; i++){
							view = productEnalbeInfoLayout.getChildAt(i);
							button = view.findViewById(R.id.branch_select);
							
							if(button != null && ((String) button.getTag()).equals(lastSelectBranchID)){
								button.setBackgroundResource(R.drawable.one_unselect_icon);
							}
						}
					}
					lastSelectBranchID = branchID;
				}else if(branchSelectFlagMap.get(branchID)){
					branchSelectFlagMap.put(branchID, false);
					lastSelectBranchID = "0";
					v.setBackgroundResource(R.drawable.one_unselect_icon);
				}
			}
		};
		return clickListener;
	}
	
	private void CreateCommodityImageView(ArrayList<String> urlList) {
		if(mViewList==null)
			mViewList=new ArrayList<View>();
		else
			mViewList.clear();
		childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
		

		if (urlList.size() == 0) {
			RelativeLayout imageLayout = (RelativeLayout) findViewById(R.id.image_layout);
			imageLayout.setVisibility(View.GONE);
		} else {
			for (int i = 0; i < urlList.size(); i++) {
				childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
				final ImageView companyImage = (ImageView) childView.findViewById(R.id.company_image);
				final String imageURL=urlList.get(i);
				companyImage.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						String originalImageUrl=imageURL.split("&")[0];
						new OrigianlImageView(CommodityDetailActivity.this,companyImage,originalImageUrl).showOrigianlImage();
					}
				});
				Picasso.with(getApplicationContext()).load(urlList.get(i)).error(R.drawable.commodity_image_null).into(companyImage);
				mViewList.add(childView);
			}
			createCommodityViewPager(mViewList);
		}

	}

	private void CreateCommodityNameTableRow() {
		TextView commodityName = (TextView) findViewById(R.id.commodity_name_text);
		commodityName.setText(commodityInformation.getName());

		TextView commoditySpecification = (TextView) findViewById(R.id.specification_content_text);
		// 没有规格时
		if (commodityInformation.getSpecification()==null|| commodityInformation.getSpecification().equals("")) {
			commoditySpecification.setText("无");
		} else {
			commoditySpecification.setText(commodityInformation.getSpecification());
		} 
	}

	private void CreateCommodityPriceTableRow() {
		TextView commodityUnitPrice = (TextView) findViewById(R.id.unit_price_content_text);
		String tmpUnitPrice = commodityInformation.getUnitPrice();
		commodityUnitPrice.setText(NumberFormatUtil.StringFormatToString(this, tmpUnitPrice));
	}

	private void CreateCommodityIntroudction() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.commodity_introduction);

		if (!commodityInformation.getDescribe().equals("")) {
			TextView commodityIntroduction = (TextView) findViewById(R.id.introduction_text);
			commodityIntroduction.setText(commodityInformation.getDescribe());
		} else {
			tableLayout.setVisibility(View.GONE);
		}
	}

	private void createCommodityViewPager(List<View> mViewList) {
		imageCount = mViewList.size();
		arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
		if (imageCount == 1)
			arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
		else 
			arrowRight.setBackgroundResource(R.drawable.arrow_right_red);

		viewPager = (ViewPager) findViewById(R.id.commodity_image_viewpager);
		PagerAdapter = new ViewPagerAdapter(mViewList);
		viewPager.setAdapter(PagerAdapter);
		viewPager.setOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageSelected(int position) {
				if (position == 0) {
					arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
				} else {
					arrowLeft.setBackgroundResource(R.drawable.arrow_left_red);
				}
				if (position == imageCount - 1) {
					arrowRight
							.setBackgroundResource(R.drawable.arrow_right_gray);
				} else {
					arrowRight
							.setBackgroundResource(R.drawable.arrow_right_red);
				}
			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onPageScrollStateChanged(int arg0) {
				// TODO Auto-generated method stub

			}
		});

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.add_cart_button:
			if(lastSelectBranchID.equals("0")){
				DialogUtil.createShortDialog(this, "请选择购买门店");
			}else{
				addCommodityToCart();
			}
			break;
		case R.id.add_order_button:
			if(lastSelectBranchID.equals("0")){
				DialogUtil.createShortDialog(this, "请选择购买门店");
			}else{
				addCommodityToOrder();
			}
			break;
		case R.id.add_favorite_relativelayout:
			addCommodityToFavorite();
			break;
		case R.id.add_favorite_button:
			addCommodityToFavorite();
			break;
		}
	}

	
	private void addCommodityToCart() {
		if (progressDialog == null) {
			progressDialog = new ProgressDialog(this);
		}
		progressDialog.setMessage("正在添加购物车。。。");
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.show();
		progressDialog.setCancelable(false);
		taskFlag = ADD_CART_FLAG;
		super.asyncRefrshView(this);
	}
	private void addCommodityToOrder(){
		if (progressDialog == null) {
			progressDialog = new ProgressDialog(this);
		}
		progressDialog.setMessage("正在添加购物车。。。");
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.show();
		progressDialog.setCancelable(false);
		taskFlag = ADD_ORDER_FLAG;
		super.asyncRefrshView(this);
	}
	private void addCommodityToFavorite() {
		String mFavoriteID=commodityInformation.getmFavoriteID();
		if(mFavoriteID!=null && !mFavoriteID.equals(""))
			taskFlag = CANCEL_FAVORITE_FLAG;
		else
			taskFlag = ADD_FAVORITE_FLAG;
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if(taskFlag == GET_COMMODITY_TASK_FLAG){
			catoryName = COMMODITY_CATEGORY_NAME;
			methodName = GET_COMMODITY_DETAIL;
			try {
				para.put("CustomerID", mCustomerID);
				para.put("ProductCode", commodityCode);
				para.put("ImageHeight", String.valueOf(400));
				para.put("ImageWidth", String.valueOf(400));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(taskFlag==ADD_CART_FLAG){
			catoryName = CATEGORY_NAME;
			methodName = ADD_CART;
			try {
				para.put("ProductCode",commodityCode);
				para.put("Quantity",1);
				para.put("ProductType",1);
				para.put("BranchID",lastSelectBranchID);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else if(taskFlag==ADD_FAVORITE_FLAG){
			catoryName =ADD_FAVORITE_CATEGORY_NAME;
			methodName = ADD_FAVORITE;
			try {
				para.put("ProductType",1);
				para.put("ProductCode",commodityCode);
			} catch (JSONException e) {
			}
		}
		else if(taskFlag==CANCEL_FAVORITE_FLAG){
			catoryName =ADD_FAVORITE_CATEGORY_NAME;
			methodName = CANCEL_FAVORITE;
			try {
				para.put("UserFavoriteID",commodityInformation.getmFavoriteID());
			} catch (JSONException e) {
			}
		}
		else if(taskFlag==ADD_ORDER_FLAG){
			catoryName = CATEGORY_NAME;
			methodName = ADD_CART;
			try {
				para.put("ProductCode",commodityCode);
				para.put("Quantity",1);
				para.put("ProductType",1);
				para.put("BranchID",lastSelectBranchID);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(progressDialog != null)
			progressDialog.dismiss();
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == GET_COMMODITY_TASK_FLAG){
					commodityInformation = (CommodityDetailInformation) response.mData;
					imageCount = commodityInformation.getImageCount();
					ArrayList<String> urlList = commodityInformation.getCommodityImageURLList();
					if (urlList.size() == 0) {
						RelativeLayout imageLayout = (RelativeLayout) findViewById(R.id.image_layout);
						imageLayout.setVisibility(View.GONE);
					} else {
						CreateCommodityImageView(urlList);
					}
					CreateCommodityNameTableRow();
					CreateCommodityPriceTableRow();
					CreateCommodityIntroudction();
					ArrayList<HashMap<String, String>> productEnalbeInfoList = commodityInformation.getProductEnalbeInfoMap();
					if(productEnalbeInfoList != null){
						lastSelectBranchID = "0";
						branchSelectFlagMap = new HashMap<String, Boolean>();
						createProductEnalbeInfoLayout(productEnalbeInfoList);
					}
					String mFavoriteID=commodityInformation.getmFavoriteID();
					if(mFavoriteID!=null && !mFavoriteID.equals(""))
						addCommodityToFavoriteBtn.setBackgroundResource(R.drawable.favorite_icon);
					else
						addCommodityToFavoriteBtn.setBackgroundResource(R.drawable.un_favorite_icon);
				}else if(taskFlag==ADD_CART_FLAG){
					LeftMenuPresenter.getInstace(mApp).addCartCount(1);
					DialogUtil.createShortDialog(this,response.getMessage());
				}
				else if(taskFlag==ADD_FAVORITE_FLAG || taskFlag==CANCEL_FAVORITE_FLAG){
					DialogUtil.createShortDialog(this,response.getMessage());
					taskFlag = GET_COMMODITY_TASK_FLAG;
					super.asyncRefrshView(this);
				}
				else if(taskFlag==ADD_ORDER_FLAG){
					LeftMenuPresenter.getInstace(mApp).addCartCount(1);
					DialogUtil.createShortDialog(this,response.getMessage());
					Intent destIntent=new Intent(this,NavigationNew.class);
					destIntent.putExtra("NavigationType",2);
					startActivity(destIntent);
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
	}

	@Override
	public void parseData(WebApiResponse response) {
		if(taskFlag == GET_COMMODITY_TASK_FLAG){
			CommodityDetailInformation commodity = new CommodityDetailInformation();
			commodity.parseByJson(response.getStringData());
			response.mData = commodity;
		}
	}
}
