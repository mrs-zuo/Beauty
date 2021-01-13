package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.DialogFragment;
import android.text.Editable;
import android.text.InputType;
import android.text.Selection;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TableLayout;
import android.widget.TableLayout.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AppointmentDetailInfo;
import com.GlamourPromise.Beauty.bean.BenefitSpinnerBean;
import com.GlamourPromise.Beauty.bean.CustomerBenefit;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.EcardSpinnerBean;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.StepTemplate;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DateButton;
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.menu.BusinessRightMenu;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

/*
 * 开单界面
 * */
@SuppressLint({"ResourceType", "LongLogTag"})
public class PrepareOrderActivity extends BaseActivity implements OnClickListener {
    private PrepareOrderActivityHandler mHandler = new PrepareOrderActivityHandler(this);
    private TextView prepareOrderCustomerText, prepareOrderTitleText, prepareOrderTotalPriceText, prepareOrderTotalSalePriceText;
    private LinearLayout prepareOrderProductListView, prepareOrderOldListView;
    private Button prepareOrderCommit;
    private ProgressDialog progressDialog, progressDialog2;
    private Thread requestWebServiceThread;
    private List<OrderProduct> orderProductList;
    private TableLayout prepareOrderTotalCountTableLayout;
    private int selectedCustomerID, opportunityID, fromWhere, isZeroOrder, operationIndex, isPastPayAll;
    private UserInfoApplication userinfoApplication;
    private LayoutInflater layoutInflater;
    private PackageUpdateUtil packageUpdateUtil;
    private List<OrderInfo> quickBalanceOrderList;
    private List<StepTemplate> stepTemplateList;//商机模板集合
    private List<CustomerBenefit> customerBenefitsList;
    // 获取优惠券状态标志
    private boolean getCustomerBenefitListRunning = false;
    DecimalFormat df = new DecimalFormat("#.00");
    DecimalFormat df2 = new DecimalFormat("0.00");
    JSONArray OldOrderIdArray = new JSONArray();
    List<EcardInfo> ecardInfoList;
    ArrayList<String> list = new ArrayList<String>();
    View prepareOrderProductTotalSpinnerView;
    long taskID = 0;
    String fromSource;
    RelativeLayout orderProductCardSpinnerRelativeLayout;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        // 开单闪退对应(PrepareOrderActivity初期化开始)
        progressDialog2 = ProgressDialogUtil.createProgressDialog(this);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_prepare_order);
        // 初始化数据信息
        initData();
        //从服务器查询最新商品和服务价格和信息
        requestNewestProductInfo();
    }

    int orderQuantity = 1;
    private AlertDialog discountDialog;

    private static class PrepareOrderActivityHandler extends Handler {
        private final PrepareOrderActivity prepareOrderActivity;

        private PrepareOrderActivityHandler(PrepareOrderActivity activity) {
            WeakReference<PrepareOrderActivity> weakReference = new WeakReference<PrepareOrderActivity>(activity);
            prepareOrderActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (prepareOrderActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (prepareOrderActivity.progressDialog != null) {
                prepareOrderActivity.progressDialog.dismiss();
                prepareOrderActivity.progressDialog = null;
            }
            // 建立需求成功
            if (msg.what == 1) {
                Intent intent = new Intent(prepareOrderActivity, OpportunityListActivity.class);
                prepareOrderActivity.startActivity(intent);
                if (prepareOrderActivity.orderProductList != null)
                    prepareOrderActivity.orderProductList.clear();
            }
            // 直接下单
            else if (msg.what == 2) {
                int authOrderPayment = prepareOrderActivity.userinfoApplication.getAccountInfo().getAuthPaymentUse();
                //有支付权限 并且全部订单不是0元订单  没有全部过去支付完成
                if (authOrderPayment == 1 && prepareOrderActivity.isZeroOrder == 0 && prepareOrderActivity.isPastPayAll == 0) {
                    Dialog dialog = new AlertDialog.Builder(prepareOrderActivity, R.style.CustomerAlertDialog)
                            .setTitle(prepareOrderActivity.getString(R.string.delete_dialog_title))
                            .setMessage(R.string.now_to_balance)
                            .setPositiveButton(prepareOrderActivity.getString(R.string.balance_at_once),
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                            Intent destIntent = new Intent(prepareOrderActivity, PaymentActionActivity.class);
                                            int paidOrderCount = 0;
                                            double paidOrderTotalPrice = 0;
                                            double paidOrderTotalSalePrice = 0;
                                            StringBuffer paidOrderIDs = new StringBuffer();
                                            StringBuffer paidOrderTypes = new StringBuffer();
                                            for (int i = 0; i < prepareOrderActivity.quickBalanceOrderList.size(); i++) {
                                                OrderInfo orderInfo = prepareOrderActivity.quickBalanceOrderList.get(i);
                                                boolean shouldAddPay = false;
                                                // 非0元订单传到支付页面 或者是过去没有全部支付过
                                                if (Double.parseDouble(orderInfo.getTotalSalePrice()) > 0) {
                                                    if ((orderInfo.isPast() && NumberFormatUtil.doubleCompare(Double.valueOf(orderInfo.getTotalSalePrice()), orderInfo.getOrderPastPaidPrice()) > 0) || !orderInfo.isPast()) {
                                                        shouldAddPay = true;
                                                    }
                                                }
                                                if (shouldAddPay) {
                                                    paidOrderCount += 1;
                                                    paidOrderTotalPrice += Double.parseDouble(orderInfo.getTotalPrice());
                                                    paidOrderTotalSalePrice += Double.parseDouble(orderInfo.getTotalSalePrice());
                                                    paidOrderIDs.append(orderInfo.getOrderID() + ",");
                                                    paidOrderTypes.append(prepareOrderActivity.orderProductList.get(i).getProductType() + ",");
                                                }
                                            }
                                            destIntent.putExtra("CUSTOMER_ID", prepareOrderActivity.selectedCustomerID);
                                            destIntent.putExtra("PAID_ORDER_IDS", paidOrderIDs.toString());
                                            destIntent.putExtra("PAID_ORDER_COUNT", paidOrderCount);
                                            destIntent.putExtra("PAID_ORDER_TOTAL_PRICE", paidOrderTotalPrice);
                                            destIntent.putExtra("PAID_ORDER_TOTAL_SALE_PRICE", paidOrderTotalSalePrice);
                                            destIntent.putExtra("BALANCE_STYLE", "QUICK");
                                            destIntent.putExtra("PAID_ORDER_TYPES", paidOrderTypes.toString());
                                            if (prepareOrderActivity.opportunityID != 0) {
                                                destIntent.putExtra("BALANCE_STYLE_PAY_FOR", "OPPORTUNITY");
                                            }
                                            if (prepareOrderActivity.orderProductList != null)
                                                prepareOrderActivity.orderProductList.clear();
                                            prepareOrderActivity.startActivity(destIntent);
                                        }
                                    })
                            .setNegativeButton(prepareOrderActivity.getString(R.string.balance_later),
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            // TODO Auto-generated method stub
                                            dialog.dismiss();
                                            dialog = null;
                                            Intent destIntent = null;
                                            // 从需求转成订单
                                            if (prepareOrderActivity.fromWhere == 0) {
                                                // 跳转到订单详细
                                                Bundle bundle = new Bundle();
                                                OrderInfo orderInfo = new OrderInfo();
                                                orderInfo.setOrderID(prepareOrderActivity.quickBalanceOrderList.get(0).getOrderID());
                                                orderInfo.setProductType(prepareOrderActivity.orderProductList.get(0).getProductType());
                                                bundle.putSerializable("orderInfo", orderInfo);
                                                destIntent = new Intent(prepareOrderActivity, OrderDetailActivity.class);
                                                destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                                                destIntent.putExtras(bundle);
                                            }
                                            // 生成订单
                                            else {
                                                //客户选择被删除之后
                                                if (prepareOrderActivity.userinfoApplication.getSelectedCustomerID() == 0)
                                                    destIntent = new Intent(prepareOrderActivity, HomePageActivity.class);
                                                else {
                                                    // 如果是多个订单跳转到列表页
                                                    if (prepareOrderActivity.quickBalanceOrderList.size() > 1) {
                                                        destIntent = new Intent(prepareOrderActivity, OrderListActivity.class);
                                                        destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                                                        destIntent.putExtra("currentItem", 1);
                                                    }
                                                    // 单个订单则跳转到订单详细
                                                    else if (prepareOrderActivity.quickBalanceOrderList.size() == 1) {
                                                        Bundle bundle = new Bundle();
                                                        OrderInfo orderInfo = new OrderInfo();
                                                        orderInfo.setOrderID(prepareOrderActivity.quickBalanceOrderList.get(0).getOrderID());
                                                        orderInfo.setProductType(prepareOrderActivity.orderProductList.get(0).getProductType());
                                                        bundle.putSerializable("orderInfo", orderInfo);
                                                        destIntent = new Intent(prepareOrderActivity, OrderDetailActivity.class);
                                                        destIntent.putExtra("userRole", Constant.USER_ROLE_CUSTOMER);
                                                        destIntent.putExtras(bundle);
                                                    }
                                                }
                                            }
                                            if (prepareOrderActivity.orderProductList != null)
                                                prepareOrderActivity.orderProductList.clear();
                                            prepareOrderActivity.startActivity(destIntent);
                                        }
                                    }).create();
                    dialog.show();
                    dialog.setCancelable(false);
                } else if (authOrderPayment == 0 || prepareOrderActivity.isZeroOrder == 1 || prepareOrderActivity.isPastPayAll == 1) {
                    Intent destIntent = null;
                    // 从需求转成订单
                    if (prepareOrderActivity.fromWhere == 0) {
                        Bundle bundle = new Bundle();
                        OrderInfo orderInfo = new OrderInfo();
                        orderInfo.setOrderID(prepareOrderActivity.quickBalanceOrderList.get(0).getOrderID());
                        orderInfo.setProductType(prepareOrderActivity.orderProductList.get(0).getProductType());
                        bundle.putSerializable("orderInfo", orderInfo);
                        destIntent = new Intent(prepareOrderActivity, OrderDetailActivity.class);
                        destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                        destIntent.putExtras(bundle);
                    }
                    // 生成订单
                    else {
                        // 没有订单编辑权限或者客户选择被删除之后
                        if (prepareOrderActivity.userinfoApplication.getSelectedCustomerID() == 0)
                            destIntent = new Intent(prepareOrderActivity, HomePageActivity.class);
                        else {
                            // 如果是多个订单跳转到列表页
                            if (prepareOrderActivity.quickBalanceOrderList.size() > 1) {
                                destIntent = new Intent(prepareOrderActivity, OrderListActivity.class);
                                destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                                destIntent.putExtra("currentItem", 1);
                            }
                            // 单个订单则跳转到订单详细
                            else if (prepareOrderActivity.quickBalanceOrderList.size() == 1) {
                                Bundle bundle = new Bundle();
                                OrderInfo orderInfo = new OrderInfo();
                                orderInfo.setOrderID(prepareOrderActivity.quickBalanceOrderList.get(0).getOrderID());
                                orderInfo.setProductType(prepareOrderActivity.orderProductList.get(0).getProductType());
                                bundle.putSerializable("orderInfo", orderInfo);
                                destIntent = new Intent(prepareOrderActivity, OrderDetailActivity.class);
                                destIntent.putExtra("userRole", Constant.USER_ROLE_CUSTOMER);
                                destIntent.putExtras(bundle);
                            }
                        }
                    }
                    if (prepareOrderActivity.orderProductList != null)
                        prepareOrderActivity.orderProductList.clear();
                    prepareOrderActivity.startActivity(destIntent);
                }

            } else if (msg.what == 0) {
                String message = (String) msg.obj;
                DialogUtil.createMakeSureDialog(prepareOrderActivity, "提示信息", message);
            } else if (msg.what == -1)
                DialogUtil.createMakeSureDialog(prepareOrderActivity, "提示信息", "您的网络貌似不给力，请重试！");
                // 从服务器端成功获取最新商品和服务信息
            else if (msg.what == 3) {
                prepareOrderActivity.initView();
            }
            // 价格变动重新请求
            else if (msg.what == 4) {
                DialogUtil.createShortDialog(prepareOrderActivity, (String) msg.obj);
                prepareOrderActivity.requestNewestProductInfo();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(prepareOrderActivity, prepareOrderActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(prepareOrderActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + prepareOrderActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(prepareOrderActivity);
                prepareOrderActivity.packageUpdateUtil = new PackageUpdateUtil(prepareOrderActivity, prepareOrderActivity.mHandler, fileCache, downloadFileUrl, false, prepareOrderActivity.userinfoApplication);
                prepareOrderActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                prepareOrderActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = prepareOrderActivity.getFileStreamPath(filename);
                file.getName();
                prepareOrderActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            //暂存获得商机模板，如果只有一个商机模板则设置所有的服务或者商品是模板都一样 如果超过一个模板，则跳转到第三张页面，让客户自己选择
            else if (msg.what == 6) {
                if (prepareOrderActivity.stepTemplateList != null && prepareOrderActivity.stepTemplateList.size() > 0) {
                    if (prepareOrderActivity.stepTemplateList.size() == 1) {
                        StepTemplate st = prepareOrderActivity.stepTemplateList.get(0);
                        for (OrderProduct op : prepareOrderActivity.orderProductList) {
                            op.setStepTemplateId(st.getStepTemplateID());
                        }
                        prepareOrderActivity.addOpportunity();
                    } else if (prepareOrderActivity.stepTemplateList.size() > 1) {
                        for (int i = 0; i < prepareOrderActivity.orderProductList.size(); i++) {
                            double orderProductTotalSalePrice = 0;
                            try {
                                orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderActivity.prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_promotion_price)).getText().toString()));
                            } catch (NumberFormatException e) {
                                orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderActivity.prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_total_price)).getText().toString()));
                            }
                            prepareOrderActivity.orderProductList.get(i).setTotalSalePrice(String.valueOf(orderProductTotalSalePrice));
                            prepareOrderActivity.orderProductList.get(i).setQuantity(Integer.parseInt(((EditText) prepareOrderActivity.prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_quantity)).getText().toString()));
                        }
                        Intent destIntent = new Intent(prepareOrderActivity, AddOpportunityConfirmActivity.class);
                        Bundle bundle = new Bundle();
                        bundle.putSerializable("orderProductList", (Serializable) prepareOrderActivity.orderProductList);
                        bundle.putSerializable("stepTemplateList", (Serializable) prepareOrderActivity.stepTemplateList);
                        destIntent.putExtras(bundle);
                        prepareOrderActivity.startActivity(destIntent);
                    }
                }
            } else if (msg.what == 8) {
                final EcardSpinnerBean esb = (EcardSpinnerBean) msg.obj;
                final int j = msg.arg1;
                ArrayAdapter<String> cardArrayAdapter = new ArrayAdapter<String>(prepareOrderActivity, R.xml.spinner_checked_text, esb.getCardNameArray());
                cardArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                esb.getEcardSpinner().setAdapter(cardArrayAdapter);
                for (int i = 0; i < esb.getCardNameArray().length; i++) {
                    if (prepareOrderActivity.orderProductList.get(j).getUserEcardID() == Integer.parseInt(esb.getCardId().get(i).toString())) {
                        esb.getEcardSpinner().setSelection(i);
                        break;
                    }
                }
                esb.getEcardSpinner().setOnItemSelectedListener(new OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {
                        prepareOrderActivity.orderProductList.get(j).setUserEcardID(Integer.parseInt(esb.getCardId().get(position).toString()));
                        if (prepareOrderActivity.orderProductList.get(j).getMarketingPolicy() == 0) {
                            esb.getPrepareOrderProductPromotionPriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getTotalPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                            esb.getPrepareOrderProductTotalSalePriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getTotalPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                        } else if (prepareOrderActivity.orderProductList.get(j).getMarketingPolicy() == 1) {
                            esb.getPrepareOrderProductPromotionPriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getTotalPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                            esb.getPrepareOrderProductTotalSalePriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getTotalPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                        } else if (prepareOrderActivity.orderProductList.get(j).getMarketingPolicy() == 2) {
                            if (position != 0) {
                                esb.getPrepareOrderProductPromotionPriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getOldPromotionPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                                esb.getPrepareOrderProductTotalSalePriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getOldPromotionPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                            } else {
                                esb.getPrepareOrderProductPromotionPriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getTotalPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));
                                esb.getPrepareOrderProductTotalSalePriceText().setText(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(prepareOrderActivity.orderProductList.get(j).getTotalPrice()) * prepareOrderActivity.orderQuantity * Double.parseDouble(esb.getCardDiscount().get(position).toString()))));

                            }
                        }
                        prepareOrderActivity.orderProductList.get(j).setPromotionPrice(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(esb.getPrepareOrderProductPromotionPriceText().getText().toString()) / prepareOrderActivity.orderQuantity)));
                        prepareOrderActivity.orderProductList.get(j).setTotalSalePrice(String.valueOf(prepareOrderActivity.df.format(Double.parseDouble(esb.getPrepareOrderProductTotalSalePriceText().getText().toString()) / prepareOrderActivity.orderQuantity)));
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {

                    }

                });
            }
            //下大订单
            else if (msg.what == 9) {
                Intent prepareAndOldOrderit = new Intent(prepareOrderActivity, ProductAndOldOrderListActivity.class);
                Bundle b = new Bundle();
                b.putStringArrayList("orderIdList", prepareOrderActivity.list);
                prepareAndOldOrderit.putExtras(b);
                prepareOrderActivity.startActivity(prepareAndOldOrderit);
                prepareOrderActivity.finish();
                if (prepareOrderActivity.orderProductList != null && prepareOrderActivity.orderProductList.size() > 0) {
                    prepareOrderActivity.orderProductList.clear();
                }
            }
            //成功获取到券列表
            else if (msg.what == 10) {
                final BenefitSpinnerBean bsb = (BenefitSpinnerBean) msg.obj;
                final int j = msg.arg1;
                final List<CustomerBenefit> customerBenefitList = bsb.getCustomerBenefitList();
                String[] benefitNameArray = new String[customerBenefitList.size()];
                for (int i = 0; i < customerBenefitList.size(); i++) {
                    benefitNameArray[i] = customerBenefitList.get(i).getBenefitName();
                }
                ArrayAdapter<String> cardArrayAdapter = new ArrayAdapter<String>(prepareOrderActivity, R.xml.spinner_checked_text, benefitNameArray);
                cardArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                Spinner customerBenefitSpinner = (Spinner) bsb.getPrepareOrderProductView().findViewById(R.id.add_order_customer_benefits_spinner);
                customerBenefitSpinner.setAdapter(cardArrayAdapter);
                customerBenefitSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {
                        prepareOrderActivity.orderProductList.get(j).setBenefitID(customerBenefitList.get(position).getBenefitID());
                        double orderTotalPromotionPrice = Double.valueOf(((EditText) prepareOrderActivity.prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_promotion_price)).getText().toString());
                        //不使用优惠券或者本订单价格不在优惠券范围内 则将订单成交价恢复为订单B价格  如果符合条件  则将订单成交价调整为订单B价格减去优惠券优惠价格
                        if (!TextUtils.isEmpty(customerBenefitList.get(position).getBenefitID())) {
                            if (customerBenefitList.get(position).getPrValue1() <= orderTotalPromotionPrice) {
                                prepareOrderActivity.orderProductList.get(j).setTotalSalePrice(String.valueOf(orderTotalPromotionPrice - customerBenefitList.get(position).getPrValue2()));
                                prepareOrderActivity.orderProductList.get(j).setPrValue2(customerBenefitList.get(position).getPrValue2());

                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_sale_price1_divide_view).setVisibility(View.VISIBLE);
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_discuss_relativelayout).setVisibility(View.VISIBLE);
                                ((TextView) bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_sale_price)).setText(String.valueOf(prepareOrderActivity.df.format(orderTotalPromotionPrice - customerBenefitList.get(position).getPrValue2())));
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_divide_view).setVisibility(View.VISIBLE);
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_relativelayout).setVisibility(View.VISIBLE);
                                ((TextView) bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_text)).setText(customerBenefitList.get(position).getBenefitRule());
                            } else {

                                ((TextView) bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_sale_price)).setText(String.valueOf(prepareOrderActivity.df.format(orderTotalPromotionPrice)));
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_sale_price1_divide_view).setVisibility(View.GONE);
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_discuss_relativelayout).setVisibility(View.GONE);
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_divide_view).setVisibility(View.GONE);
                                bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_relativelayout).setVisibility(View.GONE);
                            }
                        } else {
                            ((TextView) bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_sale_price)).setText(String.valueOf(prepareOrderActivity.df.format(orderTotalPromotionPrice)));
                            bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_divide_view).setVisibility(View.GONE);
                            bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_benfit_rule_relativelayout).setVisibility(View.GONE);
                            bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_sale_price1_divide_view).setVisibility(View.GONE);
                            bsb.getPrepareOrderProductView().findViewById(R.id.prepare_order_product_total_discuss_relativelayout).setVisibility(View.GONE);
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {

                    }

                });
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(prepareOrderActivity, "服务器异常，请重试");
            }
            if (prepareOrderActivity.requestWebServiceThread != null) {
                prepareOrderActivity.requestWebServiceThread.interrupt();
                prepareOrderActivity.requestWebServiceThread = null;
            }
        }
    }

    //会员卡
    protected void discountInfo(final long productCode, final int productType, final Spinner addCardSpinner, final EditText prepareOrderProductTotalSalePriceText, final int k, final EditText prepareOrderProductPromotionPriceText) {
        if (orderProductList == null || orderProductList.size() == 0) {
            DialogUtil.createMakeSureDialog(this, "温馨提示", "请选择服务或者商品开单");
        } else {
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    if (exit) {
                        return;
                    }
                    String methodName = "GetCardDiscountList";
                    String endPoint = "ECard";
                    JSONObject getProductInfoJson = new JSONObject();
                    try {
                        getProductInfoJson.put("CustomerID", selectedCustomerID);
                        getProductInfoJson.put("ProductCode", productCode);
                        getProductInfoJson.put("ProductType", productType);
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getProductInfoJson.toString(), userinfoApplication);
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResultResult);
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (serverResultResult == null || serverResultResult.equals(""))
                        mHandler.sendEmptyMessage(-1);
                    else {
                        int code = 0;
                        String message = "";
                        try {
                            code = resultJson.getInt("Code");
                            message = resultJson.getString("Message");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                            code = 0;
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (code == 1) {
                            List<EcardInfo> ecardInfos = new ArrayList<EcardInfo>();
                            JSONArray productArray = null;
                            try {
                                productArray = resultJson.getJSONArray("Data");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            if (productArray != null) {
                                EcardInfo ecardInfo1 = new EcardInfo();
                                ecardInfo1.setUserEcardID(0);
                                ecardInfo1.setUserEcardNo("0");
                                ecardInfo1.setUserEcardName("不使用e账户");
                                ecardInfo1.setUserEcardDiscount("1");
                                ecardInfo1.setUserEcardNameAndDiscount("不使用e账户");
                                ecardInfos.add(ecardInfo1);
                                for (int i = 0; i < productArray.length(); i++) {
                                    JSONObject productjson = null;
                                    try {
                                        productjson = (JSONObject) productArray.get(i);
                                    } catch (JSONException e) {
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                    try {
                                        EcardInfo ecardInfo = new EcardInfo();
                                        if (productjson.has("CardID")) {
                                            ecardInfo.setUserEcardID(productjson.getInt("CardID"));
                                        }
                                        if (productjson.has("UserCardNo")) {
                                            ecardInfo.setUserEcardNo(productjson.getString("UserCardNo"));
                                        }
                                        if (productjson.has("CardName")) {
                                            ecardInfo.setUserEcardName(productjson.getString("CardName"));
                                        }
                                        if (productjson.has("Discount")) {
                                            ecardInfo.setUserEcardDiscount(productjson.getString("Discount"));
                                        }
                                        if (productjson.has("CardName") && productjson.has("Discount")) {
                                            if (!(productjson.getString("Discount")).equals("1.0")) {
                                                ecardInfo.setUserEcardNameAndDiscount(productjson.getString("CardName") + "(" + productjson.getString("Discount") + ")");
                                            } else {
                                                ecardInfo.setUserEcardNameAndDiscount(productjson.getString("CardName"));
                                            }
                                        }
                                        ecardInfos.add(ecardInfo);
                                    } catch (JSONException e) {
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                }
                            }
                            ecardInfoList.clear();
                            ecardInfos.addAll(ecardInfos);
                            Message msg = new Message();
                            EcardSpinnerBean esb = new EcardSpinnerBean();
                            String[] cardNameArray = new String[ecardInfos.size()];
                            ArrayList<String> cardDiscount = new ArrayList<String>();
                            ArrayList<String> cardId = new ArrayList<String>();
                            for (int j = 0; j < ecardInfos.size(); j++) {
                                cardId.add(String.valueOf(ecardInfos.get(j).getUserEcardID()));
                                cardDiscount.add(ecardInfos.get(j).getUserEcardDiscount());
                                cardNameArray[j] = ecardInfos.get(j).getUserEcardNameAndDiscount();
                            }
                            esb.setEcardSpinner(addCardSpinner);
                            esb.setCardNameArray(cardNameArray);
                            esb.setCardDiscount(cardDiscount);
                            esb.setCardId(cardId);
                            esb.setPrepareOrderProductTotalSalePriceText(prepareOrderProductTotalSalePriceText);
                            esb.setPrepareOrderProductPromotionPriceText(prepareOrderProductPromotionPriceText);
                            msg.obj = esb;
                            msg.what = 8;
                            msg.arg1 = k;
                            mHandler.sendMessage(msg);
                        } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                            mHandler.sendEmptyMessage(code);
                        else {
                            Message msg = new Message();
                            msg.what = 0;
                            msg.obj = message;
                            mHandler.sendMessage(msg);
                        }
                    }
                }
            };
            requestWebServiceThread.start();
        }

    }

    protected void requestNewestProductInfo() {
        if (orderProductList == null || orderProductList.size() == 0) {
            DialogUtil.createMakeSureDialog(this, "温馨提示", "请选择服务或者商品开单");
        } else {
            progressDialog = ProgressDialogUtil.createProgressDialog(this);
            ecardInfoList = new ArrayList<EcardInfo>();
            final JSONArray oldProductArray = new JSONArray();
            for (int j = 0; j < orderProductList.size(); j++) {
                JSONObject oldProduct = new JSONObject();
                OrderProduct orderProduct = orderProductList.get(j);
                try {
                    oldProduct.put("Code", orderProduct.getProductCode());
                    oldProduct.put("ProductType", orderProduct.getProductType());
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                oldProductArray.put(oldProduct);
            }
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    if (exit) {
                        return;
                    }
                    String methodName = "getProductInfoList";
                    String endPoint = "Commodity";
                    JSONObject getProductInfoJson = new JSONObject();
                    try {
                        getProductInfoJson.put("CustomerID", selectedCustomerID);
                        getProductInfoJson.put("ProductCode", oldProductArray);
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getProductInfoJson.toString(), userinfoApplication);
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResultResult);
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (serverResultResult == null || serverResultResult.equals(""))
                        mHandler.sendEmptyMessage(-1);
                    else {
                        int code = 0;
                        String message = "";
                        try {
                            code = resultJson.getInt("Code");
                            message = resultJson.getString("Message");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                            code = 0;
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (code == 1) {
                            JSONArray productArray = null;
                            try {
                                productArray = resultJson.getJSONArray("Data");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            if (productArray != null) {
                                for (int i = 0; i < productArray.length(); i++) {
                                    JSONObject productjson = null;
                                    try {
                                        productjson = (JSONObject) productArray.get(i);
                                    } catch (JSONException e) {
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                    try {

                                        for (int j = 0; j < orderProductList.size(); j++) {
                                            OrderProduct op = orderProductList.get(j);
                                            if (taskID != 0) {
                                                if (productjson.has("ID")) {
                                                    orderProductList.get(j).setProductID(productjson.getInt("ID"));
                                                }
                                                if (productjson.has("Code")) {
                                                    orderProductList.get(j).setProductCode(productjson.getLong("Code"));
                                                }
                                                if (productjson.has("ProductType")) {
                                                    orderProductList.get(j).setProductType(productjson.getInt("ProductType"));
                                                }
                                                if (productjson.has("Name")) {
                                                    orderProductList.get(j).setProductName(productjson.getString("Name"));
                                                }
                                                if (productjson.has("UnitPrice")) {
                                                    orderProductList.get(j).setUnitPrice(productjson.getString("UnitPrice"));
                                                }
                                                if (opportunityID == 0) {
                                                    orderProductList.get(j).setQuantity(1);
                                                }
                                                if (productjson.has("PromotionPrice")) {
                                                    orderProductList.get(j).setPromotionPrice(productjson.getString("PromotionPrice"));
                                                    orderProductList.get(j).setOldPromotionPrice(productjson.getString("PromotionPrice"));
                                                }
                                                if (productjson.has("MarketingPolicy")) {
                                                    orderProductList.get(j).setMarketingPolicy(productjson.getInt("MarketingPolicy"));
                                                    orderProductList.get(j).setTotalPrice(String.valueOf(Double.valueOf(orderProductList.get(j).getUnitPrice()) * 1));
                                                    if (orderProductList.get(j).getProductType() == Constant.SERVICE_TYPE) {
                                                        orderProductList.get(j).setServiceOrderExpirationDate(productjson.getString("ExpirationDate"));
                                                    }
                                                }
                                                if (productjson.has("CardName")) {
                                                    orderProductList.get(j).setUserEcardName(productjson.getString("CardName"));
                                                }
                                                if (productjson.has("CardID")) {
                                                    orderProductList.get(j).setUserEcardID(productjson.getInt("CardID"));
                                                }
                                                if (productjson.has("CourseFrequency")) {
                                                    orderProductList.get(j).setCourseFrequency(productjson.getInt("CourseFrequency"));
                                                }
                                            } else {
                                                if (!op.isOldOrder() && op.getProductCode() == productjson.getLong("Code") && op.getProductType() == productjson.getInt("ProductType")) {
                                                    if (productjson.has("ID")) {
                                                        orderProductList.get(j).setProductID(productjson.getInt("ID"));
                                                    }
                                                    if (productjson.has("Code")) {
                                                        orderProductList.get(j).setProductCode(productjson.getLong("Code"));
                                                    }
                                                    if (productjson.has("ProductType")) {
                                                        orderProductList.get(j).setProductType(productjson.getInt("ProductType"));
                                                    }
                                                    if (productjson.has("Name")) {
                                                        orderProductList.get(j).setProductName(productjson.getString("Name"));
                                                    }
                                                    if (productjson.has("UnitPrice")) {
                                                        orderProductList.get(j).setUnitPrice(productjson.getString("UnitPrice"));
                                                    }
                                                    if (opportunityID == 0) {
                                                        orderProductList.get(j).setQuantity(1);
                                                    }
                                                    if (productjson.has("PromotionPrice")) {
                                                        orderProductList.get(j).setPromotionPrice(productjson.getString("PromotionPrice"));
                                                        orderProductList.get(j).setOldPromotionPrice(productjson.getString("PromotionPrice"));
                                                    }
                                                    if (productjson.has("MarketingPolicy")) {
                                                        orderProductList.get(j).setMarketingPolicy(productjson.getInt("MarketingPolicy"));
                                                        orderProductList.get(j).setTotalPrice(String.valueOf(Double.valueOf(orderProductList.get(j).getUnitPrice()) * 1));
                                                        if (orderProductList.get(j).getProductType() == Constant.SERVICE_TYPE) {
                                                            orderProductList.get(j).setServiceOrderExpirationDate(productjson.getString("ExpirationDate"));
                                                        }
                                                    }
                                                    if (productjson.has("CardName")) {
                                                        orderProductList.get(j).setUserEcardName(productjson.getString("CardName"));
                                                    }
                                                    if (productjson.has("CardID")) {
                                                        orderProductList.get(j).setUserEcardID(productjson.getInt("CardID"));
                                                    }
                                                    if (productjson.has("CourseFrequency")) {
                                                        orderProductList.get(j).setCourseFrequency(productjson.getInt("CourseFrequency"));
                                                    }
                                                }
                                            }
                                        }

                                    } catch (JSONException e) {
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                }
                            }
                            mHandler.sendEmptyMessage(3);
                        } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                            mHandler.sendEmptyMessage(code);
                        else {
                            Message msg = new Message();
                            msg.what = 0;
                            msg.obj = message;
                            mHandler.sendMessage(msg);
                        }
                    }
                }
            };
            requestWebServiceThread.start();
        }
    }

    private void getCustomerBenefitListData(final View prepareOrderProductView, final int k, final double prepareOrderPromotionPrice) {
        // 单件商品开单闪退对应(获取Ecard开始)
        getCustomerBenefitListRunning = true;
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                if (exit) {
                    return;
                }
                String methodName = "GetCustomerBenefitList";
                String endPoint = "ECard";
                JSONObject customerBenefitJsonParam = new JSONObject();
                try {
                    customerBenefitJsonParam.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    customerBenefitJsonParam.put("Type", 1);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerBenefitJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    String msg = "";
                    JSONArray customerBenefitArray = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        msg = resultJson.getString("Message");
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        try {
                            customerBenefitArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (customerBenefitArray != null) {
                            customerBenefitsList = new ArrayList<CustomerBenefit>();
                            CustomerBenefit defaultCustomerBenefit = new CustomerBenefit();
                            defaultCustomerBenefit.setBenefitID("");
                            defaultCustomerBenefit.setBenefitName("不使用券");
                            customerBenefitsList.add(defaultCustomerBenefit);
                            for (int i = 0; i < customerBenefitArray.length(); i++) {
                                CustomerBenefit cb = new CustomerBenefit();
                                JSONObject customerBenefitJson = null;
                                String benefitID = "";
                                String benefitName = "";
                                String benefitRule = "";
                                String prcode = "";
                                double prValue1 = 0;
                                double prValue2 = 0;
                                try {
                                    customerBenefitJson = customerBenefitArray.getJSONObject(i);
                                    if (!customerBenefitJson.isNull("BenefitID") && customerBenefitJson.has("BenefitID"))
                                        benefitID = customerBenefitJson.getString("BenefitID");
                                    //券名称
                                    if (!customerBenefitJson.isNull("PolicyName") && customerBenefitJson.has("PolicyName"))
                                        benefitName = customerBenefitJson.getString("PolicyName");
                                    //券规则内容
                                    if (!customerBenefitJson.isNull("PolicyDescription") && customerBenefitJson.has("PolicyDescription"))
                                        benefitRule = customerBenefitJson.getString("PolicyDescription");

                                    if (!customerBenefitJson.isNull("PRCode") && customerBenefitJson.has("PRCode"))
                                        prcode = customerBenefitJson.getString("PRCode");

                                    if (!customerBenefitJson.isNull("PRValue1") && customerBenefitJson.has("PRValue1"))
                                        prValue1 = customerBenefitJson.getDouble("PRValue1");

                                    if (!customerBenefitJson.isNull("PRValue2") && customerBenefitJson.has("PRValue2"))
                                        prValue2 = customerBenefitJson.getDouble("PRValue2");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                cb.setBenefitID(benefitID);
                                cb.setBenefitName(benefitName);
                                cb.setBenefitRule(benefitRule);
                                cb.setPrcode(prcode);
                                cb.setPrValue1(prValue1);
                                cb.setPrValue2(prValue2);
                                customerBenefitsList.add(cb);
                            }
                        }
                        List<CustomerBenefit> customerBenefits = new ArrayList<CustomerBenefit>();
                        for (CustomerBenefit cb : customerBenefitsList) {
                            if (TextUtils.isEmpty(cb.getBenefitID()) || cb.getPrValue1() <= prepareOrderPromotionPrice) {
                                customerBenefits.add(cb);
                            }
                        }
                        // 单件商品开单闪退对应(获取Ecard结束)
                        getCustomerBenefitListRunning = false;
                        Message message = new Message();
                        BenefitSpinnerBean bsb = new BenefitSpinnerBean();
                        bsb.setCustomerBenefitList(customerBenefits);
                        bsb.setPrepareOrderProductView(prepareOrderProductView);
                        message.obj = bsb;
                        message.what = 10;
                        message.arg1 = k;
                        mHandler.sendMessage(message);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message message = new Message();
                        message.what = 0;
                        message.obj = msg;
                        mHandler.sendMessage(message);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    private void initData() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        layoutInflater = LayoutInflater.from(this);
        prepareOrderCustomerText = (TextView) findViewById(R.id.prepare_order_customer_text);
        prepareOrderTitleText = (TextView) findViewById(R.id.prepare_order_detail_title_text);
        prepareOrderProductListView = (LinearLayout) findViewById(R.id.prepare_order_product_list);
        prepareOrderOldListView = (LinearLayout) findViewById(R.id.old_order_product_list);
        prepareOrderCommit = (Button) findViewById(R.id.prepare_order_commit);
        prepareOrderCommit.setOnClickListener(this);
        Intent intent = getIntent();
        fromSource = intent.getStringExtra("FROM_SOURCE");
        if (fromSource.equals("MENU")) {
            fromWhere = 1;
            selectedCustomerID = userinfoApplication.getSelectedCustomerID();
            prepareOrderCustomerText.setText(userinfoApplication.getSelectedCustomerName());
            if (userinfoApplication.getOrderInfo() != null) {
                orderProductList = userinfoApplication.getOrderInfo().getOrderProductList();
            }
            prepareOrderTitleText.setText(getResources().getString(R.string.prepare_order_detail_title_text));
        }
        if (fromSource.equals("Appointment")) {
            orderProductList = new ArrayList<OrderProduct>();
            AppointmentDetailInfo appointmentDetailInfo = (AppointmentDetailInfo) intent.getSerializableExtra("appointmentDetailInfo");
            OrderProduct order = new OrderProduct();
            order.setProductCode(appointmentDetailInfo.getProductCode());
            order.setProductType(intent.getIntExtra("ProductType", 0));
            taskID = intent.getLongExtra("TaskID", 0);
            order.setProductID(appointmentDetailInfo.getOrderInfo().getOrderID());
            order.setResponsiblePersonID(appointmentDetailInfo.getOrderInfo().getResponsiblePersonID());
            order.setResponsiblePersonName(appointmentDetailInfo.getOrderInfo().getResponsiblePersonName());
            userinfoApplication.setSelectedCustomerID(appointmentDetailInfo.getOrderInfo().getCustomerID());
            selectedCustomerID = userinfoApplication.getSelectedCustomerID();
            prepareOrderCustomerText.setText(appointmentDetailInfo.getOrderInfo().getCustomerName());
            prepareOrderTitleText.setText(getResources().getString(R.string.prepare_order_detail_title_text));
            orderProductList.add(order);
        }
    }

    protected void initView() {
        discountDialog = new AlertDialog.Builder(this).create();
        Intent intent = getIntent();
        final String fromSource = intent.getStringExtra("FROM_SOURCE");
        int accountIsAllowedOrderTotalSalePriceEdit = userinfoApplication.getAccountInfo().getAccountIsAllowedWriteOrderTotalSalePrice();
        if (orderProductList != null && orderProductList.size() != 0) {
            prepareOrderProductListView.removeAllViews();
            prepareOrderOldListView.removeAllViews();
            for (int i = 0; i < orderProductList.size(); i++) {
                final int orderProductPos = i;
                TableLayout.LayoutParams orderProductTableLP = new LayoutParams();
                orderProductTableLP.topMargin = 10;
                final OrderProduct orderProduct = orderProductList.get(i);
                if (orderProduct.isOldOrder()) {
                    OldOrderIdArray.put(orderProduct.getOldOrderID());
                    final View oldOrderProductView = layoutInflater.inflate(R.xml.old_order_product_list_item, null);
                    TableLayout orderOldTableLayout = (TableLayout) oldOrderProductView.findViewById(R.id.order_old_tablelayout);
                    orderOldTableLayout.setLayoutParams(orderProductTableLP);
                    ((TextView) oldOrderProductView.findViewById(R.id.prepare_order_product_name)).setText(orderProduct.getProductName());
                    String TotalCount = "无限";
                    if (orderProduct.getTotalCount() != 0) {
                        TotalCount = String.valueOf(orderProduct.getTotalCount());
                    }
                    ((TextView) oldOrderProductView.findViewById(R.id.completeOrtotal)).setText("完成" + orderProduct.getCompleteCount() + "次/共" + TotalCount + "次");
                    prepareOrderOldListView.addView(oldOrderProductView);
                } else {
                    final View prepareOrderProductView = layoutInflater.inflate(R.xml.prepare_order_product_list_item, null);
                    TableLayout orderProductTableLayout = (TableLayout) prepareOrderProductView.findViewById(R.id.order_product_tablelayout);
                    orderProductTableLayout.setLayoutParams(orderProductTableLP);
                    TextView prepareOrderProductNameText = (TextView) prepareOrderProductView.findViewById(R.id.prepare_order_product_name);
                    RelativeLayout prepareOrderResponsiblePersonRelativelayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_responsible_relativelayout);
                    TextView prepareOrderResponsiblePersonNameText = (TextView) prepareOrderProductView.findViewById(R.id.prepare_order_reaponsible_name);
                    // 数量
                    final EditText prepareOrderProductQuantityText = (EditText) prepareOrderProductView.findViewById(R.id.prepare_order_product_quantity);
                    final TextView prepareOrderProductTotalPriceText = (TextView) prepareOrderProductView.findViewById(R.id.prepare_order_product_total_price);
                    // 成交价 EditText
                    final EditText prepareOrderProductTotalSalePriceText = (EditText) prepareOrderProductView.findViewById(R.id.prepare_order_product_total_sale_price);
                    // 过去支付 EditText
                    final EditText prepareOrderProductHasPaidPriceText = (EditText) prepareOrderProductView.findViewById(R.id.prepare_order_product_has_paid_price);
                    final EditText prepareOrderProductPromotionPriceText = (EditText) prepareOrderProductView.findViewById(R.id.prepare_order_product_promotion_price);
                    // 过去完成次数
                    final EditText prepareOrderProductHasCompletenumText = (EditText) prepareOrderProductView.findViewById(R.id.prepare_order_product_has_completenum);
                    final ImageButton prepareOrderPlusProductHasQuantityButton = (ImageButton) prepareOrderProductView.findViewById(R.id.prepare_order_plus_has_quantity_btn);
                    ImageButton prepareOrderReduceProductHasQuantityButton = (ImageButton) prepareOrderProductView.findViewById(R.id.prepare_order_reduce_has_quantity_btn);
                    ImageButton prepareOrderPlusProductQuantityButton = (ImageButton) prepareOrderProductView.findViewById(R.id.prepare_order_plus_quantity_btn);
                    ImageButton prepareOrderReduceProductQuantityButton = (ImageButton) prepareOrderProductView.findViewById(R.id.prepare_order_reduce_quantity_btn);
                    ImageButton prepareOrderServicePlusProductQuantityButton = (ImageButton) prepareOrderProductView.findViewById(R.id.prepare_order_service_plus_quantity_btn);
                    ImageButton prepareOrderServiceReduceProductQuantityButton = (ImageButton) prepareOrderProductView.findViewById(R.id.prepare_order_service_reduce_quantity_btn);
                    // 服务次数
                    final EditText prepareOrderServiceProductQuantityText = (EditText) prepareOrderProductView.findViewById(R.id.prepare_order_service_quantity);
                    // 不限次
                    TextView prepareOrderServiceQuantityZero = (TextView) prepareOrderProductView.findViewById(R.id.prepare_order_service_quantity_zero);
                    final RelativeLayout orderProductPromotionPriceRelativeLayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_promotion_price_relativelayout);
                    // 过去支付 Layout
                    final RelativeLayout orderProductHadPaidPriceRelativeLayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_has_paid_price_relativelayout);
                    final RelativeLayout orderProductHadCompleteNumRelativeLayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_has_completenum_relativelayout);
                    // 成交价 Layout
                    final RelativeLayout orderProductHadDiscussRelativeLayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_total_discuss_relativelayout);
                    final RelativeLayout prepareOrderQuantityRelativelayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_quantity_relativelayout);
                    View prepareOrderServiceQuantityDivideView = prepareOrderProductView.findViewById(R.id.prepare_order_service_quantity_divide_view);
                    //优惠券选项
                    View prepareOrderBenefitDivideView = prepareOrderProductView.findViewById(R.id.prepare_order_product_benfit_divide_view);
                    RelativeLayout prepareOrderBenefitRelativelayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_benfit_relativelayout);
                    if (orderProduct.getProductType() == 0) {
                        prepareOrderQuantityRelativelayout.setVisibility(View.VISIBLE);
                        prepareOrderServiceQuantityDivideView.setVisibility(View.VISIBLE);
                    } else {
                        prepareOrderServiceQuantityDivideView.setVisibility(View.GONE);
                        prepareOrderQuantityRelativelayout.setVisibility(View.GONE);
                    }
                    orderProductCardSpinnerRelativeLayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_total_spinner_relativelayout);
                    prepareOrderProductTotalSpinnerView = prepareOrderProductView.findViewById(R.id.prepare_order_product_total_spinner_view);
                    ((TextView) prepareOrderProductView.findViewById(R.id.prepare_order_product_total_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
                    ((TextView) prepareOrderProductView.findViewById(R.id.prepare_order_product_promotion_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
                    ((TextView) prepareOrderProductView.findViewById(R.id.prepare_order_product_total_sale_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
                    ((TextView) prepareOrderProductView.findViewById(R.id.prepare_order_product_has_paid_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
                    final View orderProductHasPaidPriceDivideView = prepareOrderProductView.findViewById(R.id.prepare_order_product_has_paid_price_divide_view);
                    final View orderProductTotalSalePrice1DivideView = prepareOrderProductView.findViewById(R.id.prepare_order_product_total_sale_price1_divide_view);
                    prepareOrderProductPromotionPriceText.setEnabled(false);
                    prepareOrderProductHasCompletenumText.setText(String.valueOf(0));
                    prepareOrderProductHasPaidPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    //折扣卡列表
                    final Spinner addCardSpinner = (Spinner) prepareOrderProductView.findViewById(R.id.add_opportunity_confirm_step_template_spinner);

                    discountInfo(orderProductList.get(i).getProductCode(), orderProductList.get(i).getProductType(), addCardSpinner, prepareOrderProductPromotionPriceText, i, prepareOrderProductTotalSalePriceText);
                    //如果只有一个订单时，则获取券列表
                    if (orderProductList.size() == 1) {
                        prepareOrderBenefitDivideView.setVisibility(View.VISIBLE);
                        prepareOrderBenefitRelativelayout.setVisibility(View.VISIBLE);
                        //获取券列表
                        getCustomerBenefitListData(prepareOrderProductView, orderProductPos, Double.valueOf(orderProductList.get(i).getPromotionPrice()));
                    }
                    //隐藏选优惠券的功能
                    else {
                        prepareOrderBenefitDivideView.setVisibility(View.GONE);
                        prepareOrderBenefitRelativelayout.setVisibility(View.GONE);
                    }
                    // 服务有效期
                    View serviceOrderExpirationDateDivideView = prepareOrderProductView.findViewById(R.id.service_order_expiration_date_divide_view);
                    RelativeLayout serviceOrderExpirationDateRelativeLayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.service_order_expiration_date_relativelayout);
                    ImageButton serviceOrderExpirationBtn = (ImageButton) prepareOrderProductView.findViewById(R.id.service_order_expiration_date_btn);
                    //订单的每个服务或者商品是否已经支付过
                    RelativeLayout hasPaidRelativelayout = (RelativeLayout) prepareOrderProductView.findViewById(R.id.prepare_order_product_has_paid_relativelayout);
                    View prepareOrderProductHasPaidRelativeLayoutDivideView = prepareOrderProductView.findViewById(R.id.prepare_order_product_has_paid_relativelayout_divide_view);
                    if (orderProduct.getProductType() == 0) {
                        hasPaidRelativelayout.setVisibility(View.VISIBLE);
                        prepareOrderProductHasPaidRelativeLayoutDivideView.setVisibility(View.VISIBLE);
                        hasPaidRelativelayout.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                ImageView prepareOrderProductHasPaidIcon = (ImageView) view.findViewById(R.id.prepare_order_product_has_paid_icon);
                                //如果当前的商品或者服务是老订单转入
                                if (orderProduct.isPast()) {
                                    prepareOrderProductHasPaidIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
                                    orderProduct.setPast(false);
                                    //隐藏输入已支付过金额的控件
                                    orderProductHasPaidPriceDivideView.setVisibility(View.GONE);
                                    orderProductHadPaidPriceRelativeLayout.setVisibility(View.GONE);
                                    orderProductHadCompleteNumRelativeLayout.setVisibility(View.GONE);
                                } else if (!orderProduct.isPast()) {
                                    prepareOrderProductHasPaidIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
                                    orderProduct.setPast(true);
                                    if (orderProduct.getProductType() == 0) {
                                        // 填写转入订单的过去支付金额
                                        int authPastPayment = userinfoApplication.getAccountInfo().getAuthPastPayment();
                                        if (authPastPayment == 1) {
                                            orderProductHasPaidPriceDivideView.setVisibility(View.VISIBLE);
                                            orderProductHadPaidPriceRelativeLayout.setVisibility(View.VISIBLE);
                                        }
                                        // 隐藏订单的过去支付金额
                                        else {
                                            orderProductHasPaidPriceDivideView.setVisibility(View.GONE);
                                            orderProductHadPaidPriceRelativeLayout.setVisibility(View.GONE);
                                        }
                                        //填写转入订单的过去完成次数
                                        int authPastFinished = userinfoApplication.getAccountInfo().getAuthPastFinished();
                                        if (authPastFinished == 1) {
                                            orderProductHadCompleteNumRelativeLayout.setVisibility(View.VISIBLE);
                                        }
                                        //隐藏转入订单的过去完成次数
                                        else {
                                            orderProductHadCompleteNumRelativeLayout.setVisibility(View.GONE);
                                        }
                                    }
                                }
                            }
                        });
                    } else {
                        hasPaidRelativelayout.setVisibility(View.GONE);
                        prepareOrderProductHasPaidRelativeLayoutDivideView.setVisibility(View.GONE);
                        orderProductHasPaidPriceDivideView.setVisibility(View.GONE);
                        orderProductTotalSalePrice1DivideView.setVisibility(View.GONE);
                    }

                    if (orderProduct.getProductType() == Constant.SERVICE_ORDER) {
                        serviceOrderExpirationDateDivideView.setVisibility(View.VISIBLE);
                        serviceOrderExpirationDateRelativeLayout.setVisibility(View.VISIBLE);
                        final EditText serviceOrderExpirationDateText = (EditText) prepareOrderProductView.findViewById(R.id.service_order_expiration_date_text);
                        serviceOrderExpirationDateText.setInputType(InputType.TYPE_NULL);
                        // 更换订单的服务有效期
                        serviceOrderExpirationDateRelativeLayout.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                // TODO Auto-generated method stub
                                DateButton dateButton = new DateButton(PrepareOrderActivity.this, serviceOrderExpirationDateText, Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION, null);
                                dateButton.datePickerDialog();
                            }
                        });
                        serviceOrderExpirationBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                // TODO Auto-generated method stub
                                DateButton dateButton = new DateButton(PrepareOrderActivity.this, serviceOrderExpirationDateText, Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION, null);
                                dateButton.datePickerDialog();
                            }
                        });
                        serviceOrderExpirationDateText.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                // TODO Auto-generated method stub
                                DateButton dateButton = new DateButton(PrepareOrderActivity.this, serviceOrderExpirationDateText, Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION, null);
                                dateButton.datePickerDialog();
                            }
                        });

                        String serviceOrderExpirationDate = orderProduct.getServiceOrderExpirationDate();
                        if (serviceOrderExpirationDate != null && !("").equals(serviceOrderExpirationDate))
                            serviceOrderExpirationDateText.setText(DateUtil.getFormateDateByString(orderProduct.getServiceOrderExpirationDate()));
                        else {
                            serviceOrderExpirationDateText.setText("2099-12-31");
                        }
                    }

                    prepareOrderProductNameText.setText(orderProduct.getProductName());
                    // 禁止长按黏贴
                    prepareOrderProductQuantityText.setLongClickable(false);
                    prepareOrderProductQuantityText.setText(String.valueOf(orderProduct.getQuantity()));
                    orderQuantity = orderProduct.getQuantity();
                    prepareOrderServiceProductQuantityText.setLongClickable(false);
                    if (orderProduct.getCourseFrequency() < 1) {
                        prepareOrderServiceQuantityZero.setVisibility(View.VISIBLE);
                        prepareOrderServiceProductQuantityText.setVisibility(View.GONE);
                        prepareOrderServiceReduceProductQuantityButton.setVisibility(View.GONE);
                        prepareOrderServicePlusProductQuantityButton.setVisibility(View.GONE);
                    } else {
                        prepareOrderServiceQuantityZero.setVisibility(View.GONE);
                        prepareOrderServiceProductQuantityText.setVisibility(View.VISIBLE);
                        prepareOrderServiceProductQuantityText.setText(String.valueOf(orderProduct.getCourseFrequency()));
                        prepareOrderServiceReduceProductQuantityButton.setVisibility(View.VISIBLE);
                        prepareOrderServicePlusProductQuantityButton.setVisibility(View.VISIBLE);
                    }

                    prepareOrderProductTotalPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getTotalPrice()) * orderProduct.getQuantity())));
                    prepareOrderResponsiblePersonNameText.setText(orderProduct.getResponsiblePersonName());

                    // 开单更换美丽顾问
                    prepareOrderResponsiblePersonRelativelayout.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            // TODO Auto-generated method stub
                            operationIndex = orderProductPos;
                            Intent intent = new Intent(PrepareOrderActivity.this, ChoosePersonActivity.class);
                            intent.putExtra("personRole", "Doctor");
                            intent.putExtra("checkModel", "Single");
                            JSONArray responsiblePersonArray = new JSONArray();
                            responsiblePersonArray.put(orderProduct.getResponsiblePersonID());
                            intent.putExtra("selectPersonIDs", responsiblePersonArray.toString());
                            intent.putExtra("customerID", userinfoApplication.getSelectedCustomerID());
                            startActivityForResult(intent, 300);
                        }
                    });
                    orderProductPromotionPriceRelativeLayout.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (orderProductHadDiscussRelativeLayout.getVisibility() == View.GONE) {
                                orderProductTotalSalePrice1DivideView.setVisibility(View.VISIBLE);
                                orderProductHadDiscussRelativeLayout.setVisibility(View.VISIBLE);
                            } else {
                                orderProductHadDiscussRelativeLayout.setVisibility(View.GONE);
                                orderProductTotalSalePrice1DivideView.setVisibility(View.GONE);
                            }
                        }
                    });
                    if (fromSource.equals("OPPORTUNITY")) {
                        if (Double.valueOf(orderProduct.getTotalSalePrice()) != Double.valueOf(orderProduct.getUnitPrice())) {
                            prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getTotalSalePrice()))));
                        } else {
                            prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getTotalPrice()))));
                        }
                    } else {

                    }
                    //订单B价格
                    prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getPromotionPrice()))));
                    prepareOrderProductPromotionPriceText.addTextChangedListener(new TextWatcher() {

                        @Override
                        public void onTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {
                            // TODO Auto-generated method stub

                        }

                        @Override
                        public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
                                                      int arg3) {
                            // TODO Auto-generated method stub

                        }

                        @Override
                        public void afterTextChanged(Editable arg0) {
                            // TODO Auto-generated method stub
                            if (orderProductList.size() == 1) {
                                // 单件商品开单闪退对应(等待获取优惠券信息)
                                while (getCustomerBenefitListRunning) {
                                    Log.v("PrepareOrderActivity", "等待获取优惠券信息...");
                                    try {
                                        Thread.sleep(200);
                                    } catch (InterruptedException e) {
                                        e.printStackTrace();
                                    }
                                }
                                Log.v("PrepareOrderActivity", "获取优惠券信息成功");
                                List<CustomerBenefit> customerBenefits = new ArrayList<CustomerBenefit>();
                                for (CustomerBenefit cb : customerBenefitsList) {
                                    if (TextUtils.isEmpty(cb.getBenefitID()) || cb.getPrValue1() <= Double.valueOf(((EditText) prepareOrderProductListView.getChildAt(orderProductPos).findViewById(R.id.prepare_order_product_promotion_price)).getText().toString())) {
                                        customerBenefits.add(cb);
                                    }
                                }
                                Message message = new Message();
                                BenefitSpinnerBean bsb = new BenefitSpinnerBean();
                                bsb.setCustomerBenefitList(customerBenefits);
                                bsb.setPrepareOrderProductView(prepareOrderProductView);
                                message.obj = bsb;
                                message.what = 10;
                                message.arg1 = orderProductPos;
                                mHandler.sendMessage(message);
                            }
                        }
                    });
                    prepareOrderProductTotalSalePriceText.setText(prepareOrderProductPromotionPriceText.getText().toString());
                    if (accountIsAllowedOrderTotalSalePriceEdit == 0) {
                        prepareOrderProductTotalSalePriceText.setEnabled(false);
                    } else {
                        prepareOrderProductTotalSalePriceText.addTextChangedListener(new TextWatcher() {
                            @Override
                            public void onTextChanged(CharSequence s,
                                                      int start, int before, int count) {

                            }

                            @Override
                            public void beforeTextChanged(CharSequence s,
                                                          int start, int count, int after) {
                            }

                            @Override
                            public void afterTextChanged(Editable s) {
                                if (s == null || (s.toString()).length() < 1 || s.toString().trim().equals("") || s.toString().trim().equals(".")) {
                                    prepareOrderProductTotalSalePriceText.setText("0.00");
                                }
                                double orderProductPromotionTotalSalePrice = 0;
                                int k = 0;
                                for (int i = 0; i < orderProductList.size(); i++) {
                                    if (!orderProductList.get(i).isOldOrder()) {
                                        double orderProductTotalSalePrice = 0;
                                        EditText editText = (EditText) prepareOrderProductListView.getChildAt(k).findViewById(R.id.prepare_order_product_total_sale_price);
                                        try {
                                            orderProductTotalSalePrice = Double.parseDouble((editText.getText().toString()));
                                        } catch (NumberFormatException e) {
                                            orderProductTotalSalePrice = 0;
                                            editText.setText("0.00");
                                        }
                                        orderProductList.get(i).setTotalSalePrice(String.valueOf(orderProductTotalSalePrice / orderProductList.get(k).getQuantity()));
                                        orderProductPromotionTotalSalePrice += orderProductTotalSalePrice;
                                        k++;
                                    }

                                }
                                prepareOrderTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderProductPromotionTotalSalePrice)));
									/*}else {
										double orderProductPromotionTotalSalePrice = 0;
										int j=0;
										for (int i = 0; i < orderProductList
												.size(); i++) {
											if(!orderProductList.get(i).isOldOrder()){
											double orderProductTotalSalePrice = 0;
											if (orderProductPos != i) {
												try {
													orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_sale_price)).getText().toString()));
												} catch (NumberFormatException e) {
													orderProductTotalSalePrice = 0;
												}
											} else {
												try {
													orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_sale_price)).getText().toString()));
												} catch (NumberFormatException e) {
													orderProductTotalSalePrice = 0;
												}
											}
											orderProductList.get(i).setTotalSalePrice(String.valueOf(orderProductTotalSalePrice/orderProductList.get(i).getQuantity()));
											orderProductPromotionTotalSalePrice += orderProductTotalSalePrice;
										  j++;
										 }
										}
										prepareOrderTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderProductPromotionTotalSalePrice)));
									}*/
                            }
                        });
                    }
                    prepareOrderProductHasPaidPriceText.addTextChangedListener(new TextWatcher() {
                        @Override
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                            if ((prepareOrderProductHasPaidPriceText.getText().toString()).length() < 1) {
                                prepareOrderProductHasPaidPriceText.setText("0.00");
                            }
                        }

                        @Override
                        public void beforeTextChanged(CharSequence s, int start, int count,
                                                      int after) {
                        }

                        @Override
                        public void afterTextChanged(Editable s) {
                            // TODO Auto-generated method stub
                            if (s != null && !s.toString().trim().equals("") && !s.toString().trim().equals(".")) {
                                String orderProductPromotionPriceInput = prepareOrderProductTotalSalePriceText.getText().toString();
                                if (orderProductPromotionPriceInput == null || orderProductPromotionPriceInput.equals("")) {
                                    //监听输入的过去支付金额不能大于商品或者服务的成交价
                                    if (orderProduct.getMarketingPolicy() == 1 || orderProduct.getMarketingPolicy() == 2) {
                                        if (NumberFormatUtil.doubleCompare(Double.valueOf(s.toString()), Double.valueOf(orderProduct.getPromotionPrice())) > 0) {
                                            DialogUtil.createShortDialog(getApplicationContext(), "过去支付金额不能大于服务/商品的价格");
                                            prepareOrderProductHasPaidPriceText.setText("0.00");
                                            prepareOrderProductHasPaidPriceText.selectAll();
                                        }
                                    } else {
                                        if (NumberFormatUtil.doubleCompare(Double.valueOf(s.toString()), Double.valueOf(orderProduct.getUnitPrice())) > 0) {
                                            DialogUtil.createShortDialog(getApplicationContext(), "过去支付金额不能大于服务/商品的价格");
                                            prepareOrderProductHasPaidPriceText.setText("0.00");
                                            prepareOrderProductHasPaidPriceText.selectAll();
                                        }
                                    }
                                } else {
                                    if (NumberFormatUtil.doubleCompare(Double.valueOf(s.toString()), Double.valueOf(orderProductPromotionPriceInput)) > 0) {
                                        DialogUtil.createShortDialog(getApplicationContext(), "过去支付金额不能大于服务/商品的价格");
                                        prepareOrderProductHasPaidPriceText.setText("0.00");
                                        prepareOrderProductHasPaidPriceText.selectAll();
                                    }
                                }
                            } else {
                                prepareOrderProductHasPaidPriceText.setText("0.00");
                                prepareOrderProductHasPaidPriceText.selectAll();
                            }
                        }
                    });
                    prepareOrderProductListView.addView(prepareOrderProductView);
                    // 增加过去完成次数
                    prepareOrderPlusProductHasQuantityButton.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            int quantity = Integer.parseInt(prepareOrderProductHasCompletenumText.getText().toString());
                            if (orderProduct.getCourseFrequency() < 1) {
                                prepareOrderProductHasCompletenumText.setText(String.valueOf(quantity + 1));
                            } else {
                                int serviceQuantity = Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString());
                                if (quantity < serviceQuantity) {
                                    prepareOrderProductHasCompletenumText.setText(String.valueOf(quantity + 1));
                                } else {
                                    DialogUtil.createShortDialog(PrepareOrderActivity.this, "过去完成次数不能大于服务次数");
                                }
                            }
                        }
                    });
                    prepareOrderReduceProductHasQuantityButton.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            // TODO Auto-generated method stub
                            int quantity = Integer.parseInt(prepareOrderProductHasCompletenumText.getText().toString());
                            if (quantity > 0) {
                                prepareOrderProductHasCompletenumText.setText(String.valueOf(quantity - 1));
                            } else {
                                prepareOrderProductHasCompletenumText.setText(String.valueOf(0));
                                DialogUtil.createShortDialog(PrepareOrderActivity.this, "过去完成次数不能小于0！");
                            }
                        }
                    });
                    prepareOrderProductHasCompletenumText.addTextChangedListener(new TextWatcher() {
                        @Override
                        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                        }

                        @Override
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                            if ((prepareOrderProductHasCompletenumText.getText().toString()).length() < 1) {
                                prepareOrderProductHasCompletenumText.setText("0");
                            }
                        }

                        @Override
                        public void afterTextChanged(Editable s) {
                            if (s != null && !s.toString().trim().equals("")) {
                                if (orderProduct.getCourseFrequency() < 1) {
                                    // 不限次
                                } else {
                                    // 限次
                                    int serviceQuantity = Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString());
                                    int quantity = Integer.parseInt(s.toString());
                                    if (quantity > serviceQuantity) {
                                        DialogUtil.createShortDialog(PrepareOrderActivity.this, "过去完成次数不能大于服务次数");
                                        prepareOrderProductHasCompletenumText.setText(prepareOrderServiceProductQuantityText.getText());
                                        prepareOrderProductHasCompletenumText.selectAll();
                                    }
                                }
                            } else {
                                prepareOrderProductHasCompletenumText.setText("0");
                                prepareOrderProductHasCompletenumText.selectAll();
                            }
                        }
                    });
                    // 手动修改过去次数edit
                    /*prepareOrderProductHasCompletenumText.addTextChangedListener(new TextWatcher() {

                        @Override
                        public void beforeTextChanged(CharSequence s, int start,
                                                      int count, int after) {

                        }

                        @Override
                        public void onTextChanged(CharSequence s, int start,
                                                  int before, int count) {
                            if ((prepareOrderProductHasCompletenumText.getText().toString()).length() < 1) {
                                prepareOrderProductHasCompletenumText.setText("0");
                            }
                        }

                        @Override
                        public void afterTextChanged(Editable s) {

                        }

                    });*/
                    // 增加服务次数按钮
                    prepareOrderServicePlusProductQuantityButton.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            int serviceQuantity = Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString());
                            prepareOrderServiceProductQuantityText.setText(String.valueOf(serviceQuantity + 1));
                        }
                    });
                    prepareOrderServiceReduceProductQuantityButton.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            int serviceQuantity = Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString());
                            if (serviceQuantity > 1) {
                                prepareOrderServiceProductQuantityText.setText(String.valueOf(serviceQuantity - 1));
                            } else {
                                prepareOrderServiceProductQuantityText.setText(String.valueOf(1));
                                DialogUtil.createShortDialog(PrepareOrderActivity.this, "服务次数不能小于1！");
                            }
                        }
                    });
                    // 手动修改服务次数edit
                    prepareOrderServiceProductQuantityText
                            .addTextChangedListener(new TextWatcher() {
                                @Override
                                public void onTextChanged(CharSequence s, int start, int before, int count) {
                                    if ((prepareOrderServiceProductQuantityText.getText().toString()).length() < 1 || Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString()) < 1) {
                                        prepareOrderServiceProductQuantityText.setText("1");
                                    }
                                    int servoceQuantity = 1;
                                    try {
                                        servoceQuantity = Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString());
                                        //orderProductList.get(orderProductPos).setQuantity(servoceQuantity);
                                    } catch (NumberFormatException e1) {
                                        servoceQuantity = 1;
                                        prepareOrderServiceProductQuantityText.setText("1");
                                    }
                                }

                                @Override
                                public void beforeTextChanged(CharSequence s,
                                                              int start, int count, int after) {
                                }

                                @Override
                                public void afterTextChanged(Editable s) {
                                    int prepareOrderServiceProductQuantity = Integer.parseInt(prepareOrderServiceProductQuantityText.getText().toString());
                                    int prepareOrderProductHasCompletenum = Integer.parseInt(prepareOrderProductHasCompletenumText.getText().toString());
                                    if (prepareOrderProductHasCompletenum > prepareOrderServiceProductQuantity) {
                                        prepareOrderProductHasCompletenumText.setText(prepareOrderServiceProductQuantityText.getText());
                                    }
                                }
                            });

                    // 增加服务或者商品的数量按钮
                    prepareOrderPlusProductQuantityButton.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            int quantity = Integer.parseInt(prepareOrderProductQuantityText.getText().toString());
                            orderQuantity = quantity;
                            prepareOrderProductQuantityText.setText(String.valueOf(quantity + 1));
                        }
                    });
                    prepareOrderReduceProductQuantityButton.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            // TODO Auto-generated method stub
                            int quantity = Integer.parseInt(prepareOrderProductQuantityText.getText().toString());
                            orderQuantity = quantity;
                            if (quantity > 1) {
                                prepareOrderProductQuantityText.setText(String.valueOf(quantity - 1));
                            } else {
                                prepareOrderProductQuantityText.setText(String.valueOf(0));
                            }
                        }
                    });
					/*prepareOrderProductTotalSalePriceText.addTextChangedListener(new TextWatcher() {

						@Override
						public void beforeTextChanged(CharSequence s, int start,
													  int count, int after) {

						}

						@Override
						public void onTextChanged(CharSequence s, int start,int before, int count) {
							if((prepareOrderProductTotalSalePriceText.getText().toString()).length()<1){
								prepareOrderProductTotalSalePriceText.setText("0");
							}
						}

						@Override
						public void afterTextChanged(Editable s) {

						}

					});*/
                    // 手动修改商品或者服务的数量
                    prepareOrderProductQuantityText
                            .addTextChangedListener(new TextWatcher() {
                                @Override
                                public void onTextChanged(CharSequence s,
                                                          int start, int before, int count) {
                                    if ((prepareOrderProductQuantityText.getText().toString()).length() < 1) {
                                        prepareOrderProductQuantityText.setText("1");
                                    }
                                    // TODO Auto-generated method stub
                                    int orderType = orderProduct.getProductType();
                                    Editable editable = prepareOrderProductQuantityText.getText();
                                    int len = editable.length();
                                    int maxLength = 0;
                                    // 服务订单数量最大为两位 商品订单最大为四位
                                    if (orderType == Constant.SERVICE_ORDER)
                                        maxLength = 2;
                                    else if (orderType == Constant.COMMODITY_ORDER)
                                        maxLength = 4;
                                    String newStr = "";
                                    if (len > maxLength) {
                                        int selEndIndex = Selection.getSelectionEnd(editable);
                                        String str = editable.toString();
                                        // 截取新字符串
                                        newStr = str.substring(0, maxLength);
                                        prepareOrderProductQuantityText.setText(newStr);
                                        editable = prepareOrderProductQuantityText.getText();
                                        // 新字符串的长度
                                        int newLen = editable.length();
                                        // 旧光标位置超过字符串长度
                                        if (selEndIndex > newLen) {
                                            selEndIndex = editable.length();
                                        }
                                        // 设置新光标所在的位置
                                        Selection.setSelection(editable, selEndIndex);
                                    } else {
                                        newStr = prepareOrderProductQuantityText.getText().toString();
                                    }
                                    boolean isError = false;
                                    int quantity = 0;
                                    try {
                                        quantity = Integer.parseInt(newStr);
                                        orderProductList.get(orderProductPos).setQuantity(quantity);
                                    } catch (NumberFormatException e1) {
                                        isError = true;
                                    }
                                    // 输入正常的值
                                    if (!isError) {
                                        if (quantity >= 1) {
                                            if (orderQuantity > 0) {
                                                prepareOrderProductTotalPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getUnitPrice()) * quantity)));
                                                prepareOrderServiceProductQuantityText.setText(String.valueOf(quantity * orderProductList.get(orderProductPos).getCourseFrequency()));
                                                prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf((Double.valueOf(orderProduct.getPromotionPrice()) * quantity))));

                                                if (prepareOrderProductTotalSalePriceText.getText().toString() != null && !(("").equals(prepareOrderProductTotalSalePriceText.getText().toString()))) {
                                                    Log.e("oldorderQuantity->orderQuantity==OrderTotalSalePriceText", orderQuantity + "->" + quantity + "==" + prepareOrderProductTotalSalePriceText.getText());
                                                    prepareOrderProductTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(((Double.valueOf(prepareOrderProductTotalSalePriceText.getText().toString()) / orderQuantity) * quantity))));
                                                } else {
                                                    prepareOrderProductTotalSalePriceText.setText("0");
                                                }
                                                double orderProductPromotionTotalSalePrice = 0;
                                                double orderTotalPrice = 0;
                                                int j = 0;
                                                for (int i = 0; i < orderProductList.size(); i++) {
                                                    if (!orderProductList.get(i).isOldOrder()) {
                                                        double orderProductTotalSalePrice = 0;
                                                        double orderProductTotalPrice = 0;
                                                        try {
                                                            orderProductTotalSalePrice = Double.parseDouble((((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_sale_price)).getText().toString()));
                                                            orderProductTotalPrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_price)).getText().toString()));
                                                        } catch (NumberFormatException e) {
                                                            orderProductTotalPrice = 0;
                                                            orderProductTotalSalePrice = 0;
                                                        }
                                                        orderProductPromotionTotalSalePrice += orderProductTotalSalePrice;
                                                        orderTotalPrice += orderProductTotalPrice;
                                                        j++;
                                                    }
                                                }
                                                prepareOrderTotalPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderTotalPrice)));
                                                prepareOrderTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderProductPromotionTotalSalePrice)));
                                            }
                                        } else {
                                            //提示是否删除前 恢复该订单的原价  优惠价 及成交价
                                            prepareOrderProductTotalPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getUnitPrice()) * 1)));
                                            prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf((Double.valueOf(orderProduct.getPromotionPrice()) * 1))));
                                            prepareOrderProductTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf((Double.valueOf(orderProduct.getPromotionPrice()) * 1))));
                                            Dialog dialog = new AlertDialog.Builder(PrepareOrderActivity.this, R.style.CustomerAlertDialog)
                                                    .setTitle(getString(R.string.delete_dialog_title))
                                                    .setMessage(R.string.delete_service_or_commodity)
                                                    .setPositiveButton(getString(R.string.delete_confirm),
                                                            new DialogInterface.OnClickListener() {
                                                                @Override
                                                                public void onClick(DialogInterface dialog, int which) {
                                                                    // 如果商品或者服务数量为1的话,直接删除掉
                                                                    // 将视图删除掉
                                                                    // 刷新全局变量中的服务商品
                                                                    prepareOrderProductListView.removeView(prepareOrderProductView);
                                                                    // 将服务或者商品从当前变量中删除
                                                                    Iterator<OrderProduct> iterator = orderProductList.iterator();
                                                                    while (iterator.hasNext()) {
                                                                        OrderProduct op = iterator.next();
                                                                        int productID = op.getProductID();
                                                                        if (productID == orderProduct.getProductID()) {
                                                                            iterator.remove();
                                                                            break;
                                                                        }
                                                                    }
                                                                    if (fromSource.equals("MENU")) {
                                                                        Iterator<OrderProduct> menuOrderProductiterator = userinfoApplication.getOrderInfo().getOrderProductList().iterator();
                                                                        while (menuOrderProductiterator.hasNext()) {
                                                                            OrderProduct op = menuOrderProductiterator.next();
                                                                            int productID = op.getProductID();
                                                                            if (productID == orderProduct.getProductID()) {
                                                                                iterator.remove();
                                                                                break;
                                                                            }
                                                                        }
                                                                    }
                                                                    if (orderProductList.size() == 1) {
                                                                        prepareOrderTotalCountTableLayout.setVisibility(View.GONE);
                                                                    } else {
                                                                        double orderProductPromotionTotalSalePrice = 0;
                                                                        double orderTotalPrice = 0;
                                                                        int j = 0;
                                                                        for (int i = 0; i < orderProductList
                                                                                .size(); i++) {
                                                                            if (!orderProductList.get(i).isOldOrder()) {
                                                                                double orderProductTotalSalePrice = 0;
                                                                                double orderProductTotalPrice = 0;
                                                                                try {
                                                                                    orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_sale_price)).getText().toString()));
                                                                                    orderProductTotalPrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_price)).getText().toString()));
                                                                                } catch (NumberFormatException e) {
                                                                                    orderProductTotalSalePrice = 0;
                                                                                }
                                                                                orderProductPromotionTotalSalePrice += orderProductTotalSalePrice;
                                                                                orderTotalPrice += orderProductTotalPrice;
                                                                                j++;
                                                                            }
                                                                        }
                                                                        prepareOrderTotalPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderTotalPrice)));
                                                                        prepareOrderTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderProductPromotionTotalSalePrice)));
                                                                    }
                                                                    initView();
                                                                    BusinessRightMenu.createMenuContent();
                                                                    BusinessRightMenu.rightMenuAdapter.notifyDataSetChanged();
                                                                }
                                                            })
                                                    .setNegativeButton(getString(R.string.delete_cancel),
                                                            new DialogInterface.OnClickListener() {
                                                                @Override
                                                                public void onClick(DialogInterface dialog, int which) {
                                                                    prepareOrderProductQuantityText.setText(String.valueOf(1));
                                                                    dialog.dismiss();
                                                                    dialog = null;
                                                                }
                                                            }).create();
                                            dialog.show();
                                            dialog.setCancelable(false);
                                        }
                                    }
                                }

                                @Override
                                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                                    orderQuantity = orderProductList.get(orderProductPos).getQuantity();
                                }

                                @Override
                                public void afterTextChanged(Editable s) {
                                    orderQuantity = orderProductList.get(orderProductPos).getQuantity();
                                }
                            });
                    orderProductList.get(i).setPromotionPrice(prepareOrderProductTotalSalePriceText.getText().toString());
                }
            }
        }
        prepareOrderTotalCountTableLayout = (TableLayout) findViewById(R.id.prepare_order_total_count_table_layout);
        prepareOrderTotalPriceText = (TextView) findViewById(R.id.prepare_order_total_price);
        prepareOrderTotalSalePriceText = (TextView) findViewById(R.id.prepare_order_total_sale_price);
        if (orderProductList != null && orderProductList.size() != 0) {
            if (orderProductList.size() <= 1)
                prepareOrderTotalCountTableLayout.setVisibility(View.GONE);
            else {
                prepareOrderTotalCountTableLayout.setVisibility(View.VISIBLE);
                ((TextView) findViewById(R.id.prepare_order_total_price_currency))
                        .setText(userinfoApplication.getAccountInfo()
                                .getCurrency());
                ((TextView) findViewById(R.id.prepare_order_total_sale_price_currency))
                        .setText(userinfoApplication.getAccountInfo().getCurrency());
            }
        }
        double prepareTotalPrice = 0;
        double prepareTotalSalePrice = 0;
        if (orderProductList != null && orderProductList.size() != 0) {
            for (OrderProduct orderProduct : orderProductList) {
                if (!orderProduct.isOldOrder()) {
                    int marketingPolicy = orderProduct.getMarketingPolicy();
                    prepareTotalPrice += (Double.parseDouble(orderProduct.getUnitPrice())) * orderProduct.getQuantity();
                    if (marketingPolicy == 1 || marketingPolicy == 2) {
                        prepareTotalSalePrice += Double.parseDouble(orderProduct.getPromotionPrice()) * orderProduct.getQuantity();
                    } else if (marketingPolicy == 0) {
                        prepareTotalSalePrice += (Double.parseDouble(orderProduct.getUnitPrice())) * orderProduct.getQuantity();
                    }
                }
            }
        }
        prepareOrderTotalPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(prepareTotalPrice))));
        prepareOrderTotalSalePriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(prepareTotalSalePrice))));
        // 开单闪退对应(PrepareOrderActivity初期化结束)
        if (progressDialog2 != null) {
            progressDialog2.dismiss();
            progressDialog2 = null;
        }
    }

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            case R.id.treatment_update:
                break;
            // 下单
            case R.id.prepare_order_commit:
                boolean isPaidPriceCorrect = true;
                int k = 0;
                for (int j = 0; j < orderProductList.size(); j++) {
                    OrderProduct op = orderProductList.get(j);
                    String hasPaidPriceString = null;
                    if (!op.isOldOrder()) {
                        hasPaidPriceString = ((TextView) prepareOrderProductListView.getChildAt(k).findViewById(R.id.prepare_order_product_has_paid_price)).getText().toString();
                        k++;
                    }
                    if (op.isPast()) {
                        if (hasPaidPriceString != null && !hasPaidPriceString.equals("")) {
                            String orderProductPromotionPriceInput = ((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_promotion_price)).getText().toString();
                            if (orderProductPromotionPriceInput == null || orderProductPromotionPriceInput.equals("")) {
                                //监听输入的过去支付金额不能大于商品或者服务的成交价
                                if (op.getMarketingPolicy() == 1 || op.getMarketingPolicy() == 2) {
                                    if (NumberFormatUtil.doubleCompare(Double.valueOf(hasPaidPriceString), Double.valueOf(op.getPromotionPrice())) > 0) {
                                        isPaidPriceCorrect = false;
                                        break;
                                    }
                                } else {
                                    if (NumberFormatUtil.doubleCompare(Double.valueOf(hasPaidPriceString), Double.valueOf(op.getUnitPrice())) > 0) {
                                        isPaidPriceCorrect = false;
                                        break;
                                    }
                                }
                            } else {
                                if (NumberFormatUtil.doubleCompare(Double.valueOf(hasPaidPriceString), Double.valueOf(orderProductPromotionPriceInput)) > 0) {
                                    isPaidPriceCorrect = false;
                                    break;
                                }
                            }
                        }
                    }
                }
                boolean isCommodityOrderResponsibleNull = false;
                for (OrderProduct op : orderProductList) {
                    if (op.getProductType() == Constant.COMMODITY_ORDER && op.getResponsiblePersonID() == 0) {
                        isCommodityOrderResponsibleNull = true;
                    }
                }
                if (selectedCustomerID == 0)
                    DialogUtil.createShortDialog(this, "请选择客户！");
                else if (orderProductList == null || orderProductList.size() == 0)
                    DialogUtil.createShortDialog(this, "请先选择商品或者服务");
                else if (!isPaidPriceCorrect)
                    DialogUtil.createShortDialog(this, "过去支付金额不能大于服务/商品的价格");
                else if (isCommodityOrderResponsibleNull)
                    DialogUtil.createShortDialog(this, "商品单美丽顾问不能为空");
                else {
                    // progressDialog = ProgressDialogUtil.createProgressDialog(this);
                    final JSONArray orderProductArray = new JSONArray();
                    // 成交总价
                    double productTotalPrice = 0;
                    // 所有订单过去支付的金额
                    double productPastPaidPrice = 0;
                    // 总服务次数
                    Integer serviceNum = 0;
                    // 总过去服务次数
                    Integer serviceNumPast = 0;
                    // 是否含有不限次商品
                    boolean serviceNumAll = false;
                    // 判断是否有销售顾问的功能
                    boolean hasSales = false;
                    if (userinfoApplication.getAccountInfo().getModuleInUse().contains("|4|"))
                        hasSales = true;
                    int j = 0;
                    for (int i = 0; i < orderProductList.size(); i++) {
                        if (!orderProductList.get(i).isOldOrder()) {
                            JSONObject orderProductJson = new JSONObject();
                            OrderProduct orderProduct = orderProductList.get(i);
                            if (orderProduct.getCourseFrequency() < 1) {
                                serviceNumAll = true;
                            }
                            try {
                                orderProductJson.put("ResponsiblePersonID", orderProduct.getResponsiblePersonID());
                                // 如果有销售顾问功能并且销售顾问不等于美丽顾问
                                if (hasSales && (orderProduct.getResponsiblePersonID() != 0 && orderProduct.getSalesID() != orderProduct.getResponsiblePersonID()) || (orderProduct.getResponsiblePersonID() == 0 && orderProduct.getSalesID() != 0))
                                    orderProductJson.put("SalesID", orderProduct.getSalesID());
                                if (orderProduct.getProductType() == Constant.SERVICE_TYPE)
                                    orderProductJson.put("Expirationtime", (((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.service_order_expiration_date_text)).getText().toString()));
                                else if (orderProduct.getProductType() == Constant.COMMODITY_TYPE)
                                    orderProductJson.put("Expirationtime", "2099-12-31");
                            } catch (JSONException e1) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            double orderProductTotalSalePrice = 0;
                            try {
                                orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_sale_price)).getText().toString()));
                            } catch (NumberFormatException e) {
                                // TODO Auto-generated catch block
                                orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_total_price)).getText().toString()));
                            }
                            double orderProductHasPaidPrice = 0;
                            try {
                                orderProductHasPaidPrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_has_paid_price)).getText().toString()));
                            } catch (NumberFormatException e) {
                                // TODO Auto-generated catch block
                            }
                            Integer prepareOrderServiceQuantity = 0;
                            try {
                                prepareOrderServiceQuantity = Integer.parseInt((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_service_quantity)).getText().toString()));
                            } catch (NumberFormatException e) {
                                // TODO Auto-generated catch block
                            }
                            Integer prepareOrderProductHasCompletenum = 0;
                            try {
                                prepareOrderProductHasCompletenum = Integer.parseInt((((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_has_completenum)).getText().toString()));
                            } catch (NumberFormatException e) {
                                // TODO Auto-generated catch block
                            }
                            String orderProductRemark = (((TextView) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_remark)).getText().toString());
                            try {
                                if (orderProductRemark != null && !(("").equals(orderProductRemark))) {
                                    orderProductJson.put("Remark", orderProductRemark);
                                } else
                                    orderProductJson.put("Remark", "");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }


                            try {
                                orderProductJson.put("TaskID", taskID);
                                String hasCompletenumString = ((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_has_completenum)).getText().toString();
                                orderProductJson.put("CardID", orderProduct.getUserEcardID());
                                orderProductJson.put("ProductID", orderProduct.getProductID());
                                orderProductJson.put("OpportunityID", 0);
                                orderProductJson.put("ProductType", orderProduct.getProductType());
                                orderProductJson.put("ProductCode", orderProduct.getProductCode());
                                orderProductJson.put("Quantity", ((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_quantity)).getText().toString());
                                orderProductJson.put("TotalSalePrice", orderProductTotalSalePrice);
                                orderProductJson.put("TotalOrigPrice", NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getUnitPrice()) * orderProductJson.getInt("Quantity"))));
                                orderProductJson.put("TotalCalcPrice", Double.valueOf(((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_promotion_price)).getText().toString()));
                                orderProductJson.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                                orderProductJson.put("TGPastCount", hasCompletenumString);
                                orderProductJson.put("IsPast", orderProduct.isPast());
                                orderProductJson.put("BenefitID", orderProduct.getBenefitID());
                                orderProductJson.put("PRValue2", orderProduct.getPrValue2());
                                String hasPaidPriceString = ((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_product_has_paid_price)).getText().toString();
                                orderProductJson.put("PaidPrice", hasPaidPriceString);

                                if (orderProduct.getProductType() == 0 && orderProduct.getCourseFrequency() != 0) {
                                    orderProductJson.put("TGTotalCount", ((EditText) prepareOrderProductListView.getChildAt(j).findViewById(R.id.prepare_order_service_quantity)).getText().toString());
                                } else {
                                    orderProductJson.put("TGTotalCount", 0);
                                }

                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            orderProductArray.put(orderProductJson);
                            // 成交价格
                            productTotalPrice += orderProductTotalSalePrice;
                            // 过去支付
                            productPastPaidPrice += orderProductHasPaidPrice;
                            // 服务次数
                            serviceNum += prepareOrderServiceQuantity;
                            // 过去服务次数
                            serviceNumPast += prepareOrderProductHasCompletenum;
                            j++;
                        }

                    }
                    //判断是不是所有订单都是0元订单
                    if (productTotalPrice == 0)
                        isZeroOrder = 1;
                    //判断订单的过去支付金额是不是都小于订单应付金额
                    if (NumberFormatUtil.doubleCompare(productTotalPrice, productPastPaidPrice) == 0)
                        isPastPayAll = 1;

                    AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.CustomerAlertDialog);
                    // 获取布局
                    View view2 = getLayoutInflater().from(this).inflate(R.layout.activity_prepare_order_make_sure, null);
                    // 获取布局中的控件
                    final TextView prepareOrderTotalPrice = (TextView) view2.findViewById(R.id.prepare_order_total_price);
                    if (productTotalPrice - productPastPaidPrice > 0) {
                        prepareOrderTotalPrice.setText(df2.format(productTotalPrice - productPastPaidPrice));
                    } else {
                        prepareOrderTotalPrice.setText(df2.format(0));
                    }
                    final TextView prepareOrderServiceNum = (TextView) view2.findViewById(R.id.prepare_order_service_num);
                    if (serviceNum - serviceNumPast > 0) {
                        prepareOrderServiceNum.setText(String.valueOf(serviceNum - serviceNumPast));
                    } else if (serviceNumAll) {
                        prepareOrderServiceNum.setText("不限");
                    } else {
                        prepareOrderServiceNum.setText(String.valueOf(0));
                    }
                    final Button btnMakeSure = (Button) view2.findViewById(R.id.btn_make_sure);
                    final Button btnCancel = (Button) view2.findViewById(R.id.btn_cancel);
                    // 创建对话框
                    final AlertDialog alertDialog = builder.create();
                    alertDialog.setCanceledOnTouchOutside(true);
                    alertDialog.show();
                    alertDialog.getWindow().setContentView(view2);
                    btnCancel.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            alertDialog.dismiss();
                        }
                    });
                    btnMakeSure.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            // TODO Auto-generated method stub
                            alertDialog.dismiss();
                            progressDialog = ProgressDialogUtil.createProgressDialog(PrepareOrderActivity.this);
                            requestWebServiceThread = new Thread() {
                                @Override
                                public void run() {
                                    if (exit) {
                                        return;
                                    }
                                    String methodName = "AddNewOrder";
                                    String endPoint = "Order";
                                    JSONObject prepareOrderJson = new JSONObject();
                                    try {
                                        prepareOrderJson.put("OrderList", orderProductArray);
                                        prepareOrderJson.put("OldOrderIDs", OldOrderIdArray);
                                    } catch (JSONException e) {
                                        // TODO Auto-generated catch block
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                    if (opportunityID != 0) {
                                        try {
                                            prepareOrderJson.put("CustomerID", orderProductList.get(0).getCustomerID());
                                        } catch (JSONException e) {
                                            mHandler.sendEmptyMessage(99);
                                            return;
                                        }
                                    } else {
                                        try {
                                            prepareOrderJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                                        } catch (JSONException e) {
                                            mHandler.sendEmptyMessage(99);
                                            return;
                                        }
                                    }
                                    String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, prepareOrderJson.toString(), userinfoApplication);
                                    JSONObject resultJson = null;
                                    try {
                                        resultJson = new JSONObject(serverResultResult);
                                    } catch (JSONException e1) {
                                        // TODO Auto-generated catch block
                                        e1.printStackTrace();
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                    if (serverResultResult == null
                                            || serverResultResult.equals(""))
                                        mHandler.sendEmptyMessage(-1);
                                    else {
                                        String code = "0";
                                        String message = "";
                                        try {
                                            code = resultJson.getString("Code");
                                            message = resultJson.getString("Message");
                                        } catch (JSONException e) {
                                            // TODO Auto-generated catch block
                                            code = "0";
                                            mHandler.sendEmptyMessage(99);
                                            return;
                                        }
                                        if (Integer.parseInt(code) == 1) {
                                            quickBalanceOrderList = new ArrayList<OrderInfo>();
                                            JSONArray orderListArray = null;
                                            try {
                                                orderListArray = resultJson.getJSONArray("Data");
                                            } catch (JSONException e) {
                                                mHandler.sendEmptyMessage(99);
                                                return;
                                            }
                                            if (orderListArray != null) {
                                                for (int i = 0; i < orderListArray.length(); i++) {
                                                    try {
                                                        list.add(orderListArray.get(i).toString());
                                                    } catch (JSONException e) {
                                                        e.printStackTrace();
                                                        mHandler.sendEmptyMessage(99);
                                                        return;
                                                    }
                                                }
                                            }
                                            Message msg = new Message();
                                            mHandler.sendEmptyMessage(9);
                                        } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                                            mHandler.sendEmptyMessage(Integer.parseInt(code));
                                        else if (Integer.parseInt(code) == -2) {
                                            Message msg = new Message();
                                            msg.what = 4;
                                            msg.obj = message;
                                            mHandler.sendMessage(msg);
                                        } else {
                                            Message msg = new Message();
                                            msg.what = 0;
                                            msg.obj = message;
                                            mHandler.sendMessage(msg);
                                        }
                                    }
                                }
                            };
                            requestWebServiceThread.start();
                        }
                    });
                }
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        // 选择美丽顾问成功返回
        if (resultCode == RESULT_OK) {
            // 开单 更换订单的美丽顾问
            if (requestCode == 300) {
                final int newResponsiblePersonID = data.getIntExtra("personId", 0);
                orderProductList.get(operationIndex).setResponsiblePersonID(newResponsiblePersonID);
                if (newResponsiblePersonID == 0) {
                    ((TextView) prepareOrderProductListView.getChildAt(operationIndex).findViewById(R.id.prepare_order_reaponsible_name)).setText("");
                } else if (newResponsiblePersonID != 0) {
                    String personName = data.getStringExtra("personName");
                    ((TextView) prepareOrderProductListView.getChildAt(operationIndex).findViewById(R.id.prepare_order_reaponsible_name)).setText(personName);
                }
            }
        }
    }

    private void addOpportunity() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        final JSONArray opportunityProductArray = new JSONArray();
        for (int i = 0; i < orderProductList.size(); i++) {
            if (!orderProductList.get(i).isOldOrder()) {
                JSONObject opportunityProduct = new JSONObject();
                OrderProduct orderProduct = orderProductList.get(i);
                try {
                    opportunityProduct.put("ResponsiblePersonID", orderProduct.getResponsiblePersonID());
                } catch (JSONException e1) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                double orderProductTotalSalePrice = 0;
                try {
                    orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_promotion_price)).getText().toString()));
                } catch (NumberFormatException e) {
                    orderProductTotalSalePrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_total_price)).getText().toString()));
                }

                double orderProductTotalPrice = Double.parseDouble((((TextView) prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_total_price)).getText().toString()));
                try {
                    opportunityProduct.put("ProductType", orderProduct.getProductType());
                    opportunityProduct.put("Quantity", Integer.parseInt(((EditText) prepareOrderProductListView.getChildAt(i).findViewById(R.id.prepare_order_product_quantity)).getText().toString()));
                    opportunityProduct.put("ProductCode", orderProduct.getProductCode());
                    opportunityProduct.put("TotalSalePrice", orderProductTotalSalePrice);
                    opportunityProduct.put("TotalOrigPrice", NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getUnitPrice()) * opportunityProduct.getInt("Quantity"))));
                    opportunityProduct.put("TotalCalcPrice", NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(orderProduct.getPromotionPrice()) * opportunityProduct.getInt("Quantity"))));
                    opportunityProduct.put("StepID", orderProduct.getStepTemplateId());
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                opportunityProductArray.put(opportunityProduct);
            }
        }
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                if (exit) {
                    return;
                }
                String methodName = "addOpportunity";
                String endPoint = "Opportunity";
                JSONObject prepareOpportunityJson = new JSONObject();
                try {
                    prepareOpportunityJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    prepareOpportunityJson.put("ProductList", opportunityProductArray);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, prepareOpportunityJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                if (serverResultResult == null || serverResultResult.equals(""))
                    mHandler.sendEmptyMessage(-1);
                else {
                    String code = "0";
                    String message = "";
                    try {
                        code = resultJson.getString("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = "0";
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (Integer.parseInt(code) == 1) {
                        mHandler.sendEmptyMessage(1);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
                    else if (Integer.parseInt(code) == -2) {
                        Message msg = new Message();
                        msg.what = 4;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    } else {
                        Message msg = new Message();
                        msg.what = 0;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    //获得商机模板
    private void getStepTemplate() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                if (exit) {
                    return;
                }
                String methodName = "getStepList";
                String endPoint = "Opportunity";
                JSONObject getStepListParamJson = new JSONObject();
                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getStepListParamJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                if (serverResultResult == null || serverResultResult.equals(""))
                    mHandler.sendEmptyMessage(-1);
                else {
                    String code = "0";
                    String message = "";
                    try {
                        code = resultJson.getString("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        code = "0";
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (Integer.parseInt(code) == 1) {
                        stepTemplateList = new ArrayList<StepTemplate>();
                        JSONArray stepTemplateArray = null;
                        try {
                            stepTemplateArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (stepTemplateArray != null) {
                            for (int i = 0; i < stepTemplateArray.length(); i++) {
                                JSONObject stepTemplatejson = null;
                                try {
                                    stepTemplatejson = (JSONObject) stepTemplateArray.get(i);
                                } catch (JSONException e1) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                StepTemplate st = new StepTemplate();
                                int stepTemplateID = 0;
                                if (stepTemplatejson.has("StepID")) {
                                    try {
                                        stepTemplateID = stepTemplatejson.getInt("StepID");
                                    } catch (JSONException e) {
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                }
                                String stepTemplateName = "";
                                if (stepTemplatejson.has("StepName")) {
                                    try {
                                        stepTemplateName = stepTemplatejson.getString("StepName");
                                    } catch (JSONException e) {
                                        mHandler.sendEmptyMessage(99);
                                        return;
                                    }
                                }
                                st.setStepTemplateID(stepTemplateID);
                                st.setStepTemplateName(stepTemplateName);
                                stepTemplateList.add(st);
                            }
                        }
                        mHandler.sendEmptyMessage(6);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
                    else if (Integer.parseInt(code) == -2) {
                        Message msg = new Message();
                        msg.what = 4;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    } else {
                        Message msg = new Message();
                        msg.what = 0;
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
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}