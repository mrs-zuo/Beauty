package com.GlamourPromise.Beauty.Business;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.TypedValue;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.Opportunity;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Timer;

public class OpportunityDetailActivity extends BaseActivity implements
		OnClickListener {
	private OpportunityDetailActivityHandler mHandler = new OpportunityDetailActivityHandler(this);
	private TextView opportunityDetailCreateTimeText;
	private TextView opportunityDetailProductNameText;
	private TextView opportunityDetailQuantityText;
	private TextView opportunityDetailTotalPriceText;
	private LinearLayout opportunityLinearlayout;
	private ImageButton dispatchOrderBtn;
	private ImageButton cancelOpportunityBtn;
	private ImageButton onlyCancelOpportunityBtn;
	private int progress = 0;
	private Button progressButton;
	private String[] stepContentArray;
	private Opportunity opportunity;
	private Thread requestWebServiceThread;
	private UserInfoApplication userinfoApplication;
	private View opportunityDetailTotalSalePriceDivideView;
	private RelativeLayout opportunityDetailTotalSalePriceRelativeLayout;
	private TextView opportunityDetailTotalSalePriceText;
	private Timer    dialogTimer;
	private PackageUpdateUtil packageUpdateUtil;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_opportunity_detail);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class OpportunityDetailActivityHandler extends Handler {
		private final OpportunityDetailActivity opportunityDetailActivity;

		private OpportunityDetailActivityHandler(OpportunityDetailActivity activity) {
			WeakReference<OpportunityDetailActivity> weakReference = new WeakReference<OpportunityDetailActivity>(activity);
			opportunityDetailActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 1) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(opportunityDetailActivity, "提示信息", "取消需求成功！");
				alertDialog.show();
				Intent destIntent = new Intent(opportunityDetailActivity, OpportunityListActivity.class);
				opportunityDetailActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, opportunityDetailActivity.dialogTimer, opportunityDetailActivity, destIntent);
				opportunityDetailActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == 0) {
				DialogUtil.createMakeSureDialog(opportunityDetailActivity,
						"提示信息", "操作失败，请重试");
			} else if (msg.what == 2) {
				// 如果当前账号没有编辑订单权限时   或者需求无效时 只能取消需求
				if (opportunityDetailActivity.userinfoApplication.getAccountInfo().getAuthMyOrderWrite() == 0
						|| opportunityDetailActivity.userinfoApplication.getAccountInfo().getBranchId() != opportunityDetailActivity.opportunity.getBranchID() || !opportunityDetailActivity.opportunity.isAvailable()) {
					opportunityDetailActivity.cancelOpportunityBtn.setVisibility(View.GONE);
					opportunityDetailActivity.dispatchOrderBtn.setVisibility(View.GONE);
					opportunityDetailActivity.onlyCancelOpportunityBtn.setVisibility(View.VISIBLE);
				} else {
					opportunityDetailActivity.dispatchOrderBtn.setVisibility(View.VISIBLE);
					opportunityDetailActivity.cancelOpportunityBtn.setVisibility(View.VISIBLE);
					opportunityDetailActivity.onlyCancelOpportunityBtn.setVisibility(View.GONE);
				}
				opportunityDetailActivity.opportunityDetailCreateTimeText.setText(opportunityDetailActivity.opportunity.getCreatTime());
				opportunityDetailActivity.opportunityDetailProductNameText.setText(opportunityDetailActivity.opportunity.getProductName());
				((TextView) opportunityDetailActivity.findViewById(R.id.opportunity_detail_responsible_person_text)).setText(opportunityDetailActivity.opportunity.getResponsiblePersonName());
				((TextView) opportunityDetailActivity.findViewById(R.id.opportunity_detail_customer_name_text)).setText(opportunityDetailActivity.opportunity.getCustomerName());
				opportunityDetailActivity.opportunityDetailQuantityText.setText(String.valueOf(opportunityDetailActivity.opportunity.getQuantity()));
				String formatPrice = NumberFormatUtil.currencyFormat(opportunityDetailActivity.opportunity.getTotalPrice());
				opportunityDetailActivity.opportunityDetailTotalPriceText.setText(formatPrice);
				if (Float.valueOf(opportunityDetailActivity.opportunity.getTotalSalePrice()) == 0
						|| opportunityDetailActivity.opportunity.getTotalSalePrice().equals(
						opportunityDetailActivity.opportunity.getTotalPrice())) {
					opportunityDetailActivity.opportunityDetailTotalSalePriceDivideView
							.setVisibility(View.GONE);
					opportunityDetailActivity.opportunityDetailTotalSalePriceRelativeLayout
							.setVisibility(View.GONE);
				} else
					opportunityDetailActivity.opportunityDetailTotalSalePriceText
							.setText(NumberFormatUtil
									.currencyFormat(opportunityDetailActivity.opportunity
											.getTotalSalePrice()));
				String stepContent = opportunityDetailActivity.opportunity.getStepContent();
				opportunityDetailActivity.stepContentArray = stepContent.split("\\|");
				opportunityDetailActivity.progress = opportunityDetailActivity.opportunity.getProgress();
				opportunityDetailActivity.opportunityLinearlayout.removeAllViews();
				for (int i = 0; i < opportunityDetailActivity.stepContentArray.length; i++) {
					opportunityDetailActivity.progressButton = new Button(opportunityDetailActivity);
					opportunityDetailActivity.progressButton.setId(i);
					if (i == 0) {
						opportunityDetailActivity.progressButton
								.setBackgroundResource(R.drawable.opportunity_progress_head_blue);
					} else if (i == (opportunityDetailActivity.stepContentArray.length - 1))
						if ((opportunityDetailActivity.progress - 1) == i)
							opportunityDetailActivity.progressButton
									.setBackgroundResource(R.drawable.opportunity_progress_foot_blue);
						else
							opportunityDetailActivity.progressButton
									.setBackgroundResource(R.drawable.opportunity_progress_foot_gray);
					else if ((opportunityDetailActivity.progress - 1) >= i)
						opportunityDetailActivity.progressButton
								.setBackgroundResource(R.drawable.opportunity_progress_body_blue);
					else
						opportunityDetailActivity.progressButton
								.setBackgroundResource(R.drawable.opportunity_progress_body_gray);
					int codeTextSize = opportunityDetailActivity.userinfoApplication.getCodeTextSize();
					opportunityDetailActivity.progressButton.setTextColor(opportunityDetailActivity.getResources().getColor(
							R.color.white));
					opportunityDetailActivity.progressButton.setSingleLine(true);
					opportunityDetailActivity.progressButton.setMaxWidth(60);
					opportunityDetailActivity.progressButton.setTextSize(TypedValue.COMPLEX_UNIT_SP,
							codeTextSize);
					int screenWidth = opportunityDetailActivity.userinfoApplication.getScreenWidth();
					int screenHeight = opportunityDetailActivity.userinfoApplication.getScreenHeight();
					if (screenWidth == 480 && screenHeight == 800)
						opportunityDetailActivity.progressButton.setPadding(80, 0, 10, 5);
					else if (screenWidth == 540)
						opportunityDetailActivity.progressButton.setPadding(85, 0, 10, 5);
					else if (screenWidth == 720)
						opportunityDetailActivity.progressButton.setPadding(100, 0, 10, 5);
					else if (screenWidth == 1080)
						opportunityDetailActivity.progressButton.setPadding(150, 0, 10, 5);
					else
						opportunityDetailActivity.progressButton.setPadding(100, 0, 10, 5);
					opportunityDetailActivity.progressButton.setText(opportunityDetailActivity.stepContentArray[i]);
					opportunityDetailActivity.progressButton
							.setOnClickListener(opportunityDetailActivity);
					opportunityDetailActivity.opportunityLinearlayout.addView(opportunityDetailActivity.progressButton);
				}
			} else if (msg.what == 3)
				DialogUtil.createShortDialog(opportunityDetailActivity,
						"您的网络貌似不给力，请重试");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(opportunityDetailActivity, opportunityDetailActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(opportunityDetailActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + opportunityDetailActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(opportunityDetailActivity);
				opportunityDetailActivity.packageUpdateUtil = new PackageUpdateUtil(opportunityDetailActivity, opportunityDetailActivity.mHandler, fileCache, downloadFileUrl, false, opportunityDetailActivity.userinfoApplication);
				opportunityDetailActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				opportunityDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = opportunityDetailActivity.getFileStreamPath(filename);
				file.getName();
				opportunityDetailActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (opportunityDetailActivity.requestWebServiceThread != null) {
				opportunityDetailActivity.requestWebServiceThread.interrupt();
				opportunityDetailActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		opportunityDetailCreateTimeText = (TextView) findViewById(R.id.opportunity_detail_create_time);
		opportunityDetailProductNameText = (TextView) findViewById(R.id.opportunity_detail_product_name);
		opportunityDetailQuantityText = (TextView) findViewById(R.id.opportunity_detail_quantity);
		opportunityDetailTotalPriceText = (TextView) findViewById(R.id.opportunity_detail_total_price);
		opportunityLinearlayout = (LinearLayout) findViewById(R.id.opportunity_progress);
		dispatchOrderBtn = (ImageButton) findViewById(R.id.dispatch_order_btn);
		cancelOpportunityBtn = (ImageButton) findViewById(R.id.cancel_opportunity_btn);
		onlyCancelOpportunityBtn = (ImageButton) findViewById(R.id.only_cancel_opportunity_btn);
		dispatchOrderBtn.setOnClickListener(this);
		cancelOpportunityBtn.setOnClickListener(this);
		onlyCancelOpportunityBtn.setOnClickListener(this);
		opportunity = new Opportunity();
		opportunityDetailTotalSalePriceDivideView = findViewById(R.id.opportunity_detail_total_sale_price_view);
		opportunityDetailTotalSalePriceRelativeLayout = (RelativeLayout) findViewById(R.id.opportunity_detail_total_sale_price_relativelayout);
		opportunityDetailTotalSalePriceText = (TextView) findViewById(R.id.opportunity_detail_total_sale_price);
		((TextView) findViewById(R.id.opportunity_detail_total_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
		((TextView) findViewById(R.id.opportunity_detail_total_sale_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
		Intent intent = getIntent();
		opportunity=(Opportunity) intent.getSerializableExtra("opportunity");
		requestWebService();
	}

	protected void requestWebService() {
		final int opportunityID = getIntent().getIntExtra("opportunityID", 0);
		final int productType = getIntent().getIntExtra("productType", 0);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "getOpportunityDetail";
				String endPoint = "opportunity";
				JSONObject opportunityDetailJson = new JSONObject();
				try {
					opportunityDetailJson.put("OpportunityID", opportunityID);
					opportunityDetailJson.put("ProductType", productType);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,opportunityDetailJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e2) {
				}
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(3);
				else {
					int    code =    0;
					String message = "";
					try {
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						code =0;
					}
					if (code== 1) {
						JSONObject opportunityDetail = null;
						try {
							opportunityDetail = resultJson.getJSONObject("Data");
						} catch (JSONException e) {
						}
						if (opportunityDetail != null) {
							int opportunityID = 0;
							int productID = 0;
							int productType = 0;
							String productName = "";
							int quantity = 0;
							String totalPrice = "0";
							String totalSalePrice = "0";
							String createTime = "";
							int progress = 0;
							String stepContent = "";
							String unitPrice = "";
							String promotionPrice = "";
							int marketingPolicy = 0;
							int customerID = 0;
							String customerName = "";
							double disCount = 0;
							long  productCode = 0;
							int responsiblePersonID = 0;
							String expirationDate = "";
							int branchID = 0;
							try {
								if (opportunityDetail.has("OpportunityID"))
									opportunityID = opportunityDetail.getInt("OpportunityID");
								if (opportunityDetail.has("ProductID"))
									productID = opportunityDetail.getInt("ProductID");
								if (opportunityDetail.has("ProductType"))
									productType = opportunityDetail.getInt("ProductType");
								if (opportunityDetail.has("ProductName"))
									productName = opportunityDetail.getString("ProductName");
								if (opportunityDetail.has("Quantity"))
									quantity = opportunityDetail.getInt("Quantity");
								// 该需求原来价格
								if (opportunityDetail.has("TotalOrigPrice"))
									totalPrice = opportunityDetail.getString("TotalOrigPrice");
								// 需求最终销售价格
								if (opportunityDetail.has("TotalSalePrice"))
									totalSalePrice = opportunityDetail.getString("TotalSalePrice");
								if (opportunityDetail.has("CreateTime"))
									createTime = opportunityDetail.getString("CreateTime");
								if (opportunityDetail.has("Progress"))
									progress = opportunityDetail.getInt("Progress");
								if (opportunityDetail.has("StepContent"))
									stepContent = opportunityDetail.getString("StepContent");
								if (opportunityDetail.has("UnitPrice"))
									unitPrice = opportunityDetail.getString("UnitPrice");
								if (opportunityDetail.has("PromotionPrice"))
									promotionPrice = opportunityDetail.getString("PromotionPrice");
								if (opportunityDetail.has("MarketingPolicy"))
									marketingPolicy = opportunityDetail.getInt("MarketingPolicy");
								if (opportunityDetail.has("CustomerID"))
									customerID = opportunityDetail.getInt("CustomerID");
								if (opportunityDetail.has("CustomerName"))
									customerName = opportunityDetail.getString("CustomerName");
								if (opportunityDetail.has("Discount"))
									disCount = opportunityDetail.getDouble("Discount");
								if (opportunityDetail.has("ProductCode"))
									productCode = opportunityDetail.getLong("ProductCode");
								if (opportunityDetail.has("ResponsiblePersonID"))
									responsiblePersonID = opportunityDetail.getInt("ResponsiblePersonID");
								if (opportunityDetail.has("ExpirationTime"))
									expirationDate = opportunityDetail.getString("ExpirationTime");
								if (opportunityDetail.has("BranchID"))
									branchID = opportunityDetail.getInt("BranchID");
							} catch (JSONException e) {
							}
							opportunity.setOpportunityID(opportunityID);
							opportunity.setProductType(productType);
							opportunity.setProductID(productID);
							opportunity.setProductName(productName);
							opportunity.setCustomerID(customerID);
							opportunity.setQuantity(quantity);
							opportunity.setTotalPrice(totalPrice);
							opportunity.setTotalSalePrice(totalSalePrice);
							opportunity.setCreatTime(createTime);
							opportunity.setProgress(progress);
							opportunity.setStepContent(stepContent);
							opportunity.setUnitPrice(unitPrice);
							opportunity.setPromotionPrice(promotionPrice);
							opportunity.setMarketingPolicy(marketingPolicy);
							opportunity.setCustomerID(customerID);
							opportunity.setDiscount(disCount);
							opportunity.setCustomerName(customerName);
							opportunity.setProductCode(productCode);
							opportunity.setResponsiblePersonID(responsiblePersonID);
							opportunity.setExpirationDate(expirationDate);
							opportunity.setBranchID(branchID);
						}

						mHandler.sendEmptyMessage(2);
					}
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						mHandler.sendEmptyMessage(3);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}

	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		requestWebService();
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if (view.getId() == R.id.dispatch_order_btn) {
			Intent destIntent = new Intent(this, PrepareOrderActivity.class);
			ArrayList<OrderProduct> orderProductList = new ArrayList<OrderProduct>();
			OrderProduct orderProduct = new OrderProduct();
			orderProduct.setProductCode(opportunity.getProductCode());
			orderProduct.setProductID(opportunity.getProductID());
			orderProduct.setProductName(opportunity.getProductName());
			orderProduct.setProductType(opportunity.getProductType());
			orderProduct.setQuantity(opportunity.getQuantity());
			orderProduct.setCustomerID(opportunity.getCustomerID());
			orderProduct.setOpportunityID(opportunity.getOpportunityID());
			orderProduct.setTotalSalePrice(opportunity.getTotalSalePrice());
			orderProduct.setTotalPrice(opportunity.getTotalPrice());
			orderProduct.setUnitPrice(String.valueOf(Double.valueOf(opportunity.getTotalPrice()) / orderProduct.getQuantity()));
			orderProduct.setResponsiblePersonID(opportunity.getResponsiblePersonID());
			orderProduct.setResponsiblePersonName(opportunity.getResponsiblePersonName());
			orderProduct.setSalesID(0);
			orderProduct.setSalesName("");
			orderProduct.setPast(false);//是否老订单转入
			orderProduct.setCustomerName(opportunity.getCustomerName());
			//如果是服务订单 传递服务有效期
			if(opportunity.getProductType()==Constant.SERVICE_TYPE)
				orderProduct.setServiceOrderExpirationDate(opportunity.getExpirationDate());
			orderProductList.add(orderProduct);
			Bundle bundle = new Bundle();
			bundle.putSerializable("ORDER_LIST", orderProductList);
			destIntent.putExtra("FROM_SOURCE", "OPPORTUNITY");
			destIntent.putExtras(bundle);
			startActivity(destIntent);
		} else if (view.getId() == R.id.cancel_opportunity_btn || view.getId()==R.id.only_cancel_opportunity_btn) {
			Dialog dialog = new AlertDialog.Builder(this,R.style.CustomerAlertDialog)
					.setTitle(getString(R.string.delete_dialog_title))
					.setMessage(R.string.cancel_opportunity)
					.setPositiveButton(getString(R.string.delete_confirm),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									dialog.dismiss();
									// 取消需求
									requestWebServiceThread = new Thread() {
										@Override
										public void run() {
											// TODO Auto-generated method stub
											String methodName = "deleteOpportunity";
											String endPoint = "Opportunity";
											JSONObject delOpportunityJson = new JSONObject();
											try {
												delOpportunityJson.put("OpportunityID",opportunity.getOpportunityID());
											} catch (JSONException e) {
												
											}
											String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,delOpportunityJson.toString(),userinfoApplication);
											JSONObject resultJson = null;
											try {
												resultJson = new JSONObject(
														serverRequestResult);
											} catch (JSONException e1) {
											}
											if (serverRequestResult == null
													|| serverRequestResult
															.equals(""))
												mHandler.sendEmptyMessage(3);
											else {
												int    code = 0;
												String message = "";
												try {
													code =    resultJson.getInt("Code");
													message = resultJson.getString("Message");
												} catch (JSONException e) {
													code = 0;
												}
												if (code== 1) {
													mHandler.sendEmptyMessage(1);
												}
												else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
													mHandler.sendEmptyMessage(code);
												else {
													mHandler.sendEmptyMessage(0);
												}
											}
										}
									};
									requestWebServiceThread.start();
								}
							})
					.setNegativeButton(getString(R.string.delete_cancel),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub
									dialog.dismiss();
									dialog = null;
								}
							}).create();
			dialog.show();
			dialog.setCancelable(false);

		} else
		// 销售进度的按钮点击
		{
			int id = view.getId();
			if (id == 0) {
				Button button = (Button) findViewById(id + 1);
				button.setBackgroundResource(R.drawable.opportunity_progress_body_gray);
				view.setBackgroundResource(R.drawable.opportunity_progress_head_blue);
			} else if (id < (stepContentArray.length - 1)) {
				for (int i = 1; i <= id; i++) {
					Button button = (Button) findViewById(i);
					button.setBackgroundResource(R.drawable.opportunity_progress_body_blue);
				}
				for (int j = stepContentArray.length - 1; j > id; j--) {
					Button button = (Button) findViewById(j);
					if (j == stepContentArray.length - 1)
						button.setBackgroundResource(R.drawable.opportunity_progress_foot_gray);
					else
						button.setBackgroundResource(R.drawable.opportunity_progress_body_gray);
				}
			} else if (id == (stepContentArray.length - 1)) {
				for (int i = 1; i < id; i++) {
					Button button = (Button) findViewById(i);
					button.setBackgroundResource(R.drawable.opportunity_progress_body_blue);
				}
				view.setBackgroundResource(R.drawable.opportunity_progress_foot_blue);
			}
			Intent destIntent = new Intent(this,EditOpportunityProgressActivity.class);
			Bundle bundle = new Bundle();
			bundle.putSerializable("opportunity",opportunity);
			destIntent.putExtra("progressID", id);
			destIntent.putExtra("progressName", ((Button) view).getText());
			destIntent.putExtra("maxProgress", stepContentArray.length);
			destIntent.putExtras(bundle);
			startActivity(destIntent);
		}
	}
}
