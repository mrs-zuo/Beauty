package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AppointmentInfo;
import cn.com.antika.bean.Customer;
import cn.com.antika.bean.CustomerBenefit;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.Treatment;
import cn.com.antika.bean.TreatmentGroup;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.ChangeServiceExpirationDateListener;
import cn.com.antika.util.DateButton;
import cn.com.antika.util.DateUtil;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.OrderOperationUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.menu.BusinessRightMenu;
import cn.com.antika.view.sign.HandwritingActivity;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class OrderDetailActivity extends BaseActivity implements OnClickListener {
	private OrderDetailActivityHandler mHandler = new OrderDetailActivityHandler(this);
	private Thread         requestWebServiceThread;
	private ProgressDialog progressDialog;
	private TextView orderDetailTimeText, orderDetailProductNameText,
					 orderDetailQuantityText, orderDetailTotalPriceText,
			         orderDetailStatusText,orderDetailCustomerNameText,orderDetailCreatorNameText,
			         orderDetailResponsibleNameText,orderDetailTotalSalePriceText,OrderDetailTotalCalculatePriceText;
	private RelativeLayout orderExpirationDateDivideRelativelayout,orderDetailCustomerNameRelativelayout,orderDetailThirdPartPayRelativelayout;
	private LayoutInflater layoutInflater;
	private TableLayout orderCourseTablelayout,orderUnCompleteTablelayout;
	private OrderInfo transOrderInfo;
	private UserInfoApplication userinfoApplication;
	private RelativeLayout orderNumberRelativelayout,orderDetailProductNameRelativelayout;
	private OrderInfo    orderInfo;
	private TableLayout orderDetailBasicTableLayout,orderDetailProductNameTablelayout,orderCompleteInfoTablelayout,orderAppointmentTablelayout;
	// 标识课程下面是否有服务正在做或者已经完成
	private int         userRole,deleteOrderType;//deleteOrderType: 1:取消订单  2：终止订单  3:订单退款
	private int 		showPayStatusInfo;// 显示订单的支付状态:(order表中的PaymentStatus)：3 已付款
	private AlertDialog treatmentUpdateDialog;
	// 订单备注文本框
	private EditText  orderRemarkEditText;
	private ImageView orderRemarkSaveBtn,orderRemarkEditBtn,orderDetailHasExpirationIcon,changeResponsiblePerson;
	private View orderExpirationDateDivideView,orderDetailThirdPartPayDivideView;
	private EditText orderExpirationDateText;
	private ImageButton orderChangeExpirationDateBtn,orderDetailRefreshIcon;
	private boolean           fromOrderList,isOrderBasicHide,isOrderProductNameHide,isOderCompleteRecordShow,isOrderAppointmentShow;
	private PackageUpdateUtil packageUpdateUtil;
	private Button    completeOrderBtn,deleteOrderBtn,payOrderBtn,addOrderForTGBtn,addAppointmentBtn;
	private String    operationTreatmentGroupNo;
	private ImageView  orderBasicUpDownIcon,orderProductUpDownIcon;
	private int        operationTreatmentID;
	private Animation  mShowAction,mHiddenAction;
	private int        authMyOrderWrite;
	/**订单详细页*/
	private static final int ORDER_DETAIL=2;
	private TreatmentGroup currentTreatmentGroup;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_order_detail);
		treatmentUpdateDialog = new AlertDialog.Builder(this).create();
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		orderDetailTimeText = (TextView) findViewById(R.id.order_detail_time);
		orderDetailProductNameText = (TextView) findViewById(R.id.order_detail_product_name);
		orderDetailQuantityText = (TextView) findViewById(R.id.order_detail_product_quantity);
		orderDetailTotalPriceText = (TextView) findViewById(R.id.order_detail_total_price);
		orderDetailStatusText = (TextView) findViewById(R.id.order_detail_status_text);
		changeResponsiblePerson = (ImageView) findViewById(R.id.order_detail_reaponsible_name_icon);
		orderRemarkEditText = (EditText) findViewById(R.id.order_detail_remark_text);
		orderRemarkEditBtn = (ImageView) findViewById(R.id.order_detail_remark_edit_btn);
		orderRemarkSaveBtn = (ImageView) findViewById(R.id.order_detail_remark_save_btn);
		orderRemarkSaveBtn.setOnClickListener(this);
		orderRemarkEditBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				orderRemarkEditText.setEnabled(true);
				orderRemarkEditBtn.setVisibility(View.GONE);
				orderRemarkSaveBtn.setVisibility(View.VISIBLE);
			}
		});
		orderDetailCustomerNameText = (TextView) findViewById(R.id.order_detail_customer_name);
		orderDetailCreatorNameText = (TextView) findViewById(R.id.order_detail_creator_name);
		orderDetailResponsibleNameText = (TextView) findViewById(R.id.order_detail_reaponsible_name);
		orderDetailTotalSalePriceText = (TextView) findViewById(R.id.order_detail_total_sale_price_text);
		OrderDetailTotalCalculatePriceText=(TextView)findViewById(R.id.order_detail_total_calculate_price_text);
		layoutInflater = LayoutInflater.from(this);
		orderCourseTablelayout = (TableLayout)findViewById(R.id.order_course_tablelayout);
		orderUnCompleteTablelayout=(TableLayout)findViewById(R.id.order_uncomplete_tablelayout);
		userinfoApplication = UserInfoApplication.getInstance();
		// 服务订单的过期日期
		orderExpirationDateDivideView = findViewById(R.id.order_detail_expiration_date_divide_view);
		orderExpirationDateDivideRelativelayout = (RelativeLayout) findViewById(R.id.order_detail_expiration_date_relativelayout);
		orderChangeExpirationDateBtn = (ImageButton) findViewById(R.id.order_detail_service_order_expiration_date_btn);
		orderExpirationDateText = (EditText) findViewById(R.id.order_detail_service_expiration_date_text);
		orderExpirationDateText.setInputType(InputType.TYPE_NULL);
		orderDetailHasExpirationIcon = (ImageView) findViewById(R.id.order_detail_service_order_has_expiration);
		//手动刷新订单
		orderDetailRefreshIcon=(ImageButton)findViewById(R.id.order_detail_refresh_icon);
		orderDetailBasicTableLayout=(TableLayout)findViewById(R.id.order_detail_basic_tablelayout);
		orderInfo = (OrderInfo) getIntent().getSerializableExtra("orderInfo");
		//点击订单的顾客 可以选中该顾客
		orderDetailCustomerNameRelativelayout=(RelativeLayout) findViewById(R.id.order_detail_customer_name_relativelayout);
		orderNumberRelativelayout=(RelativeLayout) findViewById(R.id.layout_order_serial_number);
		orderNumberRelativelayout.setOnClickListener(this);
		orderDetailProductNameTablelayout=(TableLayout)findViewById(R.id.order_detail_product_name_tablelayout);
		orderDetailProductNameRelativelayout=(RelativeLayout) findViewById(R.id.order_detail_product_name_relativelayout);
		orderDetailProductNameRelativelayout.setOnClickListener(this);
		orderCompleteInfoTablelayout=(TableLayout) findViewById(R.id.order_complete_info_tablelayout);
		completeOrderBtn=(Button)findViewById(R.id.order_detail_complete_btn);
		completeOrderBtn.setOnClickListener(this);
		deleteOrderBtn=(Button)findViewById(R.id.order_detail_delete_btn);
		deleteOrderBtn.setOnClickListener(this);
		payOrderBtn=(Button)findViewById(R.id.order_detail_pay_btn);
		payOrderBtn.setOnClickListener(this);
		//增加小单按钮和预约按钮
		addOrderForTGBtn=(Button)findViewById(R.id.add_order_for_treatment_group);
		addAppointmentBtn=(Button)findViewById(R.id.add_appointment_for_order);
		//第三方支付结果
		orderDetailThirdPartPayDivideView=findViewById(R.id.order_detail_third_part_pay_divide_view);
		orderDetailThirdPartPayRelativelayout=(RelativeLayout)findViewById(R.id.order_detail_third_part_pay_relativelayout);
		((RelativeLayout)findViewById(R.id.layout_order_serial_number)).setOnClickListener(this);
		orderBasicUpDownIcon=(ImageView)findViewById(R.id.order_basic_up_down_icon);
		orderProductUpDownIcon=(ImageView) findViewById(R.id.order_product_up_down_icon);
		orderAppointmentTablelayout=(TableLayout)findViewById(R.id.order_appointment_info_tablelayout);
		orderDetailRefreshIcon.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				initView();
			}
		});
		//初始化动画效果
		initAnimations();
		//初始化订单详细页面头部的信息
		isOrderBasicHide=false;
		orderBasicUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
		isOrderProductNameHide=false;
		orderProductUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
		isOderCompleteRecordShow=false;
		imageLoader =ImageLoader.getInstance();
		displayImageOptions= ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		hideOrShowOrderBasic();
		hideOrShowOrderProduct();
		initView();
	}

	private static class OrderDetailActivityHandler extends Handler {
		private final OrderDetailActivity orderDetailActivity;

		private OrderDetailActivityHandler(OrderDetailActivity activity) {
			WeakReference<OrderDetailActivity> weakReference = new WeakReference<OrderDetailActivity>(activity);
			orderDetailActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (orderDetailActivity == null) {
				UserInfoApplication.getInstance().exitForLogin(null);
			}
			if (orderDetailActivity.progressDialog != null) {
				orderDetailActivity.progressDialog.dismiss();
				orderDetailActivity.progressDialog = null;
			}
			if (orderDetailActivity.requestWebServiceThread != null) {
				orderDetailActivity.requestWebServiceThread.interrupt();
				orderDetailActivity.requestWebServiceThread = null;
			}
			if (msg.what == 1) {
				OrderInfo showOrderInfo = (OrderInfo) msg.obj;
				orderDetailActivity.showPayStatusInfo = showOrderInfo.getPaymentStatus();
				orderDetailActivity.userinfoApplication.setCustomerID(showOrderInfo.getCustomerID());
				orderDetailActivity.userinfoApplication.setOrderResponsiblePersonID(showOrderInfo.getResponsiblePersonID());
				orderDetailActivity.userinfoApplication.setOrderCreatorID(showOrderInfo.getCreatorID());
				orderDetailActivity.authMyOrderWrite = OrderOperationUtil.checkPersonAuthOrderWrite(showOrderInfo, orderDetailActivity.userinfoApplication);
				//订单编号
				((TextView) orderDetailActivity.findViewById(R.id.order_serial_number)).setText(showOrderInfo.getOrderSerialNumber());
				// 下单门店
				((TextView) orderDetailActivity.findViewById(R.id.order_branch_name_text)).setText(showOrderInfo.getBranchName());
				if (showOrderInfo.getResponsiblePersonName() == null || ("").equals(showOrderInfo.getResponsiblePersonName())) {
					if (orderDetailActivity.authMyOrderWrite == 0 || showOrderInfo.getStatus() == 3)
						orderDetailActivity.changeResponsiblePerson.setVisibility(View.GONE);
					else {
						orderDetailActivity.changeResponsiblePerson.setVisibility(View.VISIBLE);
						((RelativeLayout) orderDetailActivity.findViewById(R.id.responsible_name_relativelayout)).setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View view) {
								if (orderDetailActivity.changeResponsiblePerson.getVisibility() == View.VISIBLE) {
									Intent intent = new Intent(orderDetailActivity, ChoosePersonActivity.class);
									intent.putExtra("personRole", "Doctor");
									intent.putExtra("checkModel", "Single");
									orderDetailActivity.startActivityForResult(intent, 400);
								}
							}
						});
					}
				} else {
					((RelativeLayout) orderDetailActivity.findViewById(R.id.responsible_name_relativelayout)).setOnClickListener(null);
					orderDetailActivity.changeResponsiblePerson.setVisibility(View.GONE);
				}
				orderDetailActivity.orderDetailTimeText.setText(showOrderInfo.getOrderTime());
				orderDetailActivity.orderDetailProductNameText.setText(showOrderInfo.getProductName());
				orderDetailActivity.orderDetailQuantityText.setText(String.valueOf(showOrderInfo.getQuantity()));
				orderDetailActivity.orderDetailTotalPriceText.setText(orderDetailActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(showOrderInfo.getTotalPrice()));
				orderDetailActivity.orderDetailCustomerNameText.setText(showOrderInfo.getCustomerName());
				//本店订单才可以选择顾客
				int isThisBranchOrder = showOrderInfo.getIsThisBranch();
				if (isThisBranchOrder == 1) {
					((ImageButton) orderDetailActivity.findViewById(R.id.order_detail_select_customer_icon)).setVisibility(View.VISIBLE);
					orderDetailActivity.orderDetailCustomerNameRelativelayout.setOnClickListener(orderDetailActivity);
				} else {
					((ImageButton) orderDetailActivity.findViewById(R.id.order_detail_select_customer_icon)).setVisibility(View.GONE);
					orderDetailActivity.orderDetailCustomerNameRelativelayout.setOnClickListener(null);
				}
				int orderStatus = showOrderInfo.getStatus();
				// 更换服务订单有效期 如果订单是可以编辑的 则日期显示灰色 否则显示则黑色
				if (orderDetailActivity.authMyOrderWrite == 1 && showOrderInfo.getStatus() == 1) {
					orderDetailActivity.orderExpirationDateText.setTextColor(orderDetailActivity.getApplicationContext().getResources().getColor(R.color.gray));
					orderDetailActivity.orderExpirationDateDivideRelativelayout.setOnClickListener(orderDetailActivity);
					orderDetailActivity.orderExpirationDateText.setOnClickListener(orderDetailActivity);
					orderDetailActivity.orderChangeExpirationDateBtn.setOnClickListener(orderDetailActivity);
				} else {
					orderDetailActivity.orderExpirationDateDivideRelativelayout.setOnClickListener(null);
					orderDetailActivity.orderExpirationDateText.setOnClickListener(null);
					orderDetailActivity.orderChangeExpirationDateBtn.setOnClickListener(null);
					orderDetailActivity.orderExpirationDateText.setTextColor(orderDetailActivity.getApplicationContext().getResources().getColor(R.color.black));
					orderDetailActivity.orderChangeExpirationDateBtn.setVisibility(View.GONE);
				}
				int orderPayStatus = showOrderInfo.getPaymentStatus();
				String orderStatusString = OrderOperationUtil.getOrderStatus(orderStatus);
				String orderPayStatusString = OrderOperationUtil.getOrderPayemntStatus(orderPayStatus);

				// 不是未支付 并且不是0元订单时
				if (orderPayStatus == 2 || orderPayStatus == 3 || orderPayStatus == 4) {
					orderDetailActivity.findViewById(R.id.order_detail_pay_detail_divide_view).setVisibility(View.VISIBLE);
					((RelativeLayout) orderDetailActivity.findViewById(R.id.order_detail_pay_detail_relativelayout)).setVisibility(View.VISIBLE);
					((RelativeLayout) orderDetailActivity.findViewById(R.id.order_detail_pay_detail_relativelayout)).setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							Intent destIntent = new Intent(orderDetailActivity, OrderPaymentDetailActivity.class);
							destIntent.putExtra("OrderTotalSalePrice", orderDetailActivity.transOrderInfo.getTotalSalePrice());
							destIntent.putExtra("OrderID", orderDetailActivity.transOrderInfo.getOrderID());
							orderDetailActivity.startActivity(destIntent);
						}
					});
				} else {
					orderDetailActivity.findViewById(R.id.order_detail_pay_detail_divide_view).setVisibility(View.GONE);
					((RelativeLayout) orderDetailActivity.findViewById(R.id.order_detail_pay_detail_relativelayout)).setVisibility(View.GONE);
				}
				//有第三方支付，则显示没有则隐藏第三方支付结果
				if (showOrderInfo.isHasNetTrade()) {
					orderDetailActivity.orderDetailThirdPartPayDivideView.setVisibility(View.VISIBLE);
					orderDetailActivity.orderDetailThirdPartPayRelativelayout.setVisibility(View.VISIBLE);
					orderDetailActivity.orderDetailThirdPartPayRelativelayout.setOnClickListener(orderDetailActivity);
				} else {
					orderDetailActivity.orderDetailThirdPartPayDivideView.setVisibility(View.GONE);
					orderDetailActivity.orderDetailThirdPartPayRelativelayout.setVisibility(View.GONE);
				}
				orderDetailActivity.orderDetailStatusText.setText(orderStatusString + "|" + orderPayStatusString);
				orderDetailActivity.orderDetailCreatorNameText.setText(showOrderInfo.getCreatorName());
				orderDetailActivity.orderDetailResponsibleNameText.setText(showOrderInfo.getResponsiblePersonName());
				orderDetailActivity.OrderDetailTotalCalculatePriceText.setText(orderDetailActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(showOrderInfo.getTotalCalculatePrice()));
				//显示券列表
				List<CustomerBenefit> customerBenefitList = showOrderInfo.getCustomerBenefitList();
				if (customerBenefitList != null && customerBenefitList.size() > 0) {
					RelativeLayout customerBenefitItemRelativelayout = (RelativeLayout) orderDetailActivity.findViewById(R.id.order_detail_customer_benefit_item_relativelayout);
					customerBenefitItemRelativelayout.removeAllViews();
					for (CustomerBenefit cb : customerBenefitList) {
						View benefitItemView = orderDetailActivity.layoutInflater.inflate(R.xml.customer_benefit_item, null);
						TextView benefitNameText = (TextView) benefitItemView.findViewById(R.id.benefit_name);
						TextView benefitPRValue2Text = (TextView) benefitItemView.findViewById(R.id.benefit_prvalue2);
						benefitNameText.setText(cb.getBenefitName());
						benefitPRValue2Text.setText("-" + NumberFormatUtil.currencyFormat(String.valueOf(cb.getPrValue2())));
						customerBenefitItemRelativelayout.addView(benefitItemView);
					}
				}
				orderDetailActivity.orderDetailTotalSalePriceText.setText(orderDetailActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(showOrderInfo.getTotalSalePrice()));
				List<TreatmentGroup> treatmentGroupList = showOrderInfo.getTreatmentGroupList();
				orderDetailActivity.createtTreatmentGroupLayout(treatmentGroupList, 0, showOrderInfo.getProductType());
				String orderRemark = showOrderInfo.getOrderRemark();
				// 初始化备注的视图状态
				if (orderRemark != null && !(("").equals(orderRemark)) && !(("(null)").equals(orderRemark))) {
					orderDetailActivity.orderRemarkEditText.setText(orderRemark);
				}
				// 如果没有当前账户没有编辑订单权限，则隐藏备注的编辑的按钮
				if (orderDetailActivity.authMyOrderWrite == 0) {
					orderDetailActivity.orderRemarkEditBtn.setVisibility(View.GONE);
				} else {
					orderDetailActivity.orderRemarkEditBtn.setVisibility(View.VISIBLE);
				}
				orderDetailActivity.orderRemarkEditText.setEnabled(false);
				orderDetailActivity.orderRemarkSaveBtn.setVisibility(View.GONE);
				orderDetailActivity.deleteOrderType = 1;
				int completed = showOrderInfo.getCompleteCount();
				//显示取消还是终止  订单未支付并且没有小单完成  并且是未完成状态是取消 或者是免支付订单  0元订单
				if (((showOrderInfo.getPaymentStatus() == 1 || showOrderInfo.getPaymentStatus() == 5) && completed == 0 && showOrderInfo.getStatus() == 1 && orderDetailActivity.authMyOrderWrite == 1)) {
					orderDetailActivity.deleteOrderType = 1;
					orderDetailActivity.deleteOrderBtn.setText("取消");
				}
				//订单发生了付款 或者已经有小单完成  并且是未完成状态
				//else if((showOrderInfo.getPaymentStatus()!=1 || completed>0) && showOrderInfo.getStatus()==1 && authMyOrderWrite==1){
				else if ((showOrderInfo.getPaymentStatus() != 1 || completed > 0)
						&& showOrderInfo.getStatus() == 1
						&& orderDetailActivity.authMyOrderWrite == 1
						&& orderDetailActivity.userinfoApplication.getAccountInfo().getAuthTerminateOrder() == 1) {
					orderDetailActivity.deleteOrderType = 2;
					orderDetailActivity.deleteOrderBtn.setText("终止");
				}
				//当前账户有支付权限   当前订单不是合并支付 且支付状态为部分支付或已支付 并且订单是终止状态
				else if (showOrderInfo.getStatus() == 4 && (orderPayStatus == 3 || orderPayStatus == 2) && orderDetailActivity.userinfoApplication.getAccountInfo().getAuthPaymentUse() == 1) {
					orderDetailActivity.deleteOrderType = 3;
					orderDetailActivity.deleteOrderBtn.setText("退款");
				} else
					orderDetailActivity.deleteOrderBtn.setVisibility(View.GONE);
				//获取是否有结账的权限
				int authPaymentUse = orderDetailActivity.userinfoApplication.getAccountInfo().getAuthPaymentUse();
				//显示结账的条件 有效订单 并且不是已支付
				if (showOrderInfo.getPaymentStatus() != 3 && showOrderInfo.getStatus() != 3 && showOrderInfo.getStatus() != 4 && showOrderInfo.getPaymentStatus() != 5 && authPaymentUse == 1)
					orderDetailActivity.payOrderBtn.setVisibility(View.VISIBLE);
				else
					orderDetailActivity.payOrderBtn.setVisibility(View.GONE);
				//是否显示完成订单  订单的总次数等于完成次数并且订单是未完成状态 或者是无限次时有完成的次数 完成状态时未完成状态
				if ((showOrderInfo.getTotalCount() == 0 && showOrderInfo.getCompleteCount() > 0 && showOrderInfo.getStatus() == 1 && orderDetailActivity.authMyOrderWrite == 1)) {
					orderDetailActivity.completeOrderBtn.setVisibility(View.VISIBLE);
				} else {
					orderDetailActivity.completeOrderBtn.setVisibility(View.GONE);
				}
				//是否具有编辑我的订单权限
				int authOwnerOrderEdit = OrderOperationUtil.checkPersonOwnerAuthOrderWrite(orderDetailActivity.userinfoApplication);
				//是否显示订单的预约和开单界面
				if (authOwnerOrderEdit == 1 && orderDetailActivity.transOrderInfo.getStatus() == 1) {
					if (orderDetailActivity.transOrderInfo.getTotalCount() == 0)
						orderDetailActivity.addOrderForTGBtn.setVisibility(View.VISIBLE);
					else {
						if (orderDetailActivity.transOrderInfo.getSurplusCount() > 0)
							orderDetailActivity.addOrderForTGBtn.setVisibility(View.VISIBLE);
						else
							orderDetailActivity.addOrderForTGBtn.setVisibility(View.GONE);
					}
					if (showOrderInfo.getProductType() == Constant.SERVICE_TYPE) {
						if (orderDetailActivity.transOrderInfo.getTotalCount() == 0)
							orderDetailActivity.addAppointmentBtn.setVisibility(View.VISIBLE);
						else {
							//预约是否显示于结账后20171010
							if (!showOrderInfo.getAppointmentMustPaid() || (showOrderInfo.getAppointmentMustPaid() && showOrderInfo.getPaymentStatus() != 1)) {
								int executintCount = 0;
								if (orderDetailActivity.transOrderInfo.getTreatmentGroupList() != null)
									executintCount = orderDetailActivity.transOrderInfo.getTreatmentGroupList().size();
								if (orderDetailActivity.transOrderInfo.getSurplusCount() > 0 && ((orderDetailActivity.transOrderInfo.getScdlCount() + executintCount + orderDetailActivity.transOrderInfo.getCompleteCount()) < orderDetailActivity.transOrderInfo.getTotalCount()))
									orderDetailActivity.addAppointmentBtn.setVisibility(View.VISIBLE);
								else
									orderDetailActivity.addAppointmentBtn.setVisibility(View.GONE);
							} else {
								orderDetailActivity.addAppointmentBtn.setVisibility(View.GONE);
							}
						}
					} else
						orderDetailActivity.addAppointmentBtn.setVisibility(View.GONE);
				} else {
					orderDetailActivity.addOrderForTGBtn.setVisibility(View.GONE);
					orderDetailActivity.addAppointmentBtn.setVisibility(View.GONE);
				}
				//跳转到开小单界面
				orderDetailActivity.addOrderForTGBtn.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View v) {
						// TODO Auto-generated method stub
						Intent destIntent = new Intent(orderDetailActivity, ProductAndOldOrderListActivity.class);
						Bundle bundle = new Bundle();
						ArrayList<String> orderIDsList = new ArrayList<String>();
						orderIDsList.add(String.valueOf(orderDetailActivity.transOrderInfo.getOrderID()));
						bundle.putStringArrayList("orderIdList", orderIDsList);
						destIntent.putExtras(bundle);
						orderDetailActivity.startActivity(destIntent);
					}
				});
				//跳转到预约界面
				orderDetailActivity.addAppointmentBtn.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent appointmentCreateActivityIntent = new Intent(orderDetailActivity, AppointmentCreateActivity.class);
						Bundle bundle = new Bundle();
						bundle.putSerializable("orderInfo", orderDetailActivity.transOrderInfo);
						bundle.putInt("FROM_SOURCE", ORDER_DETAIL);
						appointmentCreateActivityIntent.putExtras(bundle);
						orderDetailActivity.startActivity(appointmentCreateActivityIntent);
					}
				});
				//显示已完成的服务或者商品交付记录
				orderDetailActivity.orderCompleteInfoTablelayout.removeAllViews();
				View completeTitleView = orderDetailActivity.layoutInflater.inflate(R.xml.treatment_complete_title, null);
				TextView titleText = (TextView) completeTitleView.findViewById(R.id.complete_info_title_text);
				ImageView completeUpDownIcon = (ImageView) completeTitleView.findViewById(R.id.treatment_complete_up_down_icon);
				completeUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
				if (orderDetailActivity.transOrderInfo.getCompleteCount() > 0) {
					orderDetailActivity.orderCompleteInfoTablelayout.setVisibility(View.VISIBLE);
					if (orderDetailActivity.transOrderInfo.getProductType() == Constant.SERVICE_TYPE)
						titleText.setText("已完成服务记录");
					else if (orderDetailActivity.transOrderInfo.getProductType() == Constant.COMMODITY_TYPE)
						titleText.setText("已交付商品记录");
					completeTitleView.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View view) {
							// TODO Auto-generated method stub
							orderDetailActivity.getCompleteTG();
						}
					});
					orderDetailActivity.orderCompleteInfoTablelayout.addView(completeTitleView);
				} else
					orderDetailActivity.orderCompleteInfoTablelayout.setVisibility(View.GONE);
				//如果订单的操作按钮都不存在，则隐藏掉该行
				if (orderDetailActivity.completeOrderBtn.getVisibility() == View.GONE && orderDetailActivity.payOrderBtn.getVisibility() == View.GONE && orderDetailActivity.deleteOrderBtn.getVisibility() == View.GONE) {
					orderDetailActivity.findViewById(R.id.order_operation_btn_relativelayout).setVisibility(View.GONE);
				} else {
					orderDetailActivity.findViewById(R.id.order_operation_btn_relativelayout).setVisibility(View.VISIBLE);
				}
				//如果订单的开单和预约按钮不存在，则该隐藏掉该行
				if (orderDetailActivity.addOrderForTGBtn.getVisibility() == View.GONE && orderDetailActivity.addAppointmentBtn.getVisibility() == View.GONE) {
					orderDetailActivity.findViewById(R.id.add_order_appointment_relativelayout).setVisibility(View.GONE);
				} else {
					orderDetailActivity.findViewById(R.id.add_order_appointment_relativelayout).setVisibility(View.VISIBLE);
				}
				//预约信息
				if (showOrderInfo.getProductType() == Constant.SERVICE_TYPE) {
					orderDetailActivity.orderAppointmentTablelayout.removeAllViews();
					View orderAppointmentTitleView = orderDetailActivity.layoutInflater.inflate(R.xml.order_appointment_title, null);
					TextView appointmentTitleText = (TextView) orderAppointmentTitleView.findViewById(R.id.order_appointment_title_text);
					ImageView appointmentUpDownIcon = (ImageView) orderAppointmentTitleView.findViewById(R.id.order_appointment_up_down_icon);
					appointmentUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
					orderDetailActivity.isOrderAppointmentShow = false;
					if (orderDetailActivity.transOrderInfo.getScdlCount() > 0) {
						orderDetailActivity.orderAppointmentTablelayout.setVisibility(View.VISIBLE);
						appointmentTitleText.setText(orderDetailActivity.getString(R.string.order_appointment_info_title_text));
						orderAppointmentTitleView.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View v) {
								orderDetailActivity.showOrderAppointment();
							}
						});
						orderDetailActivity.orderAppointmentTablelayout.addView(orderAppointmentTitleView);
						List<AppointmentInfo> appointmentList = showOrderInfo.getAppointmentList();
						for (int a = 0; a < appointmentList.size(); a++) {
							final AppointmentInfo ai = appointmentList.get(a);
							View orderAppointmentItemView = orderDetailActivity.layoutInflater.inflate(R.xml.order_appointment_layout, null);
							TextView appointmentNoText = (TextView) orderAppointmentItemView.findViewById(R.id.order_appointment_no_text);
							TextView appointmentResponsiblePersonText = (TextView) orderAppointmentItemView.findViewById(R.id.order_appointment_responsible_text);
							TextView appointmentStartTimeText = (TextView) orderAppointmentItemView.findViewById(R.id.order_appointment_start_time_text);
							appointmentNoText.setText(String.valueOf(a + 1));
							appointmentResponsiblePersonText.setText(ai.getResponsiblePersonName());
							appointmentStartTimeText.setText(ai.getTaskScdlStartTime());
							orderAppointmentItemView.setOnClickListener(new OnClickListener() {
								@Override
								public void onClick(View v) {
									Intent destIntent = new Intent(orderDetailActivity, AppointmentDetailActivity.class);
									destIntent.putExtra("taskID", ai.getTaskID());
									orderDetailActivity.startActivity(destIntent);
								}
							});
							orderAppointmentItemView.setVisibility(View.GONE);
							orderDetailActivity.orderAppointmentTablelayout.addView(orderAppointmentItemView);
							if (a != appointmentList.size() - 1) {
								View divideView = orderDetailActivity.layoutInflater.inflate(R.xml.divide_view, null);
								divideView.setVisibility(View.GONE);
								orderDetailActivity.orderAppointmentTablelayout.addView(divideView);
							}
						}
					} else
						orderDetailActivity.orderAppointmentTablelayout.setVisibility(View.GONE);
				} else
					orderDetailActivity.orderAppointmentTablelayout.setVisibility(View.GONE);

			} else if (msg.what == 0) {
				DialogUtil.createMakeSureDialog(orderDetailActivity, "温馨提示", "您的网络貌似不给力，请检查网络设置！");
			} else if (msg.what == 2) {
				String message = (String) msg.obj;
				if (message != null && !("").equals(message))
					DialogUtil.createShortDialog(orderDetailActivity, message);
				else
					DialogUtil.createShortDialog(orderDetailActivity, "操作失败，请重试!");
			}
			//订单详细操作之后刷新当前画面
			else if (msg.what == 3) {
				DialogUtil.createShortDialog(orderDetailActivity, (String) msg.obj);
				orderDetailActivity.initView();
			} else if (msg.what == 4) {
				DialogUtil.createShortDialog(orderDetailActivity, (String) msg.obj);
				orderDetailActivity.initView();
			} else if (msg.what == 6) {
				Customer customer = (Customer) msg.obj;
				orderDetailActivity.userinfoApplication.setSelectedCustomerID(customer.getCustomerId());
				orderDetailActivity.userinfoApplication.setSelectedCustomerName(customer.getCustomerName());
				orderDetailActivity.userinfoApplication.setSelectedCustomerHeadImageURL(customer.getHeadImageUrl());
				orderDetailActivity.userinfoApplication.setSelectedCustomerLoginMobile(customer.getLoginMobile());
				orderDetailActivity.userinfoApplication.setSelectedIsMyCustomer(customer.getIsMyCustomer());
				BusinessRightMenu.createMenuContent();
				BusinessRightMenu.rightMenuAdapter.notifyDataSetChanged();
				DialogUtil.createShortDialog(orderDetailActivity, "选择顾客成功!");
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(orderDetailActivity, orderDetailActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(orderDetailActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + orderDetailActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(orderDetailActivity);
				orderDetailActivity.packageUpdateUtil = new PackageUpdateUtil(orderDetailActivity, orderDetailActivity.mHandler, fileCache, downloadFileUrl, false, orderDetailActivity.userinfoApplication);
				orderDetailActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				orderDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = orderDetailActivity.getFileStreamPath(filename);
				file.getName();
				orderDetailActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			} else if (msg.what == 8) {
				List<TreatmentGroup> treatmentGroupList = (List<TreatmentGroup>) msg.obj;
				orderDetailActivity.createtTreatmentGroupLayout(treatmentGroupList, 1, orderDetailActivity.transOrderInfo.getProductType());
				orderDetailActivity.isOderCompleteRecordShow = true;
				((ImageView) orderDetailActivity.findViewById(R.id.treatment_complete_up_down_icon)).setBackgroundResource(R.drawable.report_main_up_icon);
			}
			//终止取消订单
			else if (msg.what == 9) {
				//终止订单并且当前账号是有结账权限时 且支付状态为已支付或部分支付 并且订单不是合并支付询问是否进行退款
				if (orderDetailActivity.deleteOrderType == 2 && (orderDetailActivity.showPayStatusInfo == 3 || orderDetailActivity.showPayStatusInfo == 2) && orderDetailActivity.userinfoApplication.getAccountInfo().getAuthPaymentUse() == 1 && !orderDetailActivity.transOrderInfo.isMergePay()) {
					DialogUtil.createShortDialog(orderDetailActivity, "订单终止成功！");
					Dialog dialog = new AlertDialog.Builder(orderDetailActivity, R.style.CustomerAlertDialog)
							.setTitle(orderDetailActivity.getString(R.string.delete_dialog_title))
							.setMessage(orderDetailActivity.getString(R.string.refund_order_tips))
							.setPositiveButton(orderDetailActivity.getString(R.string.refund_order_confirm), new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog, int which) {
									dialog.dismiss();
									dialog = null;
									Intent destIntent = new Intent();
									destIntent.setClass(orderDetailActivity, OrderRefundActivity.class);
									destIntent.putExtra("orderID", orderDetailActivity.transOrderInfo.getOrderID());
									destIntent.putExtra("customerID", orderDetailActivity.transOrderInfo.getCustomerID());
									destIntent.putExtra("productType", orderDetailActivity.transOrderInfo.getProductType());
									orderDetailActivity.startActivity(destIntent);
								}
							})
							.setNegativeButton(orderDetailActivity.getString(R.string.delete_cancel),
									new DialogInterface.OnClickListener() {
										@Override
										public void onClick(DialogInterface dialog, int which) {
											dialog.dismiss();
											dialog = null;
											orderDetailActivity.initView();
										}
									}).create();
					dialog.show();
					dialog.setCancelable(false);
				} else {
					if (orderDetailActivity.deleteOrderType == 1)
						DialogUtil.createShortDialog(orderDetailActivity, "订单取消成功!");
					else if (orderDetailActivity.deleteOrderType == 2)
						DialogUtil.createShortDialog(orderDetailActivity, "订单终止成功！");
					orderDetailActivity.initView();
				}
			}
		}
	}

	// 更改服务有效期Listener
	private ChangeServiceExpirationDateListener changeServiceExpirationDateListener = new ChangeServiceExpirationDateListener() {
		@Override
		public void changeServiceExpirationDate(String newExpirationDate) {
			progressDialog = ProgressDialogUtil.createProgressDialog(OrderDetailActivity.this);
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					String methodName ="UpdateExpirationTime";
					String endPoint = "order";
					JSONObject expirationTimeJson = new JSONObject();
					try {
						expirationTimeJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
						expirationTimeJson.put("ExpirationTime",orderExpirationDateText.getText().toString());
					} catch (JSONException e) {
						
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName, expirationTimeJson.toString(),userinfoApplication);
					if (serverRequestResult == null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(0);
					else {
						int    code = 0;
						String message = "";
						try {
							JSONObject resultJson = new JSONObject(serverRequestResult);
							code = resultJson.getInt("Code");
							message = resultJson.getString("Message");
						} catch (JSONException e) {
							code = 0;
						}
						if (code== 1){
							Message msg = new Message();
							msg.what = 3;
							msg.obj = message;
							mHandler.sendMessage(msg);
						}
						else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
							mHandler.sendEmptyMessage(code);
						else {
							Message msg = new Message();
							msg.what = 2;
							msg.obj = message;
							mHandler.sendMessage(msg);
						}

					}
				}
			};
			requestWebServiceThread.start();
		}
	};
	// 显示课程
	@SuppressLint("NewApi")
	private void createtTreatmentGroupLayout(final List<TreatmentGroup> treatmentGroupList,int showType,int productType) {
		//将TG的信息循环显示在已完成的列表上
		//showType 0:显示未完成的TG  1：显示已完成的Tg
		if(showType==0){
			orderUnCompleteTablelayout.removeAllViews();
			orderCourseTablelayout.removeAllViews();
			orderCourseTablelayout.setVisibility(View.VISIBLE);
		}
		else if(showType==1){
			orderCompleteInfoTablelayout.removeAllViews();
			View  completeTitleView=layoutInflater.inflate(R.xml.treatment_complete_title,null);
			TextView titleText=(TextView)completeTitleView.findViewById(R.id.complete_info_title_text);
			if(transOrderInfo.getProductType()==Constant.SERVICE_TYPE)
				titleText.setText("已完成服务记录");
			else if(transOrderInfo.getProductType()==Constant.COMMODITY_TYPE)
				titleText.setText("已交付商品记录");
			final ImageView completeUpDownIcon=(ImageView)completeTitleView.findViewById(R.id.treatment_complete_up_down_icon);
			if(isOderCompleteRecordShow)
				completeUpDownIcon.setBackgroundResource(R.drawable.report_main_up_icon);
			else
				completeUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
			completeTitleView.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					if(isOderCompleteRecordShow){
						for(int i=0;i<orderCompleteInfoTablelayout.getChildCount();i++){
							if(i!=0)
								orderCompleteInfoTablelayout.getChildAt(i).setVisibility(View.GONE);
						}
						isOderCompleteRecordShow=false;	
						completeUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
					}
					else
						getCompleteTG();	
				}
			});
			orderCompleteInfoTablelayout.addView(completeTitleView);
			if(transOrderInfo.getTgPastCount()!=0){
				View showTgPastCountView=layoutInflater.inflate(R.xml.treatment_group_past_count,null);
				TextView showTgPastCountTextView=(TextView)showTgPastCountView.findViewById(R.id.treatment_group_past_count_text);
				showTgPastCountTextView.setText("过去完成"+transOrderInfo.getTgPastCount()+"次");
				orderCompleteInfoTablelayout.addView(showTgPastCountView);
			}	
			
		}	
		TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
		lp.topMargin = 20;
		lp.leftMargin = 10;
		lp.rightMargin = 10;
		int  completed=0;
		if(treatmentGroupList!=null && treatmentGroupList.size()>0){
			for (int g = 0; g < treatmentGroupList.size(); g++) {
				List<Treatment> treatmentList = treatmentGroupList.get(g).getTreatmentList();
				if (treatmentList != null && treatmentList.size() > 0) {
					for (int t = 0; t < treatmentList.size(); t++) {
						if (treatmentList.get(t).getIsCompleted() != 0) {
							completed = completed + 1;
						}
					}
				}
			}
		}
		if(showType==0){
			//在表格头部添加完成的TG次数和剩余的TG次数
			View     treatmentTotalLayoutView=layoutInflater.inflate(R.xml.order_course_treatment_group_total_layout,null);
			TextView treatmentGroupCompleteText=(TextView)treatmentTotalLayoutView.findViewById(R.id.treatment_group_complete_text);
			TextView treatmentGroupSurplusText=(TextView)treatmentTotalLayoutView.findViewById(R.id.treatment_group_surplus_text);
			if(productType==Constant.SERVICE_TYPE){
				//服务订单时无限次 或者  服务订单有已经完成的服务 或者 已经完成
				if(transOrderInfo.getTotalCount()!=0){
					//开单次数显示的优化20170930
					int executingCount = transOrderInfo.getTotalCount() - transOrderInfo.getCompleteCount() - transOrderInfo.getSurplusCount();
					treatmentGroupCompleteText.setText("进行中"+executingCount+"次/完成"+transOrderInfo.getCompleteCount()+"次/共"+transOrderInfo.getTotalCount()+"次");
					treatmentGroupSurplusText.setText("剩余"+transOrderInfo.getSurplusCount()+"次");
				}
				else{
					treatmentGroupCompleteText.setText("完成"+transOrderInfo.getCompleteCount()+"次/不限次");
				}				
			}
			else if(productType==Constant.COMMODITY_TYPE){
				treatmentGroupCompleteText.setText("已交付"+transOrderInfo.getCompleteCount()+"件/共"+transOrderInfo.getTotalCount()+"件");
				treatmentGroupSurplusText.setText("剩余"+transOrderInfo.getSurplusCount()+"件");
			}
			if(transOrderInfo.getTreatmentGroupList()!=null && transOrderInfo.getTreatmentGroupList().size()>0){
				treatmentTotalLayoutView.findViewById(R.id.treatment_group_complete_divide_view).setVisibility(View.VISIBLE);
			}
			else
				treatmentTotalLayoutView.findViewById(R.id.treatment_group_complete_divide_view).setVisibility(View.GONE);
			orderCourseTablelayout.addView(treatmentTotalLayoutView);
		}
		if(treatmentGroupList!=null && treatmentGroupList.size()>0){
		View treatmentChildLayout;
		if(productType==Constant.SERVICE_TYPE){
			for (int g = 0; g < treatmentGroupList.size(); g++) {
				final TreatmentGroup operationTreatmentGroup=treatmentGroupList.get(g);
				View   treatmentGroupLayout = layoutInflater.inflate(R.xml.treatment_group_layout,null);
				Button treatmentGroupDeleteBtn=(Button) treatmentGroupLayout.findViewById(R.id.treatment_group_delete);
				Button treatmentGroupCompleteBtn=(Button) treatmentGroupLayout.findViewById(R.id.treatment_group_complete);
				TextView treatmentGroupStatusText=(TextView)treatmentGroupLayout.findViewById(R.id.treatment_group_status_text);
				final ImageView treatmentGroupJoinArrowedIcon=(ImageView)treatmentGroupLayout.findViewById(R.id.treatment_group_join_arrowhead);
				final ImageView treatmentGroupUpdateIcon=(ImageView) treatmentGroupLayout.findViewById(R.id.treatment_group_update);
				TextView treatmentGroupStartTimeText=(TextView)treatmentGroupLayout.findViewById(R.id.treatment_group_start_time_text);
				treatmentGroupStartTimeText.setText(operationTreatmentGroup.getStartTime());
				TextView    treatmentGroupServicePicText=(TextView)treatmentGroupLayout.findViewById(R.id.treatment_group_sevice_pic_name_text);
				treatmentGroupServicePicText.setText(operationTreatmentGroup.getServicePicName());
				View        treatmentGroupDivideView=treatmentGroupLayout.findViewById(R.id.treatment_group_divide_view);
				if(g==treatmentGroupList.size()-1 || treatmentGroupList.size()==0 || treatmentGroupList==null)
					treatmentGroupDivideView.setVisibility(View.GONE);
				
				if(showType==1){
					treatmentGroupStatusText.setText(OrderOperationUtil.getTGStatus(operationTreatmentGroup.getStatus()));
					treatmentGroupUpdateIcon.setVisibility(View.INVISIBLE);
					treatmentGroupDeleteBtn.setVisibility(View.GONE);
					treatmentGroupCompleteBtn.setVisibility(View.GONE);
				}
				else if(showType==0){
					if(transOrderInfo.getStatus()!=1 || OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup)==0){
						treatmentGroupDeleteBtn.setVisibility(View.GONE);
						treatmentGroupCompleteBtn.setVisibility(View.GONE);
						treatmentGroupJoinArrowedIcon.setVisibility(View.VISIBLE);
						treatmentGroupUpdateIcon.setVisibility(View.INVISIBLE);
					}
					else{
						treatmentGroupJoinArrowedIcon.setVisibility(View.INVISIBLE);
						treatmentGroupUpdateIcon.setVisibility(View.VISIBLE);
						//撤销Tg
						treatmentGroupDeleteBtn.setOnClickListener(new OnClickListener() {
							
							@Override
							public void onClick(View v) {
								// TODO Auto-generated method stub
								Dialog dialog = new AlertDialog.Builder(OrderDetailActivity.this,R.style.CustomerAlertDialog)
										.setTitle(getString(R.string.delete_dialog_title))
										.setMessage(R.string.delete_treatment)
										.setPositiveButton(getString(R.string.delete_confirm),
												new DialogInterface.OnClickListener() {
													@Override
													public void onClick(DialogInterface dialog,int which) {
														dialog.dismiss();
														deleteTreatmentGroup(operationTreatmentGroup);
													}
												})
										.setNegativeButton(getString(R.string.delete_cancel),
												new DialogInterface.OnClickListener() {
													@Override
													public void onClick(DialogInterface dialog,int which) {
														dialog.dismiss();
														dialog = null;
													}
												}).create();
								dialog.show();
								dialog.setCancelable(false);
							}
						});
						//完成TG
						treatmentGroupCompleteBtn.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View v) {
								// TODO Auto-generated method stub
								Dialog dialog = new AlertDialog.Builder(OrderDetailActivity.this,R.style.CustomerAlertDialog)
										.setTitle(getString(R.string.delete_dialog_title))
										.setMessage(R.string.complete_treatment)
										.setPositiveButton(getString(R.string.delete_confirm),
												new DialogInterface.OnClickListener() {
													@Override
													public void onClick(DialogInterface dialog,int which) {
														dialog.dismiss();
														checkConfirmed(operationTreatmentGroup);
													}
												})
										.setNegativeButton(getString(R.string.delete_cancel),
												new DialogInterface.OnClickListener() {
													@Override
													public void onClick(DialogInterface dialog,int which) {
														dialog.dismiss();
														dialog = null;
													}
												}).create();
								dialog.show();
								dialog.setCancelable(false);
							}
						});
					}
					treatmentGroupStatusText.setVisibility(View.GONE);	
				}
				final TreatmentGroup treatmentGroup = treatmentGroupList.get(g);
				List<Treatment> treatmentList = treatmentGroup.getTreatmentList();	
				RelativeLayout treatmentGroupOperationRelativelayout = (RelativeLayout) treatmentGroupLayout.findViewById(R.id.treatment_group_operation_relativelayout);
				// 订单是未完成状态并且有操作该订单的权限
				if(showType==0){
					if (transOrderInfo.getStatus() == 1 && OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup)==1) {
						// 对服务组的完成和删除
						treatmentGroupOperationRelativelayout.setOnClickListener(new OnClickListener() {
									@Override
									public void onClick(View view) {
										showTreatmentGroupUpdateDialog(treatmentGroup);
									}
								});
					}
					//点击服务组的详情
					else{
						treatmentGroupOperationRelativelayout.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View v) {
								// TODO Auto-generated method stub
								treatmentUpdateDialog.dismiss();
								Intent destIntent=new Intent(OrderDetailActivity.this,TreatmentGroupDetailTabActivity.class);
								destIntent.putExtra("orderEditFlag",OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup));
								destIntent.putExtra("GroupNo",String.valueOf(treatmentGroup.getTreatmentGroupID()));
								destIntent.putExtra("OrderID",transOrderInfo.getOrderID());
								startActivity(destIntent);
							}
						});
					}
				}
				else if(showType==1){
					treatmentGroupOperationRelativelayout.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							treatmentUpdateDialog.dismiss();
							Intent destIntent=new Intent(OrderDetailActivity.this,TreatmentGroupDetailTabActivity.class);
							destIntent.putExtra("CustomerID",transOrderInfo.getCustomerID());
							destIntent.putExtra("orderEditFlag",OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup));
							destIntent.putExtra("GroupNo",String.valueOf(treatmentGroup.getTreatmentGroupID()));
							destIntent.putExtra("OrderID",transOrderInfo.getOrderID());
							startActivity(destIntent);
						}
					});
				}
				LinearLayout treatmentChildLinearLayout = (LinearLayout) treatmentGroupLayout.findViewById(R.id.treatment_child_linearlayout);
				if (treatmentList != null && treatmentList.size() > 0) {
					for (int t = 0; t < treatmentList.size(); t++) {
						final Treatment treatment = treatmentList.get(t);
						treatmentChildLayout = layoutInflater.inflate(R.xml.course_treatment_layout,null);
						// 待确认或者已完成的服务点击,或者是无权限编辑订单这一行 跳转到服务详细页面
						if (treatmentList.get(t).getIsCompleted() != 1 || transOrderInfo.getStatus() != 1 || OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup)==0) {
							treatmentChildLayout.setOnClickListener(new OnClickListener() {
										@Override
										public void onClick(View v) {
											Intent destIntent = new Intent(OrderDetailActivity.this,TreatmentDetailActivity.class);
											Bundle mBundle = new Bundle();
											mBundle.putSerializable("treatmentGroup",(Serializable)treatmentGroup);
											mBundle.putSerializable("treatment",(Serializable) treatment);
											destIntent.putExtras(mBundle);
											destIntent.putExtra("CustomerID",transOrderInfo.getCustomerID());
											destIntent.putExtra("orderEditFlag",OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup));
											startActivity(destIntent);
										}
									});
						}
						// 是未完成的服务 点击这一行出现四个菜单项
						else {
							treatmentChildLayout.setOnClickListener(new OnClickListener() {
										@Override
										public void onClick(View v) {
											showTreatmentUpdateDialog(treatmentGroup,treatment);
										}
									});
						}
						TextView treatmentExecutorName = (TextView)treatmentChildLayout.findViewById(R.id.textview_executor_name);
						treatmentExecutorName.setText(treatment.getExecutorName());
						TextView treatmentSubServiceText = (TextView)treatmentChildLayout.findViewById(R.id.treatment_subservice_text);
						treatmentSubServiceText.setText(treatment.getSubServiceName());
						ImageView treatmentIsDesignatedIcon=(ImageView)treatmentChildLayout.findViewById(R.id.treatment_is_designated_icon);
						if(treatment.isDesignated())
							treatmentIsDesignatedIcon.setVisibility(View.VISIBLE);
						else
							treatmentIsDesignatedIcon.setVisibility(View.INVISIBLE);
						treatmentChildLinearLayout.addView(treatmentChildLayout);
						ImageView arrowheadIcon = (ImageView) treatmentChildLayout.findViewById(R.id.arrowhead);
						ImageView treatmentUpdateButton = (ImageView) treatmentChildLayout.findViewById(R.id.treatment_update);
						if (transOrderInfo.getStatus() == 1 && OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,operationTreatmentGroup)==1) {
							if (treatment.getIsCompleted() == 2 || treatment.getIsCompleted() == 3 || treatment.getIsCompleted()==4 || treatment.getIsCompleted()==5) {
								treatmentUpdateButton.setVisibility(View.INVISIBLE);
							} else if (treatment.getIsCompleted() == 1) {
								// 服务订单的每一行最后的操作按钮
								arrowheadIcon.setVisibility(View.INVISIBLE);
							}
						} else {
							treatmentUpdateButton.setVisibility(View.INVISIBLE);
							arrowheadIcon.setVisibility(View.VISIBLE);
						}
					}
				}
				if(showType==0)
					orderCourseTablelayout.addView(treatmentGroupLayout);
				else if(showType==1){
					treatmentGroupLayout.startAnimation(mShowAction);
					orderCompleteInfoTablelayout.addView(treatmentGroupLayout);
				}
					
			}
		}
		//如果是商品的
		else if(productType==Constant.COMMODITY_TYPE){
			for (int g = 0; g < treatmentGroupList.size(); g++) {
				final TreatmentGroup treatmentGroup=treatmentGroupList.get(g);
				if(showType==0){
					View   commodityDeliveryLayout = layoutInflater.inflate(R.xml.commodity_delivery_layout,null);
					TextView commodityDeliveryTitleText=(TextView)commodityDeliveryLayout.findViewById(R.id.commodity_delivery_title);
					TextView commodityDeliveryTime=(TextView)commodityDeliveryLayout.findViewById(R.id.commodity_delivery_start_time_text);
					TextView commodityQuantityText=(TextView) commodityDeliveryLayout.findViewById(R.id.commodity_delivery_quantity_text);
					Button   commodityDeliveryBtn=(Button)commodityDeliveryLayout.findViewById(R.id.commodity_delivery_btn);
					Button   commodityDeliveryCancelBtn=(Button)commodityDeliveryLayout.findViewById(R.id.commodity_delivery_delete);
					if(transOrderInfo.getStatus()!=1 || OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,treatmentGroup)==0){
						commodityDeliveryBtn.setVisibility(View.GONE);
						commodityDeliveryCancelBtn.setVisibility(View.GONE);
					}
					else{
						commodityDeliveryBtn.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View view) {
								Dialog dialog = new AlertDialog.Builder(OrderDetailActivity.this,R.style.CustomerAlertDialog)
								.setTitle(getString(R.string.delete_dialog_title))
								.setMessage(R.string.delivery_commodity)
								.setPositiveButton(getString(R.string.delete_confirm),
										new DialogInterface.OnClickListener() {
											@Override
											public void onClick(DialogInterface dialog,int which) {
												dialog.dismiss();
												checkConfirmed(treatmentGroup);
											}
										})
								.setNegativeButton(getString(R.string.delete_cancel),
										new DialogInterface.OnClickListener() {
											@Override
											public void onClick(DialogInterface dialog,int which) {
												dialog.dismiss();
												dialog = null;
											}
										}).create();
								dialog.show();
								dialog.setCancelable(false);
							}
						});
						commodityDeliveryCancelBtn.setOnClickListener(new OnClickListener() {
							
							@Override
							public void onClick(View arg0) {
								// TODO Auto-generated method stub
								Dialog dialog = new AlertDialog.Builder(OrderDetailActivity.this,R.style.CustomerAlertDialog)
								.setTitle(getString(R.string.delete_dialog_title))
								.setMessage(R.string.cancel_delivery_commodity)
								.setPositiveButton(getString(R.string.delete_confirm),
										new DialogInterface.OnClickListener() {
											@Override
											public void onClick(DialogInterface dialog,int which) {
												dialog.dismiss();
												deleteTreatmentGroup(treatmentGroup);
											}
										})
								.setNegativeButton(getString(R.string.delete_cancel),
										new DialogInterface.OnClickListener() {
											@Override
											public void onClick(DialogInterface dialog,int which) {
												dialog.dismiss();
												dialog = null;
											}
										}).create();
								dialog.show();
								dialog.setCancelable(false);
							}
						});
					}
					commodityDeliveryTitleText.setText("本次交付数量");
					commodityQuantityText.setText(treatmentGroup.getCommodityQuantity()+"件");
					commodityDeliveryTime.setText(treatmentGroup.getStartTime());
					orderCourseTablelayout.addView(commodityDeliveryLayout);
				}
				else if(showType==1){
					View     commodityDeliveryFinishedLayout = layoutInflater.inflate(R.xml.commodity_delivery_finished_layout,null);
					TextView commodityDeliveryFinishedNoText=(TextView)commodityDeliveryFinishedLayout.findViewById(R.id.commodity_delivery_finished_no_text);
					TextView commodityDeliveryFinishedTime=(TextView)commodityDeliveryFinishedLayout.findViewById(R.id.commodity_delivery_finished_start_time_text);
					TextView commodityDeliveryFinishedStatusText=(TextView)commodityDeliveryFinishedLayout.findViewById(R.id.commodity_delivery_finished_status_text);
					TextView commodityDeliveryFinishedPicNameText=(TextView)commodityDeliveryFinishedLayout.findViewById(R.id.commodity_delivery_finished_pic_name_text);
					//显示商品交付详情 包括商品交付编号和商品签字
					commodityDeliveryFinishedLayout.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							Dialog dialog = new Dialog(OrderDetailActivity.this,R.style.CustomerAlertDialog);
							Window window=dialog.getWindow();
							window.requestFeature(Window.FEATURE_NO_TITLE);
							View commodityDeliveryDetailView=layoutInflater.inflate(R.xml.commodity_deliver_detail,null);
							TextView commodityDeliveryGroupNo=(TextView)commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_group_no);
							commodityDeliveryGroupNo.setText(String.valueOf(treatmentGroup.getTreatmentGroupID()));
							//顾客签字
							if(treatmentGroup.getSignImageUrl()!=null && !"".equals(treatmentGroup.getSignImageUrl())){
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_before_divide_view).setVisibility(View.VISIBLE);
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_before_relativelayout).setVisibility(View.VISIBLE);
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_divide_view).setVisibility(View.VISIBLE);
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_relativelayout).setVisibility(View.VISIBLE);
								ImageView signImage=(ImageView)commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_image);
								imageLoader.displayImage(treatmentGroup.getSignImageUrl().split("&")[0],signImage,displayImageOptions);
							}
							else{
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_before_divide_view).setVisibility(View.GONE);
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_before_relativelayout).setVisibility(View.GONE);
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_divide_view).setVisibility(View.GONE);
								commodityDeliveryDetailView.findViewById(R.id.commodity_deliver_detail_sign_relativelayout).setVisibility(View.GONE);
							}
							dialog.setContentView(commodityDeliveryDetailView);
							dialog.setCanceledOnTouchOutside(true);
							dialog.show();
						}
					});
					commodityDeliveryFinishedNoText.setText((g+1)+".");
					commodityDeliveryFinishedTime.setText(treatmentGroup.getStartTime());
					commodityDeliveryFinishedStatusText.setText(OrderOperationUtil.getTGStatus(treatmentGroup.getStatus())+"|"+treatmentGroup.getCommodityQuantity()+"件");
					commodityDeliveryFinishedPicNameText.setText(treatmentGroup.getServicePicName());
					commodityDeliveryFinishedLayout.startAnimation(mShowAction);
					orderCompleteInfoTablelayout.addView(commodityDeliveryFinishedLayout);
				}
			}
		}
		}
	}

	protected void initView() {
		progressDialog = new ProgressDialog(OrderDetailActivity.this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		userRole = getIntent().getIntExtra("userRole",Constant.USER_ROLE_CUSTOMER);
		fromOrderList = getIntent().getBooleanExtra("FromOrderList",false);
		if (requestWebServiceThread == null) {
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					String methodName = "getOrderDetail";
					String endPoint = "order";
					JSONObject orderDetailParamJson = new JSONObject();
					try {
						orderDetailParamJson.put("OrderObjectID",orderInfo.getOrderObejctID());
						orderDetailParamJson.put("ProductType",orderInfo.getProductType());
					} catch (JSONException e) {
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName, orderDetailParamJson.toString(),userinfoApplication);
					JSONObject resultJson = null;
					try {
						resultJson = new JSONObject(serverRequestResult);
					} catch (JSONException e) {

					}
					if (serverRequestResult == null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(0);
					else {
						int    code = 0;
						String message = "";
						try {
							code =resultJson.getInt("Code");
							message =resultJson.getString("Message");
						} catch (JSONException e) {
							code = 0;
						}
						JSONObject orderDetailJson = null;
						try {
							orderDetailJson = resultJson.getJSONObject("Data");
						} catch (JSONException e) {

						}
						if (code== 1 && orderDetailJson != null) {
							transOrderInfo = new OrderInfo();
							transOrderInfo.setOrderID(orderInfo.getOrderID());
							transOrderInfo.setOrderObejctID(orderInfo.getOrderObejctID());
							transOrderInfo.setIsThisBranch(orderInfo.getIsThisBranch());
							String  orderSerialNumber = "";
							String  orderTime = "";
							int     productType = 0;
							String  productName = "";
							int     quantity = 0;
							int     status = 0;
							double  unPaidPrice = 0;
							int     paymentStatus = 0;
							String  subServiceIDs = "";
							double   totalPrice = 0;
							double   totalCalculatePrice=0;
							double   totalSalePrice = 0;
							int     responsiblePersonID = 0;
							String responsiblePersonName = "";
							String salesName = "";
							int    customerID = 0;
							String customerName = "";
							int    creatorID = 0;
							String creatorName = "";
							String orderRemark = "";
							double customerEcardBalance = 0;
							String expirationTime = "";
							int   completeCount=0;
							int   totalCount=0;
							int   surplusCount=0;
							int   tgPastCount=0;
							int   scdlCount=0;
							boolean hasNetTrade=false;
							boolean isMergePay=false;
							double  refundPrice = 0;
							int     isConfirmed=0;
							ArrayList<CustomerBenefit>  customerBenefitList=null;
							//预约是否显示于结账后 20171010
							boolean appointmentMustPaid=false;
							try {
								if (orderDetailJson.has("AppointmentMustPaid")) {
									appointmentMustPaid = orderDetailJson.getBoolean("AppointmentMustPaid");
								}
								transOrderInfo.setAppointmentMustPaid(appointmentMustPaid);
								
								if (orderDetailJson.has("OrderID"))
									transOrderInfo.setOrderID(orderDetailJson.getInt("OrderID"));
								if (orderDetailJson.has("OrderNumber"))
									orderSerialNumber = orderDetailJson.getString("OrderNumber");
								transOrderInfo.setOrderSerialNumber(orderSerialNumber);
								if (orderDetailJson.has("OrderTime"))
									orderTime = orderDetailJson.getString("OrderTime");
								transOrderInfo.setOrderTime(orderTime);
								if (orderDetailJson.has("ProductType"))
									productType = orderDetailJson.getInt("ProductType");
								transOrderInfo.setProductType(productType);
								if (orderDetailJson.has("ProductName"))
									productName = orderDetailJson.getString("ProductName");
								transOrderInfo.setProductName(productName);
								if (orderDetailJson.has("Quantity"))
									quantity = orderDetailJson.getInt("Quantity");
								transOrderInfo.setQuantity(quantity);
								if (orderDetailJson.has("Status"))
									status = orderDetailJson.getInt("Status");
								transOrderInfo.setStatus(status);
								if (orderDetailJson.has("UnPaidPrice"))
									unPaidPrice = Double.valueOf(orderDetailJson.getString("UnPaidPrice"));
								transOrderInfo.setUnpaidPrice(String.valueOf(unPaidPrice));
								if (orderDetailJson.has("RefundSumAmount"))
									refundPrice = Double.valueOf(orderDetailJson.getString("RefundSumAmount"));
								transOrderInfo.setRefundAmount(String.valueOf(refundPrice));
								if (orderDetailJson.has("PaymentStatus"))
									paymentStatus = orderDetailJson.getInt("PaymentStatus");
								transOrderInfo.setPaymentStatus(paymentStatus);
								if (orderDetailJson.has("SubServiceIDs"))
									subServiceIDs = orderDetailJson.getString("SubServiceIDs");
								transOrderInfo.setSubServiceIDs(subServiceIDs);
								if (orderDetailJson.has("TotalOrigPrice"))
									totalPrice = Double.valueOf(orderDetailJson.getString("TotalOrigPrice"));
								transOrderInfo.setTotalPrice(String.valueOf(totalPrice));
								if (orderDetailJson.has("TotalCalcPrice"))
									totalCalculatePrice = Double.valueOf(orderDetailJson.getString("TotalCalcPrice"));
								transOrderInfo.setTotalCalculatePrice(String.valueOf(totalCalculatePrice));
								if (orderDetailJson.has("TotalSalePrice"))
									totalSalePrice = Double.valueOf(orderDetailJson.getString("TotalSalePrice"));
								transOrderInfo.setTotalSalePrice(String.valueOf(totalSalePrice));
								if (orderDetailJson.has("ResponsiblePersonID"))
									responsiblePersonID = orderDetailJson.getInt("ResponsiblePersonID");
								transOrderInfo.setResponsiblePersonID(responsiblePersonID);
								if (orderDetailJson.has("ResponsiblePersonName") && !orderDetailJson.isNull("ResponsiblePersonName"))
									responsiblePersonName = orderDetailJson.getString("ResponsiblePersonName");
								transOrderInfo.setResponsiblePersonName(responsiblePersonName);
								JSONArray salesJsonArray=null;
								if(orderDetailJson.has("SalesList"))
									salesJsonArray=orderDetailJson.getJSONArray("SalesList");
								if(salesJsonArray!=null){
									for(int j=0;j<salesJsonArray.length();j++){
										if(j==salesJsonArray.length()-1)
											salesName+=salesJsonArray.getJSONObject(j).getString("SalesName");
										else
											salesName+=salesJsonArray.getJSONObject(j).getString("SalesName")+"、";
									}
								}
								transOrderInfo.setSalesName(salesName);
								if (orderDetailJson.has("CustomerID"))
									customerID = orderDetailJson.getInt("CustomerID");
								transOrderInfo.setCustomerID(customerID);
								if (orderDetailJson.has("CustomerName"))
									customerName = orderDetailJson.getString("CustomerName");
								transOrderInfo.setCustomerName(customerName);
								if (orderDetailJson.has("CreatorID"))
									creatorID = orderDetailJson.getInt("CreatorID");
								transOrderInfo.setCreatorID(creatorID);
								if (orderDetailJson.has("CreatorName"))
									creatorName = orderDetailJson.getString("CreatorName");
								transOrderInfo.setCreatorName(creatorName);
								if (orderDetailJson.has("Remark"))
									orderRemark = orderDetailJson.getString("Remark");
								transOrderInfo.setOrderRemark(orderRemark);
								if (orderDetailJson.has("Balance"))
									customerEcardBalance = Double.valueOf(orderDetailJson.getString("Balance"));
								userinfoApplication.setCustomerEcardBblanceValue(customerEcardBalance);
								if (orderDetailJson.has("ExpirationTime"))
									expirationTime = orderDetailJson.getString("ExpirationTime");
								transOrderInfo.setOrderExpirationDate(expirationTime);
								boolean isPast = false;
								if (orderDetailJson.has("IsPast"))
									isPast = orderDetailJson.getBoolean("IsPast");
								transOrderInfo.setPast(isPast);
								if (orderDetailJson.has("BranchID"))
									transOrderInfo.setBranchID(orderDetailJson.getInt("BranchID"));
								if (orderDetailJson.has("BranchName"))
									transOrderInfo.setBranchName(orderDetailJson.getString("BranchName"));
								if (orderDetailJson.has("FinishedCount"))
									completeCount = orderDetailJson.getInt("FinishedCount");
								transOrderInfo.setCompleteCount(completeCount);
								if (orderDetailJson.has("TotalCount"))
									totalCount = orderDetailJson.getInt("TotalCount");
								transOrderInfo.setTotalCount(totalCount);
								if (orderDetailJson.has("SurplusCount"))
									surplusCount = orderDetailJson.getInt("SurplusCount");
								transOrderInfo.setSurplusCount(surplusCount);
								if (orderDetailJson.has("PastCount"))
									tgPastCount= orderDetailJson.getInt("PastCount");
								transOrderInfo.setTgPastCount(tgPastCount);
								if (orderDetailJson.has("ScdlCount"))
									scdlCount=orderDetailJson.getInt("ScdlCount");
								transOrderInfo.setScdlCount(scdlCount);
								if (orderDetailJson.has("IsMergePay"))
									isMergePay=orderDetailJson.getBoolean("IsMergePay");
								transOrderInfo.setMergePay(isMergePay);
								//是否有第三方支付记录
								if (orderDetailJson.has("HasNetTrade"))
									hasNetTrade=orderDetailJson.getBoolean("HasNetTrade");
								transOrderInfo.setHasNetTrade(hasNetTrade);
								//该订单的确认方式
								if (orderDetailJson.has("IsConfirmed") && !orderDetailJson.isNull("IsConfirmed"))
									isConfirmed=orderDetailJson.getInt("IsConfirmed");
								transOrderInfo.setIsConfirmed(isConfirmed);
								//是否使用了券
								if(orderDetailJson.has("BenefitList") && !orderDetailJson.isNull("BenefitList")){
									customerBenefitList=new ArrayList<CustomerBenefit>();
									JSONArray   benefitJsonArray=orderDetailJson.getJSONArray("BenefitList");
									for(int s=0;s<benefitJsonArray.length();s++){
										JSONObject benefitJson=benefitJsonArray.getJSONObject(s);
										CustomerBenefit customerBenefit=new CustomerBenefit();
										if(benefitJson.has("PolicyName"))
											customerBenefit.setBenefitName(benefitJson.getString("PolicyName"));
										if(benefitJson.has("PRValue2"))
											customerBenefit.setPrValue2(benefitJson.getDouble("PRValue2"));
										customerBenefitList.add(customerBenefit);
									}
									transOrderInfo.setCustomerBenefitList(customerBenefitList);
								}
								
								if(orderDetailJson.has("ScdlList") && !orderDetailJson.isNull("ScdlList")){
									JSONArray   appointmentJsonArray=orderDetailJson.getJSONArray("ScdlList");
									List<AppointmentInfo> appointmentList=new ArrayList<AppointmentInfo>();
									for(int s=0;s<appointmentJsonArray.length();s++){
										JSONObject appointmentJson=appointmentJsonArray.getJSONObject(s);
										AppointmentInfo appointment=new AppointmentInfo();
										if(appointmentJson.has("TaskID"))
										    appointment.setTaskID(appointmentJson.getLong("TaskID"));
										if(appointmentJson.has("ResponsiblePersonName"))
										    appointment.setResponsiblePersonName(appointmentJson.getString("ResponsiblePersonName"));
										if(appointmentJson.has("TaskScdlStartTime"))
											appointment.setTaskScdlStartTime(appointmentJson.getString("TaskScdlStartTime"));
										appointmentList.add(appointment);
									}
									transOrderInfo.setAppointmentList(appointmentList);
								}
								if (orderDetailJson.has("GroupList")&& !orderDetailJson.isNull("GroupList")) {
												JSONArray treatmentGroupArray = orderDetailJson.getJSONArray("GroupList");
												List<TreatmentGroup> treatmentGroupList = new ArrayList<TreatmentGroup>();
												for (int g = 0; g < treatmentGroupArray.length(); g++) {
													TreatmentGroup treatmentGroup = new TreatmentGroup();
													JSONObject treatmentGroupDeatilJson = treatmentGroupArray.getJSONObject(g);
													treatmentGroup.setTreatmentGroupID(treatmentGroupDeatilJson.getLong("GroupNo"));
													treatmentGroup.setServicePicID(treatmentGroupDeatilJson.getInt("ServicePicID"));
													treatmentGroup.setStartTime(treatmentGroupDeatilJson.getString("StartTime"));
													treatmentGroup.setServicePicName(treatmentGroupDeatilJson.getString("ServicePicName"));
													
													if(transOrderInfo.getProductType()==Constant.COMMODITY_TYPE){
														treatmentGroup.setCommodityQuantity(treatmentGroupDeatilJson.getInt("Quantity"));	
													}
													if (treatmentGroupDeatilJson.has("TreatmentList") && !treatmentGroupDeatilJson.isNull("TreatmentList")) {
														List<Treatment> treatmentList = new ArrayList<Treatment>();
														JSONArray courseTreatmentJsonArray = treatmentGroupDeatilJson.getJSONArray("TreatmentList");
														for (int j = 0; j < courseTreatmentJsonArray.length(); j++) {
															Treatment treatment = new Treatment();
															JSONObject treatmentDetailJson = courseTreatmentJsonArray.getJSONObject(j);
															String subServiceName = "";
															if (treatmentDetailJson.has("SubServiceName"))
																subServiceName = treatmentDetailJson.getString("SubServiceName");
															if(subServiceName.equals(""))
																treatment.setSubServiceName("服务操作");
															else
																treatment.setSubServiceName(subServiceName);
															int executorID = 0;
															if (treatmentDetailJson.has("ExecutorID"))
																executorID = treatmentDetailJson.getInt("ExecutorID");
															treatment.setExecutorID(executorID);
															String executorName = "";
															if (treatmentDetailJson.has("ExecutorName"))
																executorName = treatmentDetailJson.getString("ExecutorName");
															treatment.setExecutorName(executorName);
															int treatmentID = 0;
															if (treatmentDetailJson.has("TreatmentID"))
																treatmentID = treatmentDetailJson.getInt("TreatmentID");
															treatment.setId(treatmentID);
															int scheduleID = 0;
															if (treatmentDetailJson.has("ScheduleID"))
																scheduleID = treatmentDetailJson.getInt("ScheduleID");
															treatment.setScheduleID(scheduleID);
															int isCompleted = 0;
															if (treatmentDetailJson.has("Status"))
																isCompleted = treatmentDetailJson.getInt("Status");
															treatment.setIsCompleted(isCompleted);
															String remark = "";
															if (treatmentDetailJson.has("Remark"))
																remark = treatmentDetailJson.getString("Remark");
															treatment.setRemark(remark);
															if(treatmentDetailJson.has("TreatmentCode"))
																treatment.setTreatmentCode(treatmentDetailJson.getString("TreatmentCode"));
															treatment.setDesignated(treatmentDetailJson.getBoolean("IsDesignated"));
															treatmentList.add(treatment);
														}
														treatmentGroup.setTreatmentList(treatmentList);
													}
													treatmentGroupList.add(treatmentGroup);
												}
												transOrderInfo.setTreatmentGroupList(treatmentGroupList);
											}
										
							} catch (JSONException e) {
							}
							Message msg = new Message();
							msg.obj = transOrderInfo;
							msg.what = 1;
							mHandler.sendMessage(msg);
						}
						else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
							mHandler.sendEmptyMessage(code);
						else {
							Message msg = new Message();
							msg.what = 2;
							msg.obj = message;
							mHandler.sendMessage(msg);
						}
					}
				}
			};
			requestWebServiceThread.start();
		}

	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
		String isExit = intent.getStringExtra("exit");
		if (isExit != null && isExit.equals("1")) {
			userinfoApplication.setAccountInfo(null);
			userinfoApplication.setSelectedCustomerID(0);
			userinfoApplication.setSelectedCustomerName("");
			userinfoApplication.setSelectedCustomerHeadImageURL("");
			userinfoApplication.setSelectedCustomerLoginMobile("");
			userinfoApplication.setAccountNewMessageCount(0);
			userinfoApplication.setAccountNewRemindCount(0);
			userinfoApplication.setOrderInfo(null);
			Constant.formalFlag = 0;
			finish();
		}
	}

	@Override
	public void onClick(View view) {
		if(ProgressDialogUtil.isFastClick())
			return;
		final String endPoint = "Order";
		switch(view.getId()){
		case R.id.order_detail_pay_btn:
			Intent destIntent=new Intent(this,PaymentActionActivity.class);
			List<OrderInfo> paidOrderList=new ArrayList<OrderInfo>();
			paidOrderList.add(transOrderInfo);
			Bundle bundle=new Bundle();
			bundle.putSerializable("paidOrderList",(Serializable)paidOrderList);
			destIntent.putExtras(bundle);
			destIntent.putExtra("CUSTOMER_ID",transOrderInfo.getCustomerID());
			startActivity(destIntent);
			break;
		case R.id.order_detail_remark_save_btn:
			// 修改订单的备注 保存
			progressDialog =ProgressDialogUtil.createProgressDialog(this);
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
								String methodName = "updateOrderRemark";
								JSONObject orderRemarkJson = new JSONObject();
								try {
									orderRemarkJson.put("OrderID",transOrderInfo.getOrderID());
									orderRemarkJson.put("ProductType",transOrderInfo.getProductType());
									orderRemarkJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
									orderRemarkJson.put("Remark",orderRemarkEditText.getText().toString());
								} catch (JSONException e) {
								}
								String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,orderRemarkJson.toString(),userinfoApplication);
								if (serverRequestResult == null || serverRequestResult.equals(""))
									mHandler.sendEmptyMessage(0);
								else {
									int    code = 0;
									String message = "";
									try {
										JSONObject resultJson = new JSONObject(serverRequestResult);
										code = resultJson.getInt("Code");
										message = resultJson.getString("Message");
									} catch (JSONException e) {
										code = 0;
									}
									if (code == 1)
									{
										Message msg = new Message();
										msg.what = 3;
										msg.obj = message;
										mHandler.sendMessage(msg);
									}
									else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
										mHandler.sendEmptyMessage(code);
									else {
										Message msg = new Message();
										msg.what = 2;
										msg.obj = message;
										mHandler.sendMessage(msg);
									}

								}
							}
						};
						requestWebServiceThread.start();
			break;
		case R.id.order_detail_expiration_date_relativelayout:
			// 更换服务订单的有效期日期
			DateButton dateButton = new DateButton(this,orderExpirationDateText,Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION,changeServiceExpirationDateListener);
			dateButton.datePickerDialog();
			break;
		case R.id.order_detail_service_expiration_date_text:
			// 更换服务订单的有效期日期
			DateButton dateButton2 = new DateButton(this,orderExpirationDateText,Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION,changeServiceExpirationDateListener);
			dateButton2.datePickerDialog();
			break;
		case R.id.order_detail_service_order_expiration_date_btn:
			// 更换服务订单的有效期日期
			DateButton dateButton3 = new DateButton(this,orderExpirationDateText,Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION,changeServiceExpirationDateListener);
			dateButton3.datePickerDialog();
			break;
		case R.id.layout_order_serial_number:
			hideOrShowOrderBasic();
			break;
		case R.id.order_detail_product_name_relativelayout:
			hideOrShowOrderProduct();
			break;
		//取消或者终止订单
		case R.id.order_detail_delete_btn:
			//终止或者取消订单
			deleteOrder();
		 break;
		 //完成订单
		case R.id.order_detail_complete_btn:
			Dialog dialog = new AlertDialog.Builder(this,R.style.CustomerAlertDialog)
					.setTitle(getString(R.string.delete_dialog_title)).setMessage(R.string.service_order_complete)
					.setPositiveButton(getString(R.string.delete_confirm),new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									dialog.dismiss();
									progressDialog = new ProgressDialog(OrderDetailActivity.this,R.style.CustomerProgressDialog);
									progressDialog.setMessage(getString(R.string.please_wait));
									progressDialog.show();
									progressDialog.setCancelable(false);
									completeOrder();
								}
							})
					.setNegativeButton(getString(R.string.delete_cancel),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									dialog.dismiss();
									dialog = null;
								}
							}).create();
			dialog.show();
			dialog.setCancelable(false);
			break;
		case R.id.order_detail_customer_name_relativelayout:
			if(userinfoApplication.getAccountInfo().getAuthMyCustomerRead()==0){
				DialogUtil.createShortDialog(this,"您没有查看顾客的权限");
			}
			else{
				userinfoApplication.setSelectedCustomerID(transOrderInfo.getCustomerID());
				Intent customerServicingIntent=new Intent(this,CustomerServicingActivity.class);
				startActivity(customerServicingIntent);
			}
			break;
		//查看第三方支付列表
		case R.id.order_detail_third_part_pay_relativelayout:
			Intent resultIntent=new Intent();
			resultIntent.setClass(this,OrderDetailThirdPartPayListActivity.class);
			resultIntent.putExtra("orderID",transOrderInfo.getOrderID());
			resultIntent.putExtra("thirdPartPayType",0);
			startActivity(resultIntent);
			break;
		}
	}
	//动画定义
	private void initAnimations()
    {
        mShowAction = AnimationUtils.loadAnimation(this,R.anim.anim_view_show);
        mHiddenAction = AnimationUtils.loadAnimation(this,R.anim.anim_view_hidden);
    }
	//点击订单编号时
	private void hideOrShowOrderBasic(){
		if(isOrderBasicHide){
			for(int i=0;i<orderDetailBasicTableLayout.getChildCount();i++){
				if(i!=0){
					orderDetailBasicTableLayout.getChildAt(i).setVisibility(View.VISIBLE);
					orderDetailBasicTableLayout.getChildAt(i).startAnimation(mShowAction);
				}
			}
			//特殊处理销售顾问的显示
			String salesName = transOrderInfo.getSalesName();
			if (userinfoApplication.getAccountInfo().getModuleInUse().contains("|4|") && salesName!=null && !salesName.equals("")) {
				((TextView) findViewById(R.id.order_detail_sales_name)).setText(salesName);
			} 
			else{
				findViewById(R.id.sales_name_divide_view).setVisibility(View.GONE);
				findViewById(R.id.sales_name_relativelayout).setVisibility(View.GONE);
			}
			// 如果商品订单 不需要显示服务有效期
			if (transOrderInfo.getProductType() == Constant.COMMODITY_TYPE) {
				orderExpirationDateDivideView.setVisibility(View.GONE);
				orderExpirationDateDivideRelativelayout.setVisibility(View.GONE);
			} else {
				orderExpirationDateText.setText(DateUtil.getFormateDateByString(transOrderInfo.getOrderExpirationDate()));
				// 服务订单有效期在今天之前 并且 订单状态不是已完成状态
				if (DateUtil.compareDate(transOrderInfo.getOrderExpirationDate())&& transOrderInfo.getStatus() == 1) {
					orderDetailHasExpirationIcon.setVisibility(View.VISIBLE);
				} else {
					orderDetailHasExpirationIcon.setVisibility(View.GONE);
				}
			}
			isOrderBasicHide=false;
			orderBasicUpDownIcon.setBackgroundResource(R.drawable.report_main_up_icon);
		}
		else if(!isOrderBasicHide){
			for(int i=0;i<orderDetailBasicTableLayout.getChildCount();i++){
				if(i!=0){
					orderDetailBasicTableLayout.getChildAt(i).setVisibility(View.GONE);
					orderDetailBasicTableLayout.getChildAt(i).startAnimation(mHiddenAction);
				}
			}
			isOrderBasicHide=true;
			orderBasicUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
		}
	}
	//点击订单产品名称时
	private void hideOrShowOrderProduct(){
		if(isOrderProductNameHide){
			for(int i=0;i<orderDetailProductNameTablelayout.getChildCount();i++){
				if(i!=0){
					orderDetailProductNameTablelayout.getChildAt(i).setVisibility(View.VISIBLE);
					orderDetailProductNameTablelayout.getChildAt(i).startAnimation(mShowAction);
				}
			}
			// 只有订单是部分付状态并且不是0元订单时 显示未付余额
			if (transOrderInfo.getPaymentStatus() == 2) {
				((TextView) findViewById(R.id.order_detail_unpaid_price_text)).setText(userinfoApplication.getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(transOrderInfo.getUnpaidPrice()));
			} else {
				findViewById(R.id.order_detail_upaid_price_view).setVisibility(View.GONE);
				findViewById(R.id.order_detail_unpaid_price_relativelayout).setVisibility(View.GONE);
			}
			//只有退款金额不为0时，则显示退款金额
			if (Double.valueOf(transOrderInfo.getRefundAmount())!=0) {
				((TextView) findViewById(R.id.order_detail_refund_price_text)).setText(userinfoApplication.getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(transOrderInfo.getRefundAmount()));
			} else {
				findViewById(R.id.order_detail_refund_price_view).setVisibility(View.GONE);
				findViewById(R.id.order_detail_refund_price_relativelayout).setVisibility(View.GONE);
			}
			if(Double.compare(Double.valueOf(transOrderInfo.getTotalCalculatePrice()),Double.valueOf(transOrderInfo.getTotalSalePrice()))!=0){
				findViewById(R.id.order_detail_total_sale_price_view).setVisibility(View.VISIBLE);
				findViewById(R.id.order_detail_total_sale_price_relativelayout).setVisibility(View.VISIBLE);
			}		
			else{
				findViewById(R.id.order_detail_total_sale_price_view).setVisibility(View.GONE);
				findViewById(R.id.order_detail_total_sale_price_relativelayout).setVisibility(View.GONE);
			}
			if(transOrderInfo.getCustomerBenefitList()!=null && transOrderInfo.getCustomerBenefitList().size()>0){
				findViewById(R.id.order_detail_customer_benefit_divide_view).setVisibility(View.VISIBLE);
				findViewById(R.id.order_detail_customer_benefit_relativelayout).setVisibility(View.VISIBLE);
				findViewById(R.id.order_detail_customer_benefit_item_divide_view).setVisibility(View.VISIBLE);
				findViewById(R.id.order_detail_customer_benefit_item_relativelayout).setVisibility(View.VISIBLE);
			}
			else{
				findViewById(R.id.order_detail_customer_benefit_divide_view).setVisibility(View.GONE);
				findViewById(R.id.order_detail_customer_benefit_relativelayout).setVisibility(View.GONE);
				findViewById(R.id.order_detail_customer_benefit_item_divide_view).setVisibility(View.GONE);
				findViewById(R.id.order_detail_customer_benefit_item_relativelayout).setVisibility(View.GONE);
			}
				
			isOrderProductNameHide=false;
			orderProductUpDownIcon.setBackgroundResource(R.drawable.report_main_up_icon);
		}
		else if(!isOrderProductNameHide){
			for(int i=0;i<orderDetailProductNameTablelayout.getChildCount();i++){
				if(i!=0){
					orderDetailProductNameTablelayout.getChildAt(i).setVisibility(View.GONE);
					
				}
			}
			isOrderProductNameHide=true;
			orderProductUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
		}
	}
	private void  showOrderAppointment(){
		if(isOrderAppointmentShow){
			for(int i=0;i<orderAppointmentTablelayout.getChildCount();i++){
				if(i!=0){
					orderAppointmentTablelayout.getChildAt(i).setVisibility(View.GONE);
					orderAppointmentTablelayout.getChildAt(i).startAnimation(mHiddenAction);
				}
			}
			isOrderAppointmentShow=false;
			((ImageView)orderAppointmentTablelayout.findViewById(R.id.order_appointment_up_down_icon)).setBackgroundResource(R.drawable.report_main_down_icon);
		}
		else if(!isOrderAppointmentShow){
			for(int i=0;i<orderAppointmentTablelayout.getChildCount();i++){
				if(i!=0){
					orderAppointmentTablelayout.getChildAt(i).setVisibility(View.VISIBLE);
					orderAppointmentTablelayout.getChildAt(i).startAnimation(mShowAction);
				}
			}
			isOrderAppointmentShow=true;
			((ImageView)orderAppointmentTablelayout.findViewById(R.id.order_appointment_up_down_icon)).setBackgroundResource(R.drawable.report_main_up_icon);
		}
	}
	private void treatmentUpdateDialogDismiss() {
		if (treatmentUpdateDialog != null)
			treatmentUpdateDialog.dismiss();
	}
	// 对服务组的操作
	protected void showTreatmentGroupUpdateDialog(final TreatmentGroup treatmentGroup) {
		View treatmentGroupUpdateLayout = layoutInflater.inflate(R.xml.treatment_group_update_dialog, null);
		treatmentUpdateDialog.show();
		// 服务组更换服务顾问
		RelativeLayout treatmentGroupSelectEmployeeRelativeLayout = (RelativeLayout)treatmentGroupUpdateLayout.findViewById(R.id.treatment_group_select_employee_relativelayout);
		
		//服务组详情
		RelativeLayout treatmentGroupDetailRelativeLayout = (RelativeLayout)treatmentGroupUpdateLayout.findViewById(R.id.treatment_group_detail_relativelayout);
		//服务组点击更换服务顾问
		treatmentGroupSelectEmployeeRelativeLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				operationTreatmentGroupNo=String.valueOf(treatmentGroup.getTreatmentGroupID());
				Intent intent = new Intent(OrderDetailActivity.this,ChoosePersonActivity.class);
				intent.putExtra("personRole","Doctor");
				intent.putExtra("checkModel","Single");
				intent.putExtra("mustSelectOne",false);
				JSONArray servicePicPersonArray=new JSONArray();
				servicePicPersonArray.put(treatmentGroup.getServicePicID());
				intent.putExtra("selectPersonIDs",servicePicPersonArray.toString());
				startActivityForResult(intent,200);
				treatmentUpdateDialog.dismiss();
			}
		});
		//服务组详情点击事件
		treatmentGroupDetailRelativeLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				treatmentUpdateDialog.dismiss();
				Intent destIntent=new Intent(OrderDetailActivity.this,TreatmentGroupDetailTabActivity.class);
				destIntent.putExtra("CustomerID",transOrderInfo.getCustomerID());
				destIntent.putExtra("orderEditFlag",OrderOperationUtil.checkPersonAuthTgWrite(transOrderInfo,userinfoApplication,treatmentGroup));
				destIntent.putExtra("GroupNo",String.valueOf(treatmentGroup.getTreatmentGroupID()));
				destIntent.putExtra("OrderID",transOrderInfo.getOrderID());
				startActivity(destIntent);
			}
		});
		Window tretmentUpdateWindow = treatmentUpdateDialog.getWindow();
		tretmentUpdateWindow.setContentView(treatmentGroupUpdateLayout);
	}
	// 对单个服务的操作
	protected void showTreatmentUpdateDialog(final TreatmentGroup treatmentGroup,final  Treatment  treatment) {
		View treatmentUpdateLayout = layoutInflater.inflate(R.xml.treatment_update_dialog, null);
		treatmentUpdateDialog.show();
		//服务更换具体操作人
		RelativeLayout treatmentSelectEmployeeRelativeLayout = (RelativeLayout)treatmentUpdateLayout.findViewById(R.id.treatment_select_employee_relativelayout);
		treatmentSelectEmployeeRelativeLayout.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				operationTreatmentID=treatment.getId();
				Intent intent = new Intent(OrderDetailActivity.this,ChoosePersonActivity.class);
				intent.putExtra("personRole","Doctor");
				intent.putExtra("checkModel","Single");
				intent.putExtra("mustSelectOne",false);
				JSONArray servicePersonArray=new JSONArray();
				servicePersonArray.put(treatment.getExecutorID());
				intent.putExtra("selectPersonIDs",servicePersonArray.toString());
				startActivityForResult(intent,300);
				treatmentUpdateDialog.dismiss();
			}
		});
		// 服务详情
		RelativeLayout treatmentDetailRelativeLayout = (RelativeLayout) treatmentUpdateLayout.findViewById(R.id.treatment_detail_relativelayout);
		treatmentDetailRelativeLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent destIntent = new Intent(OrderDetailActivity.this,TreatmentDetailActivity.class);
				Bundle mBundle = new Bundle();
				mBundle.putSerializable("treatmentGroup",(Serializable)treatmentGroup);
				mBundle.putSerializable("treatment",(Serializable) treatment);
				destIntent.putExtras(mBundle);
				destIntent.putExtra("CustomerID",transOrderInfo.getCustomerID());
				destIntent.putExtra("orderEditFlag",authMyOrderWrite);
				treatmentUpdateDialogDismiss();
				startActivity(destIntent);
			}
		});
		// 服务完成
		RelativeLayout treatmentConfirmRelativeLayout = (RelativeLayout) treatmentUpdateLayout.findViewById(R.id.treatment_confirm_relativelayout);
		treatmentConfirmRelativeLayout.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Dialog dialog = new AlertDialog.Builder(
						OrderDetailActivity.this,R.style.CustomerAlertDialog)
						.setTitle(getString(R.string.delete_dialog_title))
						.setMessage(R.string.complete_treatment)
						.setPositiveButton(getString(R.string.delete_confirm),
								new DialogInterface.OnClickListener() {
									@Override
									public void onClick(DialogInterface dialog,int which) {
										dialog.dismiss();
										completedTreatment(treatment);
									}
								})
						.setNegativeButton(getString(R.string.delete_cancel),
								new DialogInterface.OnClickListener() {
									@Override
									public void onClick(DialogInterface dialog,int which) {
										dialog.dismiss();
										dialog = null;
									}
								}).create();
				dialog.show();
				dialog.setCancelable(false);
				treatmentUpdateDialog.dismiss();
			}
			
		});
		// 服务删除
		RelativeLayout treatmentDeleteRelativeLayout = (RelativeLayout) treatmentUpdateLayout.findViewById(R.id.treatment_delete_relativelayout);
		if(treatmentGroup.getTreatmentList()!=null && treatmentGroup.getTreatmentList().size()>1){
			treatmentDeleteRelativeLayout.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
						Dialog dialog = new AlertDialog.Builder(OrderDetailActivity.this,R.style.CustomerAlertDialog)
								.setTitle(getString(R.string.delete_dialog_title))
								.setMessage(R.string.delete_treatment)
								.setPositiveButton(getString(R.string.delete_confirm),new DialogInterface.OnClickListener() {
											@Override
											public void onClick(DialogInterface dialog,int which) {
												dialog.dismiss();
												deleteTreatment(treatmentGroup,treatment);
											}
										})
								.setNegativeButton(getString(R.string.delete_cancel),
										new DialogInterface.OnClickListener() {
											@Override
											public void onClick(DialogInterface dialog,int which) {
												dialog.dismiss();
												dialog = null;
											}
										}).create();
						dialog.show();
						dialog.setCancelable(false);
						treatmentUpdateDialog.dismiss();
					}
			});
		}
		//tg下只有一个Treatment时不能出现删除
		else{
			treatmentDeleteRelativeLayout.setVisibility(View.GONE);
			treatmentUpdateLayout.findViewById(R.id.treatment_delete_divide_view).setVisibility(View.GONE);
		}
		//服务指定
	    RelativeLayout treatmentDesignateRelativeLayout = (RelativeLayout)treatmentUpdateLayout.findViewById(R.id.treatment_designat_relativelayout);
		TextView       treatmentDesignateTitleText=(TextView)treatmentDesignateRelativeLayout.findViewById(R.id.treatment_designat_title);
		if(treatment.isDesignated())
				treatmentDesignateTitleText.setText("取消指定");
		treatmentDesignateRelativeLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				treatmentUpdateDialog.dismiss();
				designateTreatment(treatmentGroup,treatment);
			}
		});
		Window tretmentUpdateWindow = treatmentUpdateDialog.getWindow();
		tretmentUpdateWindow.setContentView(treatmentUpdateLayout);
	}
	//更换美丽顾问或者
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		if (resultCode == RESULT_OK) {
			//更换服务顾问
			if(requestCode==200){
				final int newServicePicID = data.getIntExtra("personId",0);
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						String methodName = "UpdateTGServicePIC";
						String endPoint = "order";
						JSONObject updateTGServicePICJsonParam=new JSONObject();
						try {
							updateTGServicePICJsonParam.put("ServicePIC",newServicePicID);
							updateTGServicePICJsonParam.put("GroupNo",operationTreatmentGroupNo);
							updateTGServicePICJsonParam.put("OrderID",transOrderInfo.getOrderID());
						} catch (JSONException e) {
							
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,updateTGServicePICJsonParam.toString(),userinfoApplication);
						if (serverRequestResult == null || serverRequestResult.equals(""))
							mHandler.sendEmptyMessage(0);
						else {
							int    code =    0;
							String message = "";
							try {
								JSONObject resultJson = new JSONObject(serverRequestResult);
								code = resultJson.getInt("Code");
								message = resultJson.getString("Message");
							} catch (JSONException e) {
								code = 0;
							}
							if (code== 1){
								Message msg = new Message();
								msg.obj = message;
								msg.what = 3;
								mHandler.sendMessage(msg);
							}
							else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
								mHandler.sendEmptyMessage(code);
							else {
								Message msg = new Message();
								msg.what = 2;
								msg.obj = message;
								mHandler.sendMessage(msg);
							}

						}
					}
				};
				requestWebServiceThread.start();
			}
			//更换具体服务操作人
			else if(requestCode==300){
				final int newServiceID = data.getIntExtra("personId",0);
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						String methodName = "UpdateTreatmentExecutorID";
						String endPoint = "order";
						JSONObject updateTGServicePICJsonParam=new JSONObject();
						try {
							updateTGServicePICJsonParam.put("TreatmentID",operationTreatmentID);
							updateTGServicePICJsonParam.put("ExecutorID",newServiceID);
							updateTGServicePICJsonParam.put("OrderID",transOrderInfo.getOrderID());
						} catch (JSONException e) {
							
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,updateTGServicePICJsonParam.toString(),userinfoApplication);
						if (serverRequestResult == null || serverRequestResult.equals(""))
							mHandler.sendEmptyMessage(0);
						else {
							int    code =    0;
							String message = "";
							try {
								JSONObject resultJson = new JSONObject(serverRequestResult);
								code = resultJson.getInt("Code");
								message = resultJson.getString("Message");
							} catch (JSONException e) {
								code = 0;
							}
							if (code== 1){
								Message msg = new Message();
								msg.obj = message;
								msg.what = 3;
								mHandler.sendMessage(msg);
							}
							else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
								mHandler.sendEmptyMessage(code);
							else {
								Message msg = new Message();
								msg.what = 2;
								msg.obj = message;
								mHandler.sendMessage(msg);
							}

						}
					}
				};
				requestWebServiceThread.start();
			
			}
			else if(requestCode==100){
				String signPic=data.getStringExtra("signPic");
				completedTreatmentGroup(currentTreatmentGroup,signPic);
			}
			//更换订单的美丽顾问
			else{
				final int newResponsiblePersonID = data.getIntExtra("personId",0);
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						String methodName = "UpdateResponsiblePerson";
						String endPoint = "order";
						JSONObject updateResponsiblePersonJsonParam=new JSONObject();
						try {
							updateResponsiblePersonJsonParam.put("OrderID",transOrderInfo.getOrderID());
							updateResponsiblePersonJsonParam.put("OrderObjectID",transOrderInfo.getOrderObejctID());
							updateResponsiblePersonJsonParam.put("ResponsiblePersonID",newResponsiblePersonID);
							updateResponsiblePersonJsonParam.put("ProductType",transOrderInfo.getProductType());
						} catch (JSONException e) {
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,updateResponsiblePersonJsonParam.toString(),userinfoApplication);
						if (serverRequestResult == null || serverRequestResult.equals(""))
							mHandler.sendEmptyMessage(0);
						else {
							int    code = 0;
							String message = "";
							try {    
								JSONObject resultJson = new JSONObject(serverRequestResult);
								code = resultJson.getInt("Code");
								message = resultJson.getString("Message");
							} catch (JSONException e) {
								code =0;
							}
							if (code == 1){
								Message msg = new Message();
								msg.obj = message;
								msg.what = 3;
								mHandler.sendMessage(msg);
							}	
							else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
								mHandler.sendEmptyMessage(code);
							else {
								Message msg = new Message();
								msg.what = 2;
								msg.obj = message;
								mHandler.sendMessage(msg);
							}
						}
					}
				};
				requestWebServiceThread.start();
			}   
		}
	}
	//验证每个单子的确认方式 如果当中有一个是电子签名确认的 则需要跳转到签字页
	private void checkConfirmed(final TreatmentGroup treatmentGroup){
		if(transOrderInfo.getIsConfirmed()==2){
			currentTreatmentGroup=treatmentGroup;
			Intent handWriteIntent=new Intent();
			handWriteIntent.setClass(this, HandwritingActivity.class);
			startActivityForResult(handWriteIntent,100);
		}
		else{
			completedTreatmentGroup(treatmentGroup,null);
		}	
	}
	//将TG进行结单
	protected void completedTreatmentGroup(final TreatmentGroup treatmentGroup,final String signImageUrl) {
		final JSONArray treatmentGroupJsonArray = new JSONArray();
		JSONObject treatmentGroupJson=new JSONObject();
		try {
			treatmentGroupJson.put("OrderType",transOrderInfo.getProductType());
			treatmentGroupJson.put("OrderID",transOrderInfo.getOrderID());
			treatmentGroupJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
			treatmentGroupJson.put("GroupNo",treatmentGroup.getTreatmentGroupID());
		} catch (JSONException e) {
		}
		treatmentGroupJsonArray.put(treatmentGroupJson);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String endPoint = "order";
				String methodName = "CompleteTreatGroup";
				JSONObject completeTreatmentGroupJson = new JSONObject();
				try {
					completeTreatmentGroupJson.put("CustomerID",transOrderInfo.getCustomerID());
					if(signImageUrl!=null && !("".equals(signImageUrl))){
						completeTreatmentGroupJson.put("SignImg",signImageUrl);
						completeTreatmentGroupJson.put("ImageFormat",".JPEG");
					}
					completeTreatmentGroupJson.put("TGDetailList",treatmentGroupJsonArray);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,completeTreatmentGroupJson.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int    code = 0;
					String message = "";
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						Message msg = new Message();
						msg.obj = message;
						msg.what = 3;
						mHandler.sendMessage(msg);
					}
					// 数据有变动或者不能进行操作
					else if (code== -2) {
						Message msg = new Message();
						msg.obj = message;
						msg.what = 4;
						mHandler.sendMessage(msg);
					}
					else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message msg = new Message();
						msg.what = 2;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}
	//将单个服务完成
	protected void completedTreatment(final Treatment treatment) {
		requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					String endPoint = "order";
					String methodName = "CompleteTreatment";
					JSONObject completeTreatmentJson = new JSONObject();
					try {
						completeTreatmentJson.put("CustomerID",transOrderInfo.getCustomerID());
						completeTreatmentJson.put("TreatmentID",treatment.getId());
					} catch (JSONException e) {
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,completeTreatmentJson.toString(),userinfoApplication);
					if (serverRequestResult == null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(0);
					else {
						int    code = 0;
						String message = "";
						try {
							JSONObject resultJson = new JSONObject(serverRequestResult);
							code = resultJson.getInt("Code");
							message = resultJson.getString("Message");
						} catch (JSONException e) {
							code = 0;
						}
						if (code== 1) {
							Message msg = new Message();
							msg.obj = message;
							msg.what = 3;
							mHandler.sendMessage(msg);
						}
						// 数据有变动或者不能进行操作
						else if (code== -2) {
							Message msg = new Message();
							msg.obj = message;
							msg.what = 4;
							mHandler.sendMessage(msg);
						}
						else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
							mHandler.sendEmptyMessage(code);
						else {
							Message msg = new Message();
							msg.what = 2;
							msg.obj = message;
							mHandler.sendMessage(msg);
						}
					}
				}
			};
			requestWebServiceThread.start();
		}
	//将TG进行撤销
	protected void deleteTreatmentGroup(final TreatmentGroup treatmentGroup) {
			final JSONArray treatmentGroupJsonArray = new JSONArray();
			JSONObject treatmentGroupJson=new JSONObject();
			try {
				treatmentGroupJson.put("OrderType",transOrderInfo.getProductType());
				treatmentGroupJson.put("OrderID",transOrderInfo.getOrderID());
				treatmentGroupJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
				treatmentGroupJson.put("GroupNo",treatmentGroup.getTreatmentGroupID());
			} catch (JSONException e) {
			}
			treatmentGroupJsonArray.put(treatmentGroupJson);
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					String endPoint ="order";
					String methodName ="CancelTreatGroup";
					JSONObject deleteTreatmentGroupJson = new JSONObject();
					try {
						deleteTreatmentGroupJson.put("TGDetailList",treatmentGroupJsonArray);
					} catch (JSONException e) {
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,deleteTreatmentGroupJson.toString(),userinfoApplication);
					if (serverRequestResult == null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(0);
					else {
						int    code = 0;
						String message = "";
						try {
							JSONObject resultJson = new JSONObject(serverRequestResult);
							code = resultJson.getInt("Code");
							message = resultJson.getString("Message");
						} catch (JSONException e) {
							code = 0;
						}
						if (code== 1) {
							Message msg = new Message();
							msg.obj = message;
							msg.what = 3;
							mHandler.sendMessage(msg);
						}
						// 数据有变动或者不能进行操作
						else if (code== -2) {
							Message msg = new Message();
							msg.obj = message;
							msg.what = 4;
							mHandler.sendMessage(msg);
						}
						else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
							mHandler.sendEmptyMessage(code);
						else {
							Message msg = new Message();
							msg.what = 2;
							msg.obj = message;
							mHandler.sendMessage(msg);
						}
					}
				}
			};
			requestWebServiceThread.start();
		}
	//指定TG
	protected void  designateTreatment(final TreatmentGroup treatmentGroup,final Treatment treatment){
		progressDialog = new ProgressDialog(OrderDetailActivity.this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		progressDialog.setCancelable(false);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName ="UpdateTMDesignated";
				String endPoint ="order";
				JSONObject updateTreatmentDesignatedJson = new JSONObject();
				try {
					updateTreatmentDesignatedJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
					if(treatment.isDesignated())
						updateTreatmentDesignatedJson.put("IsDesignated",false);
					else
						updateTreatmentDesignatedJson.put("IsDesignated",true);
					updateTreatmentDesignatedJson.put("GroupNo",treatmentGroup.getTreatmentGroupID());
					updateTreatmentDesignatedJson.put("TreatmentID",treatment.getId());
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,updateTreatmentDesignatedJson.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int   code =  0;
					String message = "";
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code =0;
					}
					if (code== 1){
						Message msg = new Message();
						msg.obj = message;
						msg.what = 3;
						mHandler.sendMessage(msg);
					}
					else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message msg = new Message();
						msg.what = 2;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}

				}
			}
		};
		requestWebServiceThread.start();
	}
	//删除单个服务
	protected void deleteTreatment(final TreatmentGroup treatmentGroup,final  Treatment treatment) {
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String endPoint ="order";
				String methodName ="CancelTreatment";
				JSONObject deleteTreatmentJson = new JSONObject();
				try {
					deleteTreatmentJson.put("TreatmentID",treatment.getId());
					deleteTreatmentJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
					deleteTreatmentJson.put("GroupNo",treatmentGroup.getTreatmentGroupID());
				} catch (JSONException e) {
					e.printStackTrace();
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,deleteTreatmentJson.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int    code = 0;
					String message = "";
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						Message msg = new Message();
						msg.obj = message;
						msg.what = 3;
						mHandler.sendMessage(msg);
					}
					else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					// 数据有变动或者不能进行操作
					else if (code== -2) {
						Message msg = new Message();
						msg.obj = message;
						msg.what = 4;
						mHandler.sendMessage(msg);
					} else {
						Message msg = new Message();
						msg.what = 2;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}
	// 完成订单
	protected void completeOrder() {
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String endPoint = "Order";
				String methodName = "CompleteOrder";
				JSONObject completeOrderJson = new JSONObject();
				try {
					completeOrderJson.put("OrderID",transOrderInfo.getOrderID());
					completeOrderJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
					completeOrderJson.put("ProductType",transOrderInfo.getProductType());
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,completeOrderJson.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int   code = 0;
					String message = "";
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code == 1){
						Message msg = new Message();
						msg.obj = message;
						msg.what = 3;
						mHandler.sendMessage(msg);
					}
					else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message msg = new Message();
						msg.what = 2;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}

				}
			}
		};
		requestWebServiceThread.start();
	}
	//获取已完成的TG信息
	protected void getCompleteTG(){
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName ="GetTreatGroupByOrderObjectID";
				String endPoint = "order";
				JSONObject completeTgParamJson = new JSONObject();
				try {
					completeTgParamJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
					completeTgParamJson.put("ProductType",transOrderInfo.getProductType());
					completeTgParamJson.put("Status",-1);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,completeTgParamJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e) {
				}
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int    code = 0;
					String message = "";
					try {
						code =resultJson.getInt("Code");
						message =resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					JSONArray completeTGJsonArray = null;
					try {
						completeTGJsonArray = resultJson.getJSONArray("Data");
					} catch (JSONException e) {

					}
					List<TreatmentGroup> treatmentGroupList=null;
					if (code== 1 && completeTGJsonArray != null) {
						try {
								treatmentGroupList= new ArrayList<TreatmentGroup>();
									for (int g = 0; g < completeTGJsonArray.length(); g++) {
												TreatmentGroup treatmentGroup = new TreatmentGroup();
												JSONObject treatmentGroupDeatilJson = completeTGJsonArray.getJSONObject(g);
												treatmentGroup.setTreatmentGroupID(treatmentGroupDeatilJson.getLong("GroupNo"));
												treatmentGroup.setServicePicID(treatmentGroupDeatilJson.getInt("ServicePicID"));
												treatmentGroup.setStartTime(treatmentGroupDeatilJson.getString("StartTime"));
												treatmentGroup.setServicePicName(treatmentGroupDeatilJson.getString("ServicePicName"));
												treatmentGroup.setStatus(treatmentGroupDeatilJson.getInt("Status"));
												if(transOrderInfo.getProductType()==Constant.COMMODITY_TYPE){
													treatmentGroup.setCommodityQuantity(treatmentGroupDeatilJson.getInt("Quantity"));
													if(treatmentGroupDeatilJson.has("ThumbnailURL") && !treatmentGroupDeatilJson.isNull("ThumbnailURL"))
														treatmentGroup.setSignImageUrl(treatmentGroupDeatilJson.getString("ThumbnailURL"));
												}
												if (treatmentGroupDeatilJson.has("TreatmentList") && !treatmentGroupDeatilJson.isNull("TreatmentList")) {
													List<Treatment> treatmentList = new ArrayList<Treatment>();
													JSONArray courseTreatmentJsonArray = treatmentGroupDeatilJson.getJSONArray("TreatmentList");
													for (int j = 0; j < courseTreatmentJsonArray.length(); j++) {
														Treatment treatment = new Treatment();
														JSONObject treatmentDetailJson = courseTreatmentJsonArray.getJSONObject(j);
														String subServiceName = "";
														if (treatmentDetailJson.has("SubServiceName"))
															subServiceName = treatmentDetailJson.getString("SubServiceName");
														if(subServiceName.equals(""))
															treatment.setSubServiceName("服务操作");
														else
															treatment.setSubServiceName(subServiceName);
														int executorID = 0;
														if (treatmentDetailJson.has("ExecutorID"))
															executorID = treatmentDetailJson.getInt("ExecutorID");
														treatment.setExecutorID(executorID);
														String executorName = "";
														if (treatmentDetailJson.has("ExecutorName"))
															executorName = treatmentDetailJson.getString("ExecutorName");
														treatment.setExecutorName(executorName);
														int treatmentID = 0;
														if (treatmentDetailJson.has("TreatmentID"))
															treatmentID = treatmentDetailJson.getInt("TreatmentID");
														treatment.setId(treatmentID);
														int scheduleID = 0;
														if (treatmentDetailJson.has("ScheduleID"))
															scheduleID = treatmentDetailJson.getInt("ScheduleID");
														treatment.setScheduleID(scheduleID);
														int isCompleted = 0;
														if (treatmentDetailJson.has("Status"))
															isCompleted = treatmentDetailJson.getInt("Status");
														treatment.setIsCompleted(isCompleted);
														String remark = "";
														if (treatmentDetailJson.has("Remark"))
															remark = treatmentDetailJson.getString("Remark");
														treatment.setRemark(remark);
														if(treatmentDetailJson.has("TreatmentCode"))
															treatment.setTreatmentCode(treatmentDetailJson.getString("TreatmentCode"));
														treatment.setDesignated(treatmentDetailJson.getBoolean("IsDesignated"));
														treatmentList.add(treatment);
													}
													treatmentGroup.setTreatmentList(treatmentList);
												}
												treatmentGroupList.add(treatmentGroup);
											}
						} catch (JSONException e) {
							e.printStackTrace();
						}
						Message msg = new Message();
						msg.obj =treatmentGroupList;
						msg.what = 8;
						mHandler.sendMessage(msg);
					}
					else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message msg = new Message();
						msg.what = 2;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}
	//取消或者终止订单
	protected void deleteOrder(){
	  if(deleteOrderType==1 || deleteOrderType==2){
		  String deleteOrderTips="";
			if(deleteOrderType==1)
				deleteOrderTips="确认取消该订单？";
			else if(deleteOrderType==2)
				deleteOrderTips="确认终止该订单？";
			Dialog dialog = new AlertDialog.Builder(this,R.style.CustomerAlertDialog)
					.setTitle(getString(R.string.delete_dialog_title))
					.setMessage(deleteOrderTips)
					.setPositiveButton(getString(R.string.delete_confirm),new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									dialog.dismiss();
									progressDialog = new ProgressDialog(OrderDetailActivity.this,R.style.CustomerProgressDialog);
									progressDialog.setMessage(getString(R.string.please_wait));
									progressDialog.show();
									progressDialog.setCancelable(false);
									requestWebServiceThread = new Thread() {
										@Override
										public void run() {
											String methodName = "DeleteOrder";
											String endPoint="Order";
											JSONObject deleteOrderJson = new JSONObject();
											try {
												deleteOrderJson.put("OrderID",transOrderInfo.getOrderID());
												deleteOrderJson.put("OrderObjectID",transOrderInfo.getOrderObejctID());
												deleteOrderJson.put("ProductType",transOrderInfo.getProductType());
												deleteOrderJson.put("DeleteType",deleteOrderType);
											} catch (JSONException e) {
											}
											String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,deleteOrderJson.toString(),userinfoApplication);
											if (serverRequestResult == null
													|| serverRequestResult.equals(""))
												mHandler.sendEmptyMessage(0);
											else {
												int code = 0;
												String message = "";
												try {
													JSONObject resultJson = new JSONObject(serverRequestResult);
													code = resultJson.getInt("Code");
													message = resultJson.getString("Message");
												} catch (JSONException e) {
													code = 0;
												}
												if (code== 1){
													mHandler.sendEmptyMessage(9);
												}
												else if (code== Constant.APP_VERSION_ERROR || code== Constant.LOGIN_ERROR)
													mHandler.sendEmptyMessage(code);
												else {
													Message msg = new Message();
													msg.what = 2;
													msg.obj = message;
													mHandler.sendMessage(msg);
												}
											}
										}
									};
									requestWebServiceThread.start();
								}
							})
					.setNegativeButton(
							getString(R.string.delete_cancel),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(
										DialogInterface dialog,
										int which) {
									dialog.dismiss();
									dialog = null;
								}
							}).create();
			dialog.show();
			dialog.setCancelable(false);
	  }
	  else{
		  //直接点击退款按钮
		  Dialog dialog = new AlertDialog.Builder(OrderDetailActivity.this,R.style.CustomerAlertDialog)
			.setTitle(getString(R.string.delete_dialog_title))
			.setMessage(getString(R.string.refund_order_tips))
			.setPositiveButton(getString(R.string.refund_order_confirm),new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog,int which) {
							dialog.dismiss();
							dialog=null;
							Intent destIntent=new Intent();
							destIntent.setClass(OrderDetailActivity.this,OrderRefundActivity.class);
							destIntent.putExtra("orderID",transOrderInfo.getOrderID());
							destIntent.putExtra("customerID",transOrderInfo.getCustomerID());
							destIntent.putExtra("productType",transOrderInfo.getProductType());
							startActivity(destIntent);
						}
					})
			.setNegativeButton(getString(R.string.delete_cancel),
					new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog,int which) {
							dialog.dismiss();
							dialog = null;
							initView();
						}
					}).create();
			dialog.show();
			dialog.setCancelable(false);
	  }
	}
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
		if (requestWebServiceThread != null) {
			requestWebServiceThread.interrupt();
			requestWebServiceThread = null;
		}
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		super.onBackPressed();
		if (!fromOrderList) {
			Intent destIntent = new Intent(this, OrderListActivity.class);
			destIntent.putExtra("USER_ROLE", userRole);
			startActivity(destIntent);
		}
		this.finish();
	}

	protected void onRestart() {
		super.onRestart();
		initView();
	};
}