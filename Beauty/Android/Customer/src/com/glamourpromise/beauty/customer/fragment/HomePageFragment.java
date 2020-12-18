package com.glamourpromise.beauty.customer.fragment;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.BranchPromotionActivity;
import com.glamourpromise.beauty.customer.activity.CommodityCategoryListActivity;
import com.glamourpromise.beauty.customer.activity.CommodityDetailActivity;
import com.glamourpromise.beauty.customer.activity.CompanyActivity;
import com.glamourpromise.beauty.customer.activity.PromotionDetailActivity;
import com.glamourpromise.beauty.customer.activity.RemindListActivity;
import com.glamourpromise.beauty.customer.activity.ServiceCategoryListActivity;
import com.glamourpromise.beauty.customer.activity.ServiceDetailActivity;
import com.glamourpromise.beauty.customer.adapter.RecommendListAdapter;
import com.glamourpromise.beauty.customer.adapter.ViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseFragment;
import com.glamourpromise.beauty.customer.bean.PromotionDetail;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.squareup.picasso.Picasso;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView.ScaleType;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
/**
 * HomePageFragment  首页碎片
 */
public class HomePageFragment extends BaseFragment implements OnClickListener,IConnectTask,OnItemClickListener{
	private ViewPager      topPromotionViewPager;
	private View           topPromotionChildView;
	private LayoutInflater layoutInflater;
	private List<View>     mViewList;
	private ViewPagerAdapter topPromotionViewPagerAdapter;
	private List<ImageView>  pointViews;
	private LinearLayout     pointLinearlayout,promotionListLinearlayout;
	private List<PromotionDetail>  topPromotionList,promotionList;
	private int              currentItem=0;
	private ScheduledExecutorService scheduledExecutorService;
	private GridView          recommendGridView;
	private List<ServiceInformation> recommendList;
	private RelativeLayout    navigationService,navigationCommodity,navigationCompany,navigationRemind;
	private TextView          promotionMoreText;
	private int               taskType=1;
	private String            PROMOTION_CATEGORY_NAME="Promotion",RECOMMEND_CATEGORY_NAME="Commodity";
	private String            PROMOTION_METHOD_NAME="GetPromotionList",RECOMMEND_METHOD_NAME="getRecommendedProductList";
	private View homePageView;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreateView(inflater, container, savedInstanceState);
		homePageView= inflater.inflate(R.xml.home_page_fragment_layout,container, false);
		topPromotionViewPager=(ViewPager)homePageView.findViewById(R.id.top_promotion_viewpager);
		recommendGridView=(GridView)homePageView.findViewById(R.id.recommend_list_gridview);
		recommendGridView.setOnItemClickListener(this);
		pointLinearlayout=(LinearLayout)homePageView.findViewById(R.id.top_promotion_point);
		promotionListLinearlayout=(LinearLayout)homePageView.findViewById(R.id.promotion_list_linearlayout);
		navigationService=(RelativeLayout)homePageView.findViewById(R.id.navigation_service_relativelayout);
		navigationService.setOnClickListener(this);
		navigationCommodity=(RelativeLayout)homePageView.findViewById(R.id.navigation_commodity_relativelayout);
		navigationCommodity.setOnClickListener(this);
		navigationCompany=(RelativeLayout)homePageView.findViewById(R.id.navigation_company_relativelayout);
		navigationCompany.setOnClickListener(this);
		navigationRemind=(RelativeLayout)homePageView.findViewById(R.id.navigation_remind_relativelayout);
		navigationRemind.setOnClickListener(this);
		promotionMoreText=(TextView) homePageView.findViewById(R.id.promotion_more_title);
		promotionMoreText.setOnClickListener(this);
		layoutInflater=LayoutInflater.from(getActivity());
		mViewList=new ArrayList<View>();
        super.asyncRefrshView(this);
		return homePageView;
	}
	protected void createTopPromotionViewPager(){
		if(topPromotionList==null || topPromotionList.size()==0){
			homePageView.findViewById(R.id.top_promotion_rl).setVisibility(View.GONE);
		}
		else{
			String[] imageUrlArray = new String[topPromotionList.size()];
			for (int  i = 0; i < imageUrlArray.length; i++) {
				final int topPosition=i;
				imageUrlArray[i]=topPromotionList.get(i).getPromotionPictureURL();
				topPromotionChildView = layoutInflater.inflate(R.xml.viewpager_image_view, null);
				ImageView topPromotionImage = (ImageView)topPromotionChildView.findViewById(R.id.company_image);
				topPromotionImage.setScaleType(ScaleType.CENTER);
				if(imageUrlArray[i]==null || "".equals(imageUrlArray[i]))
					topPromotionImage.setBackgroundResource(R.drawable.beauty_default_customer);
				else
					Picasso.with(getActivity()).load(imageUrlArray[i]).error(R.drawable.beauty_default_customer).into(topPromotionImage);
				topPromotionImage.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent();
						destIntent.setClass(getActivity(),PromotionDetailActivity.class);
						destIntent.putExtra("PromotionCode",topPromotionList.get(topPosition).getPromotionCode());
						startActivity(destIntent);
					}
				});
				mViewList.add(topPromotionChildView);
			}
			topPromotionViewPagerAdapter=new ViewPagerAdapter(mViewList);
			topPromotionViewPager.setAdapter(topPromotionViewPagerAdapter);
			topPromotionViewPager.setCurrentItem(currentItem);
			topPromotionViewPager.setOnPageChangeListener(new OnPageChangeListener() {
				
				@Override
				public void onPageSelected(int position) {
					// TODO Auto-generated method stub
					drawPoint(position);
					currentItem=position;
				}
				
				@Override
				public void onPageScrolled(int position, float arg1, int arg2) {
					// TODO Auto-generated method stub
					
				}
				
				@Override
				public void onPageScrollStateChanged(int position) {
					// TODO Auto-generated method stub
					
				}
			});
		}
	}
	private void  createPromotionList(){
		if(promotionList==null || promotionList.size()==0){
			homePageView.findViewById(R.id.promotion_list_ll).setVisibility(View.GONE);
		}
		else{
			for(int j=0;j<promotionList.size();j++){
				final int promotionPosition=j;
				View  promotionView=layoutInflater.inflate(R.xml.promotion_list_item,null);
				ImageView image=(ImageView) promotionView.findViewById(R.id.promotion_image);
				LayoutParams layoutParams=image.getLayoutParams();
				layoutParams.width=300;
				layoutParams.height=224;
				image.setLayoutParams(layoutParams);
				String imgaeURL=promotionList.get(j).getPromotionPictureURL();
				if(imgaeURL==null || "".equals(imgaeURL))
					image.setBackgroundResource(R.drawable.beauty_default_customer);
				else
					Picasso.with(getActivity()).load(imgaeURL).error(R.drawable.beauty_default_customer).into(image);
				TextView titleText=(TextView) promotionView.findViewById(R.id.promotion_title);
				TextView descriptionText=(TextView) promotionView.findViewById(R.id.promotion_description);
				TextView timeText=(TextView) promotionView.findViewById(R.id.promotion_time);
				titleText.setText(promotionList.get(j).getTitle());
				descriptionText.setText(promotionList.get(j).getDescription());
				timeText.setText(DateUtil.getFormateDateByString(promotionList.get(j).getStartDate())+"至"+DateUtil.getFormateDateByString(promotionList.get(j).getEndDate()));
				promotionView.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent();
						destIntent.setClass(getActivity(),PromotionDetailActivity.class);
						destIntent.putExtra("PromotionCode",promotionList.get(promotionPosition).getPromotionCode());
						startActivity(destIntent);
					}
				});
				View promotionItemDivideView=promotionView.findViewById(R.id.promotion_item_divide_view);
				if(j==0)
					promotionItemDivideView.setVisibility(View.GONE);
				promotionListLinearlayout.addView(promotionView);
			}
		}
	}
	private void  createRecommendGridView(){
		if(recommendList==null || recommendList.size()==0){
			homePageView.findViewById(R.id.recommend_ll).setVisibility(View.GONE);
		}
		else{
			recommendGridView.setAdapter(new RecommendListAdapter(getActivity(),recommendList));
		}
	}
	private void initPoint() {
		pointViews = new ArrayList<ImageView>();
		ImageView imageView;
		for (int i = 0; i < mViewList.size(); i++) {
			imageView = new ImageView(getActivity());
			imageView.setBackgroundResource(R.drawable.d1);
			LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT));
			layoutParams.leftMargin = 10;
			layoutParams.rightMargin = 10;
			pointLinearlayout.addView(imageView,layoutParams);
			pointViews.add(imageView);
		}
		drawPoint(0);
	}
	public void drawPoint(int index) {
		for (int i = 0; i < pointViews.size(); i++) {
			if (index == i) {
				pointViews.get(i).setBackgroundResource(R.drawable.d2);
			} else {
				pointViews.get(i).setBackgroundResource(R.drawable.d1);
			}
		}
	}
	
    private Handler handler = new Handler() {  
        public void handleMessage(android.os.Message msg) {  
        	topPromotionViewPager.setCurrentItem(currentItem);// 切换当前显示的图片  
        };  
    };
	private class ScrollTask implements Runnable {
	        public void run() {  
	            synchronized (topPromotionViewPager) {
	                currentItem = (currentItem + 1) %mViewList.size();  
	                handler.obtainMessage().sendToTarget(); // 通过Handler切换图片  
	            }  
	        }  
	    }  
	@Override
	public void onDestroyView() {
		// TODO Auto-generated method stub
		super.onDestroyView();
		if(scheduledExecutorService!=null){
			scheduledExecutorService.shutdown();
			scheduledExecutorService=null;
		}
	}
	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		Intent destIntent=new Intent();
		switch(view.getId()){
		case R.id.navigation_service_relativelayout:
			destIntent.setClass(getActivity(),ServiceCategoryListActivity.class);
			break;
		case R.id.navigation_commodity_relativelayout:
			destIntent.setClass(getActivity(),CommodityCategoryListActivity.class);
			break;
		case R.id.navigation_company_relativelayout:
			destIntent.setClass(getActivity(),CompanyActivity.class);
			break;
		case R.id.navigation_remind_relativelayout:
			destIntent.setClass(getActivity(),RemindListActivity.class);
			break;
		case R.id.promotion_more_title:
			destIntent.setClass(getActivity(),BranchPromotionActivity.class);
			break;
		}
		if(destIntent!=null)
			startActivity(destIntent);
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		String categoryName="";
		String methodName="";
		try {
			if(taskType==1){
				categoryName=PROMOTION_CATEGORY_NAME;
				methodName=PROMOTION_METHOD_NAME;
				para.put("ImageHeight",(mApp.getScreenWidth()/4)*3);
				para.put("ImageWidth",mApp.getScreenWidth());
				para.put("CompanyID",Integer.parseInt(mCompanyID));
				para.put("Type",1);
			}
			else if(taskType==2){
				categoryName=PROMOTION_CATEGORY_NAME;
				methodName=PROMOTION_METHOD_NAME;
				para.put("ImageWidth",300);
				para.put("ImageHeight",224);
				para.put("CompanyID",Integer.parseInt(mCompanyID));
				para.put("Type",2);
			}
			else if(taskType==3){
				categoryName=RECOMMEND_CATEGORY_NAME;
				methodName=RECOMMEND_METHOD_NAME;
				para.put("ImageHeight",160);
				para.put("ImageWidth",160);
			}
		} catch (JSONException e) {
			
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName,methodName,para.toString());
		WebApiRequest request = new WebApiRequest(categoryName,methodName,para.toString(), header);
		return request;
	}
	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(taskType==3){
			ArrayList<ServiceInformation> services = ServiceInformation.parseListByJsonNoNode(response.getStringData());
			response.mData = services;
		}
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				//解析顶部促销
				if(taskType==1){
					topPromotionList=PromotionDetail.parseListByJson(response.getStringData());
					taskType=2;
					super.asyncRefrshView(this);
				}
				else if(taskType==2){
					taskType=3;
					promotionList=PromotionDetail.parseListByJson(response.getStringData());
					super.asyncRefrshView(this);
				}
				else if(taskType==3){
					super.dismissProgressDialog();
					recommendList=(List<ServiceInformation>)response.mData;
					createTopPromotionViewPager();
					initPoint();
					createPromotionList();
					createRecommendGridView();
					scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();  
			        // 当Activity显示出来后，每两秒钟切换一次图片显示  
			        scheduledExecutorService.scheduleAtFixedRate(new ScrollTask(),1,3,TimeUnit.SECONDS);
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
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
	@Override
	public void onItemClick(AdapterView<?> parentView, View view, int position, long id) {
		// TODO Auto-generated method stub
		Intent intent=new Intent();
		if(recommendList.get(position).getProductType()==0){
			intent.setClass(getActivity(),ServiceDetailActivity.class);
			intent.putExtra("serviceCode",recommendList.get(position).getCode());
		}
		else if(recommendList.get(position).getProductType()==1){
			intent.setClass(getActivity(),CommodityDetailActivity.class);
			intent.putExtra("CommodityCode",recommendList.get(position).getCode());
		}
		startActivity(intent);
	}
}
