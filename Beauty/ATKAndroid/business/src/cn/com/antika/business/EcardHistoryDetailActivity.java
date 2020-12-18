package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.BalanceCard;
import cn.com.antika.bean.BenefitPerson;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardActionMode;
import cn.com.antika.bean.EcardHistoryDetail;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.MathUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 *	账户交易详情
 * */
@SuppressLint("ResourceType")
public class EcardHistoryDetailActivity extends BaseActivity {
	private EcardHistoryDetailActivityHandler mHandler = new EcardHistoryDetailActivityHandler(this);
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private LinearLayout ecardHistoryDetailOrderListLinearlayout,ecardHistoryDetailActionModeListLinearlayout;
	private LayoutInflater layoutInflater;
	private UserInfoApplication userinfoApplication;
	private PackageUpdateUtil packageUpdateUtil;
	private int  balanceID,cardType,changeType;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_ecard_history_detail);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		initView();
	}

	private static class EcardHistoryDetailActivityHandler extends Handler {
		private final EcardHistoryDetailActivity ecardHistoryDetailActivity;

		private EcardHistoryDetailActivityHandler(EcardHistoryDetailActivity activity) {
			WeakReference<EcardHistoryDetailActivity> weakReference = new WeakReference<EcardHistoryDetailActivity>(activity);
			ecardHistoryDetailActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (ecardHistoryDetailActivity.progressDialog != null) {
				ecardHistoryDetailActivity.progressDialog.dismiss();
				ecardHistoryDetailActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				EcardHistoryDetail ecardHistoryDetail = (EcardHistoryDetail) msg.obj;
				String currency = ecardHistoryDetailActivity.userinfoApplication.getAccountInfo().getCurrency();
				TableLayout ecardHistoryDetailTablelayout = (TableLayout) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_tablelayout);
				ecardHistoryDetailActivity.layoutInflater = LayoutInflater.from(ecardHistoryDetailActivity);
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_number_text)).setText(ecardHistoryDetail.getEcardHistoryDetailNo());
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_date_text)).setText(ecardHistoryDetail.getEcardHistoryDetailCreateTime());
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_branch_name_text)).setText(ecardHistoryDetail.getEcardHistoryDetailBranchName());
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_action_mode_text)).setText(ecardHistoryDetail.getEcardHistoryDetailActionModeName());
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_operator_text)).setText(ecardHistoryDetail.getEcardHistoryDetailOperator());
				List<BenefitPerson> profitList = ecardHistoryDetail.getEcardHistoryDetailProfitList();
				boolean isComissionCalc = ecardHistoryDetailActivity.userinfoApplication.getAccountInfo().isComissionCalc();
				if (profitList == null || profitList.size() == 0)
					((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_benefit_person_text)).setText("无");
				else {
					ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_remark_title_divide_view).setVisibility(View.GONE);
					for (int j = 0; j < profitList.size(); j++) {
						BenefitPerson bp = profitList.get(j);
						View benefitPersonItemView = ecardHistoryDetailActivity.layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
						if (j != 0) {
							benefitPersonItemView.findViewById(R.id.benefit_person_before_divide_view).setVisibility(View.GONE);
						}
						if (j == profitList.size() - 1) {
							benefitPersonItemView.findViewById(R.id.benefit_person_after_divide_view).setVisibility(View.GONE);
						}
						TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
						benefitPersonNameText.setText(bp.getAccountName());
						TextView benefitPersonPercentText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
						if (!isComissionCalc) {
							benefitPersonPercentText.setVisibility(View.GONE);
							benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark).setVisibility(View.GONE);
						} else
							benefitPersonPercentText.setText(bp.getProfitPct());
						ecardHistoryDetailTablelayout.addView(benefitPersonItemView, ecardHistoryDetailTablelayout.getChildCount() - 3);
					}
				}
				String ecardHistoryDetailRemark = ecardHistoryDetail.getEcardHistoryDetailRemark();
				if (ecardHistoryDetailRemark == null || ("").equals(ecardHistoryDetailRemark)) {
					ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_remark_title_divide_view).setVisibility(View.GONE);
					ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_remark_title_relativelayout).setVisibility(View.GONE);
					ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_remark_divide_view).setVisibility(View.GONE);
					((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_remark_text)).setVisibility(View.GONE);
				} else {
					((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_remark_text)).setText(ecardHistoryDetailRemark);
				}
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_amount_title_text)).setText(ecardHistoryDetail.getEcardHistoryDetailActionModeName() + "总额");
				((TextView) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_amount_text)).setText(currency + NumberFormatUtil.currencyFormat(ecardHistoryDetail.getEcardHistoryDetailAmount()));
				TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
				lp.topMargin = 20;
				lp.leftMargin = 10;
				lp.rightMargin = 10;
				ecardHistoryDetailActivity.ecardHistoryDetailActionModeListLinearlayout = (LinearLayout) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_action_mode_list_linearlayout);
				List<EcardActionMode> ecardActionModeList = ecardHistoryDetail.getEcardActionModeList();
				if (ecardActionModeList != null && ecardActionModeList.size() > 0) {
					for (int i = 0; i < ecardActionModeList.size(); i++) {
						View ecardActionModeView = ecardHistoryDetailActivity.layoutInflater.inflate(R.xml.ecard_history_detail_action_mode_layout, null);
						LinearLayout ecardActionModeLinearlayout = (LinearLayout) ecardActionModeView.findViewById(R.id.action_mode_linearlayout);
						TextView actionModeNameText = (TextView) ecardActionModeView.findViewById(R.id.action_mode_name);
						actionModeNameText.setText(ecardActionModeList.get(i).getEcardActionModeName());
						List<BalanceCard> balanceCardList = ecardActionModeList.get(i).getBalanceCardList();
						if (balanceCardList != null && balanceCardList.size() > 0) {
							for (int j = 0; j < balanceCardList.size(); j++) {
								BalanceCard bc = balanceCardList.get(j);
								View actionModeECardView = ecardHistoryDetailActivity.layoutInflater.inflate(R.xml.ecard_history_detail_card_item_layout, null);
								actionModeECardView.setLayoutParams(lp);
								TextView actionModeECardName = (TextView) actionModeECardView.findViewById(R.id.balance_card_name_text);
								actionModeECardName.setText(bc.getCardName());
								TextView actionModeECardAmount = (TextView) actionModeECardView.findViewById(R.id.balance_card_amount_text);
								int actionMode = bc.getActionMode();
								//如果是消费支出 或者是消费退还
								if (actionMode == 1 || actionMode == 9 || actionMode == 11) {
									//如果不是储值卡，则显示卡支付了多少显示相当于多少金钱
									if (bc.getCardType() != 1) {
										if (bc.getCardType() == 2)
											actionModeECardAmount.setText(NumberFormatUtil.currencyFormat(bc.getCardPaidAmount()) + "抵" + currency + NumberFormatUtil.currencyFormat(bc.getAmount()));
										else
											actionModeECardAmount.setText(currency + NumberFormatUtil.currencyFormat(bc.getCardPaidAmount()) + "抵" + currency + NumberFormatUtil.currencyFormat(bc.getAmount()));

									} else
										actionModeECardAmount.setText(currency + NumberFormatUtil.currencyFormat(bc.getAmount()));
								}
								//赠送退还
								else if (actionMode == 13) {
									if (bc.getCardType() != 2)
										actionModeECardAmount.setText(currency + NumberFormatUtil.currencyFormat(bc.getCardPaidAmount()));
									else
										actionModeECardAmount.setText(NumberFormatUtil.currencyFormat(bc.getCardPaidAmount()));
								} else {
									if (bc.getCardType() != 2)
										actionModeECardAmount.setText(currency + NumberFormatUtil.currencyFormat(bc.getAmount()));
									else
										actionModeECardAmount.setText(bc.getAmount());
								}
								TextView actionModeECardBalance = (TextView) actionModeECardView.findViewById(R.id.balance_card_balance_text);
								if (bc.getCardType() != 2)
									actionModeECardBalance.setText(currency + NumberFormatUtil.currencyFormat(bc.getBalance()));
								else
									actionModeECardBalance.setText(bc.getBalance());
								ecardActionModeLinearlayout.addView(actionModeECardView);
							}
						}
						ecardHistoryDetailActivity.ecardHistoryDetailActionModeListLinearlayout.addView(ecardActionModeView);
					}
				}
				ecardHistoryDetailActivity.ecardHistoryDetailOrderListLinearlayout = (LinearLayout) ecardHistoryDetailActivity.findViewById(R.id.ecard_history_detail_order_list_linearlayout);
				List<OrderInfo> orderList = ecardHistoryDetail.getEcardHistoryOrderList();
				if (orderList != null && orderList.size() > 0) {
					for (int i = 0; i < orderList.size(); i++) {
						final OrderInfo oi = orderList.get(i);
						View paymentRecordDetailOrderView = ecardHistoryDetailActivity.layoutInflater.inflate(R.xml.payment_record_detail_order_item_layout, null);
						paymentRecordDetailOrderView.setLayoutParams(lp);
						RelativeLayout paymentDetailOrderJoin = (RelativeLayout) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_join);
						paymentDetailOrderJoin.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View v) {
								// TODO Auto-generated method stub
								Intent destIntent = new Intent(ecardHistoryDetailActivity, OrderDetailActivity.class);
								destIntent.putExtra("orderInfo", oi);
								destIntent.putExtra("FromOrderList", true);
								ecardHistoryDetailActivity.startActivity(destIntent);
							}
						});
						TextView paymentRecordDetailOrderNumber = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_serial_number);
						paymentRecordDetailOrderNumber.setText(orderList.get(i).getOrderSerialNumber());
						TextView paymentRecordDetailOrderProductName = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_product_name);
						paymentRecordDetailOrderProductName.setText(orderList.get(i).getProductName());
						TextView paymentRecordDetailOrderPrice = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_total_price);
						paymentRecordDetailOrderPrice.setText(currency + NumberFormatUtil.currencyFormat(orderList.get(i).getTotalSalePrice()));
						ecardHistoryDetailActivity.ecardHistoryDetailOrderListLinearlayout.addView(paymentRecordDetailOrderView);
					}
				}

			} else if (msg.what == 0) {
				DialogUtil.createMakeSureDialog(ecardHistoryDetailActivity, "提示信息", "您的网络貌似不给力，请检查网络设置！");
			} else if (msg.what == 2) {
				String message = (String) msg.obj;
				DialogUtil.createMakeSureDialog(ecardHistoryDetailActivity, "提示信息", message);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(ecardHistoryDetailActivity, ecardHistoryDetailActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(ecardHistoryDetailActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + ecardHistoryDetailActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(ecardHistoryDetailActivity);
				ecardHistoryDetailActivity.packageUpdateUtil = new PackageUpdateUtil(ecardHistoryDetailActivity, ecardHistoryDetailActivity.mHandler, fileCache, downloadFileUrl, false, ecardHistoryDetailActivity.userinfoApplication);
				ecardHistoryDetailActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				ecardHistoryDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = ecardHistoryDetailActivity.getFileStreamPath(filename);
				file.getName();
				ecardHistoryDetailActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (ecardHistoryDetailActivity.requestWebServiceThread != null) {
				ecardHistoryDetailActivity.requestWebServiceThread.interrupt();
				ecardHistoryDetailActivity.requestWebServiceThread = null;
			}
		}
	}

	private void initView() {
		userinfoApplication = UserInfoApplication.getInstance();
		Intent intent=getIntent();
		balanceID=intent.getIntExtra("balanceID",0);
		cardType=intent.getIntExtra("cardType",0);
		changeType=intent.getIntExtra("changeType",0);
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebServiceThread = new Thread() {
			public void run() {
				String methodName ="GetBalanceDetailInfo";
				String endPoint = "ECard";
				JSONObject balanceDetailJsonParam = new JSONObject();
				try {
					balanceDetailJsonParam.put("ID",balanceID);
					balanceDetailJsonParam.put("CardType",cardType);
					balanceDetailJsonParam.put("ChangeType",changeType);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,balanceDetailJsonParam.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e) {
				}
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					String code = "0";
					String message = "";
					EcardHistoryDetail ecardHistoryDetail=null;
					try {
						code = resultJson.getString("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = "0";
					}
					if (Integer.parseInt(code) == 1) {
						JSONObject balanceDetailJson = null;
						try {
							balanceDetailJson = resultJson.getJSONObject("Data");
						} catch (JSONException e) {
						}
						if (balanceDetailJson != null) {
							try {
								ecardHistoryDetail = new EcardHistoryDetail();
								String ecardHistoryDetailNo="";//交易编号
								String ecardHistoryDetailCreateTime="";//交易时间
								String ecardHistoryDetailBranchName="";//交易门店
								String ecardHistoryDetailActionModeName="";//交易类型
								String ecardHistoryDetailAmount="";
								String ecardHistoryDetailRemark="";//交易备注
								String ecardHistoryDetailOperator="";//交易操作人
								List<EcardActionMode> ecardActionModeList=null;//发生交易的动作列表
								List<OrderInfo>  ecardHistoryOrderList=null;//交易订单列表
								if(balanceDetailJson.has("BalanceNumber") && !balanceDetailJson.isNull("BalanceNumber"))
									ecardHistoryDetailNo=balanceDetailJson.getString("BalanceNumber");
								if(balanceDetailJson.has("CreateTime") && !balanceDetailJson.isNull("CreateTime"))
									ecardHistoryDetailCreateTime=balanceDetailJson.getString("CreateTime");
								if(balanceDetailJson.has("BranchName") && !balanceDetailJson.isNull("BranchName"))
									ecardHistoryDetailBranchName=balanceDetailJson.getString("BranchName");
								if(balanceDetailJson.has("ChangeTypeName") && !balanceDetailJson.isNull("ChangeTypeName"))
									ecardHistoryDetailActionModeName=balanceDetailJson.getString("ChangeTypeName");
								if(balanceDetailJson.has("Remark") && !balanceDetailJson.isNull("Remark"))
									ecardHistoryDetailRemark=balanceDetailJson.getString("Remark");
								if(balanceDetailJson.has("Operator") && !balanceDetailJson.isNull("Operator"))
									ecardHistoryDetailOperator=balanceDetailJson.getString("Operator");
								if(balanceDetailJson.has("Amount") && !balanceDetailJson.isNull("Amount"))
									ecardHistoryDetailAmount=String.valueOf(MathUtil.getMathABS(balanceDetailJson.getDouble("Amount")));
								//获取本次交易的业绩参与人
								List<BenefitPerson> benefitPersonList=new ArrayList<BenefitPerson>();
								if(balanceDetailJson.has("ProfitList") && !balanceDetailJson.isNull("ProfitList")){
									JSONArray profitArray=balanceDetailJson.getJSONArray("ProfitList");
									for(int j=0;j<profitArray.length();j++){
										JSONObject benefitPersonJson=profitArray.getJSONObject(j);
										BenefitPerson bp=new BenefitPerson();
										bp.setAccountID(benefitPersonJson.getInt("AccountID"));
										bp.setAccountName(benefitPersonJson.getString("AccountName"));
										bp.setProfitPct(NumberFormatUtil.currencyFormat(String.valueOf(benefitPersonJson.getDouble("ProfitPct")*100)));
										benefitPersonList.add(bp);
									}
									
								}
								//获取本次交易的所有操作详细
								if(balanceDetailJson.has("BalanceInfoList") && !balanceDetailJson.isNull("BalanceInfoList")){
									ecardActionModeList=new ArrayList<EcardActionMode>();
									JSONArray ecardActionModeJsonArray=balanceDetailJson.getJSONArray("BalanceInfoList");
									for(int i=0;i<ecardActionModeJsonArray.length();i++){
										JSONObject ecardActionModeJson=ecardActionModeJsonArray.getJSONObject(i);
										EcardActionMode ecardActionMode=new EcardActionMode();
										int actionMode=0;
										String actionModeName="";
										if(ecardActionModeJson.has("ActionMode") && !ecardActionModeJson.isNull("ActionMode"))
											actionMode=ecardActionModeJson.getInt("ActionMode");
										if(ecardActionModeJson.has("ActionModeName") && !ecardActionModeJson.isNull("ActionModeName"))
											actionModeName=ecardActionModeJson.getString("ActionModeName");
										ecardActionMode.setEcardActionMode(actionMode);
										ecardActionMode.setEcardActionModeName(actionModeName);
										//获取这次动作所有的设计账户信息
										if(ecardActionModeJson.has("BalanceCardList") && !ecardActionModeJson.isNull("BalanceCardList")){
											List<BalanceCard> balanceCardList=new ArrayList<BalanceCard>();
											JSONArray balanceCardJsonArray=ecardActionModeJson.getJSONArray("BalanceCardList");
											for(int j=0;j<balanceCardJsonArray.length();j++){
												JSONObject balanceCardJson=balanceCardJsonArray.getJSONObject(j);
												BalanceCard balanceCard=new BalanceCard();
												int    bcactionMode=0;
												String bcactionModeName="";
												int    bcCardType=0;
												String cardName="";
												String amount="";
												String balance="";
												String cardPaidAmount="";
												if(balanceCardJson.has("ActionMode") && !balanceCardJson.isNull("ActionMode"))
													bcactionMode=balanceCardJson.getInt("ActionMode");
												if(balanceCardJson.has("CardType") && !balanceCardJson.isNull("CardType"))
													bcCardType=balanceCardJson.getInt("CardType");
												if(balanceCardJson.has("ActionModeName") && !balanceCardJson.isNull("ActionModeName"))
													bcactionModeName=balanceCardJson.getString("ActionModeName");
												if(balanceCardJson.has("CardName") && !balanceCardJson.isNull("CardName"))
													cardName=balanceCardJson.getString("CardName");
												if(balanceCardJson.has("Amount") && !balanceCardJson.isNull("Amount"))
													amount=String.valueOf(MathUtil.getMathABS(balanceCardJson.getDouble("Amount")));
												if(balanceCardJson.has("Balance") && !balanceCardJson.isNull("Balance"))
													balance=balanceCardJson.getString("Balance");
												if(balanceCardJson.has("CardPaidAmount") && !balanceCardJson.isNull("CardPaidAmount"))
													cardPaidAmount=String.valueOf(MathUtil.getMathABS(balanceCardJson.getDouble("CardPaidAmount")));
												balanceCard.setActionMode(bcactionMode);
												balanceCard.setActionModeName(bcactionModeName);
												balanceCard.setCardName(cardName);
												balanceCard.setAmount(amount);
												balanceCard.setBalance(balance);
												balanceCard.setCardType(bcCardType);
												balanceCard.setCardPaidAmount(cardPaidAmount);
												balanceCardList.add(balanceCard);
											}
											ecardActionMode.setBalanceCardList(balanceCardList);
										}
										ecardActionModeList.add(ecardActionMode);
									}
								}
								//订单列表信息
								if(balanceDetailJson.has("OrderList") && !balanceDetailJson.isNull("OrderList")){
									ecardHistoryOrderList=new ArrayList<OrderInfo>();
									JSONArray orderJsonArray=balanceDetailJson.getJSONArray("OrderList");
									for(int i=0;i<orderJsonArray.length();i++){
										JSONObject orderInfoJson=orderJsonArray.getJSONObject(i);
										OrderInfo orderInfo=new OrderInfo();
										int   orderID=0;
										int    orderObjectID=0;
										String orderNumber="";
										String productName="";
										int    productType=0;
										String totalSalePrice="";
										if(orderInfoJson.has("OrderID") && !orderInfoJson.isNull("OrderID"))
											orderID=orderInfoJson.getInt("OrderID");
										if(orderInfoJson.has("OrderObjectID") && !orderInfoJson.isNull("OrderObjectID"))
											orderObjectID=orderInfoJson.getInt("OrderObjectID");
										if(orderInfoJson.has("OrderNumber") && !orderInfoJson.isNull("OrderNumber"))
											orderNumber=orderInfoJson.getString("OrderNumber");
										if(orderInfoJson.has("ProductName") && !orderInfoJson.isNull("ProductName"))
											productName=orderInfoJson.getString("ProductName");
										if(orderInfoJson.has("ProductType") && !orderInfoJson.isNull("ProductType"))
											productType=orderInfoJson.getInt("ProductType");
										if(orderInfoJson.has("TotalSalePrice") && !orderInfoJson.isNull("TotalSalePrice"))
											totalSalePrice=orderInfoJson.getString("TotalSalePrice");
										orderInfo.setOrderID(orderID);
										orderInfo.setOrderObejctID(orderObjectID);
										orderInfo.setOrderSerialNumber(orderNumber);
										orderInfo.setProductName(productName);
										orderInfo.setProductType(productType);
										orderInfo.setTotalSalePrice(totalSalePrice);
										ecardHistoryOrderList.add(orderInfo);
									}
								}
								ecardHistoryDetail.setEcardHistoryDetailNo(ecardHistoryDetailNo);
								ecardHistoryDetail.setEcardHistoryDetailCreateTime(ecardHistoryDetailCreateTime);
								ecardHistoryDetail.setEcardHistoryDetailBranchName(ecardHistoryDetailBranchName);
								ecardHistoryDetail.setEcardHistoryDetailActionModeName(ecardHistoryDetailActionModeName);
								ecardHistoryDetail.setEcardHistoryDetailAmount(ecardHistoryDetailAmount);
								ecardHistoryDetail.setEcardHistoryDetailOperator(ecardHistoryDetailOperator);
								ecardHistoryDetail.setEcardHistoryDetailRemark(ecardHistoryDetailRemark);
								ecardHistoryDetail.setEcardHistoryDetailProfitList(benefitPersonList);
								ecardHistoryDetail.setEcardActionModeList(ecardActionModeList);
								ecardHistoryDetail.setEcardHistoryOrderList(ecardHistoryOrderList);
							} catch (NumberFormatException e) {
							} catch (JSONException e) {
								e.printStackTrace();
							}
						}
						Message msg = new Message();
						msg.what = 1;
						msg.obj = ecardHistoryDetail;
						mHandler.sendMessage(msg);
					}
					else if(Integer.parseInt(code)==Constant.APP_VERSION_ERROR || Integer.parseInt(code)==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(Integer.parseInt(code));
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

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
	}
}
