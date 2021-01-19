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
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.implementation.RechargeEcardTask;
import cn.com.antika.manager.NetUtil;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.LowerCase2Uppercase;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint({"ResourceType", "ClickableViewAccessibility"})
public class EcardMoneyOut extends BaseActivity implements OnClickListener {
    private EcardMoneyOutHandler mHandler = new EcardMoneyOutHandler(this);
    private static final String PROMPT_MESSAGE_1 = "账户直扣成功！";
    private static final String PROMPT_MESSAGE_3 = "账户直扣失败，请重新尝试！";
    private ProgressDialog progressDialog;
    private EditText remarkEditText, thisBenefitSharePercent;
    private UserInfoApplication userInfoApplication;
    private EcardInfo ecardInfo, customerEcardInfoPoint, customerEcardInfoCashCoupon;
    private Thread thread;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    private int rechargeType;
    private String mBenefitPersonIDs;
    private String mBenefitPersonNames;
    private TextView mTvBenefitPerson, thisTimepayment_benefit_share_btn;
    private String mSlaveID, mSlaveName;
    private LayoutInflater layoutInflater;
    private TableLayout ecardSlaverTablelayout;
    private int shareFlg = 0, namegetFlg = 0, cnt_i, changeFlg = 0;
    private boolean isComissionCalc = true;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class EcardMoneyOutHandler extends Handler {
        private final EcardMoneyOut ecardMoneyOut;

        private EcardMoneyOutHandler(EcardMoneyOut activity) {
            WeakReference<EcardMoneyOut> weakReference = new WeakReference<EcardMoneyOut>(activity);
            ecardMoneyOut = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (ecardMoneyOut.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (ecardMoneyOut.progressDialog != null) {
                ecardMoneyOut.progressDialog.dismiss();
                ecardMoneyOut.progressDialog = null;
            }
            if (ecardMoneyOut.thread != null) {
                ecardMoneyOut.thread.interrupt();
                ecardMoneyOut.thread = null;
            }
            if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                AlertDialog alertDialog = null;
                alertDialog = DialogUtil.createShortShowDialog(ecardMoneyOut, "提示信息", PROMPT_MESSAGE_1);
                alertDialog.show();
                Intent destIntent = new Intent(ecardMoneyOut, CustomerEcardActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("customerEcard", ecardMoneyOut.ecardInfo);
                bundle.putSerializable("customerEcardPoint", ecardMoneyOut.customerEcardInfoPoint);
                bundle.putSerializable("customerEcardCashcoupon", ecardMoneyOut.customerEcardInfoCashCoupon);
                destIntent.putExtras(bundle);
                ecardMoneyOut.startActivity(destIntent);
                ecardMoneyOut.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, ecardMoneyOut.dialogTimer, ecardMoneyOut, destIntent);
                ecardMoneyOut.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(ecardMoneyOut, PROMPT_MESSAGE_3);
            } else if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR)
                DialogUtil.createShortDialog(ecardMoneyOut, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(ecardMoneyOut, ecardMoneyOut.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(ecardMoneyOut);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + ecardMoneyOut.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(ecardMoneyOut);
                ecardMoneyOut.packageUpdateUtil = new PackageUpdateUtil(ecardMoneyOut, ecardMoneyOut.mHandler, fileCache, downloadFileUrl, false, ecardMoneyOut.userInfoApplication);
                ecardMoneyOut.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                ecardMoneyOut.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = ecardMoneyOut.getFileStreamPath(filename);
                file.getName();
                ecardMoneyOut.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 6)
                ecardMoneyOut.initView();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_ecard_money_out);
        Intent intent = getIntent();
        ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
        customerEcardInfoPoint = (EcardInfo) intent.getSerializableExtra("customerEcardPoint");
        customerEcardInfoCashCoupon = (EcardInfo) intent.getSerializableExtra("customerEcardCashcoupon");
        userInfoApplication = (UserInfoApplication) getApplication();
        isComissionCalc = userInfoApplication.getAccountInfo().isComissionCalc();
        thisTimepayment_benefit_share_btn = (TextView) findViewById(R.id.payment_benefit_share_btn_o);
        findViewById(R.id.payment_benefit_share_btn_o).setOnClickListener(this);
        if (!isComissionCalc) {
            thisTimepayment_benefit_share_btn.setVisibility(View.GONE);
        }
        getDefaultSlaveID();
    }

    private void initView() {
        ((TextView) findViewById(R.id.balance)).setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(ecardInfo.getUserEcardBalance()));
        ((TextView) findViewById(R.id.customer_name)).setText(userInfoApplication.getSelectedCustomerName());
        ((Button) findViewById(R.id.make_sure_btn)).setOnClickListener(this);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        layoutInflater = LayoutInflater.from(this);
        ecardSlaverTablelayout = (TableLayout) findViewById(R.id.ecard_slaver_tablelayout);
        remarkEditText = (EditText) findViewById(R.id.comment_edit);
        remarkEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {
                ((TextView) findViewById(R.id.text_count)).setText(String.valueOf(s.length()) + "/200");
            }

            @Override
            public void afterTextChanged(Editable arg0) {
            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {
            }
        });
        ((EditText) findViewById(R.id.money_out_amount)).addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                // TODO Auto-generated method stub
                if (s != null && !(s.toString().equals(""))) {
                    double moneyOutNumber = 0;
                    try {
                        moneyOutNumber = Double.valueOf(s.toString());
                    } catch (NumberFormatException e) {
                        moneyOutNumber = 0;
                    }
                    if (moneyOutNumber > Double.valueOf(ecardInfo.getUserEcardBalance())) {
                        DialogUtil.createShortDialog(EcardMoneyOut.this, "直扣金额超出！");
                        ((EditText) findViewById(R.id.money_out_amount)).setText("");
                    }

                }
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
        mTvBenefitPerson = (TextView) findViewById(R.id.ecard_money_out_benefit_person);
        /*		findViewById(R.id.ecard_money_out_benefit_person_layout).setOnClickListener(this);*/
        findViewById(R.id.ecard_money_out_benefit_person).setOnClickListener(this);
        findViewById(R.id.payment_benefit_textv_o).setOnClickListener(this);
        thisBenefitSharePercent = (EditText) findViewById(R.id.benefit_share_percent_o);
        setBenefitPersonInfo(mSlaveID, mSlaveName);
    }

    protected void getDefaultSlaveID() {
        thread = new Thread() {
            @Override
            public void run() {
                String methodName = "getAccountList";
                String endPoint = "account";
                JSONObject getAccountListJsonParam = new JSONObject();
                try {
                    getAccountListJsonParam.put("CustomerID", userInfoApplication.getSelectedCustomerID());
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getAccountListJsonParam.toString(), userInfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {

                    }
                    JSONArray salesArray = null;
                    if (code == 1) {
                        try {
                            salesArray = resultJson.getJSONArray("Data");
                            String salesID = "";
                            String salesPersonName = "";
                            if (salesArray != null) {
                                JSONArray salesIDJsonArray = new JSONArray();
                                for (int j = 0; j < salesArray.length(); j++) {
                                    JSONObject obj = salesArray.getJSONObject(j);
                                    int accountType = obj.getInt("AccountType");
                                    if (accountType == 1) {
                                        salesIDJsonArray.put(obj.getInt("AccountID"));
                                        if (j == salesArray.length() - 1) {
                                            salesPersonName += obj.getString("AccountName");
                                        } else {
                                            salesPersonName += obj.getString("AccountName") + "、";
                                        }
                                    }
                                }
                                salesID = salesIDJsonArray.toString();
                            }
                            mSlaveID = salesID;
                            mSlaveName = salesPersonName;
                            namegetFlg = 1;
                        } catch (JSONException e) {
                        }
                        mHandler.sendEmptyMessage(6);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        thread.start();
    }

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            case R.id.make_sure_btn:
                if (userInfoApplication.getAccountInfo().getAuthDirectExpend() != 1) {
                    DialogUtil.createMakeSureDialog(this, "温馨提示", "您没有直扣权限，不能进行操作");
                    return;
                }
                if (userInfoApplication.getSelectedCustomerID() == 0) {
                    DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
                } else {
                    rechargeType = 5;
                    final String rechargeAmount = ((EditText) findViewById(R.id.money_out_amount)).getText().toString();
                    if (rechargeAmount == null || ("").equals(rechargeAmount))
                        DialogUtil.createShortDialog(this, "直扣金额不能为空!");
                    else if (Float.parseFloat(rechargeAmount.toString()) == 0)
                        DialogUtil.createShortDialog(this, "直扣金额不能为0!");
                    else {
                        String dialogMsg = "";
                        dialogMsg = "本次直扣合计:" + userInfoApplication.getAccountInfo().getCurrency() + rechargeAmount + "," + LowerCase2Uppercase.l2Uppercase(Double.valueOf(rechargeAmount)) + "。";
                        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                                .setTitle(getString(R.string.delete_dialog_title))
                                .setMessage(dialogMsg)
                                .setPositiveButton(getString(R.string.delete_confirm),
                                        new DialogInterface.OnClickListener() {

                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                dialog.dismiss();
                                                progressDialog = ProgressDialogUtil.createProgressDialog(EcardMoneyOut.this);
                                                rechargeToServer(rechargeAmount);
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
                    }
                }
                break;
/*		case R.id.ecard_money_out_benefit_person_layout:
			Intent chooseBenefitPersonIntent = new Intent(this,ChoosePersonActivity.class);
			chooseBenefitPersonIntent.putExtra("personRole", "Doctor");
			chooseBenefitPersonIntent.putExtra("checkModel", "Multi");
			chooseBenefitPersonIntent.putExtra("selectPersonIDs",mBenefitPersonIDs);
			chooseBenefitPersonIntent.putExtra("customerID",userInfoApplication.getSelectedCustomerID());
			startActivityForResult(chooseBenefitPersonIntent, 101);
			break;*/
            case R.id.ecard_money_out_benefit_person:
                Intent chooseBenefitPersonIntent2 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent2.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent2.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent2.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent2.putExtra("customerID", userInfoApplication.getSelectedCustomerID());
                startActivityForResult(chooseBenefitPersonIntent2, 101);
                break;
            case R.id.payment_benefit_textv_o:
                Intent chooseBenefitPersonIntent3 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent3.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent3.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent3.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent3.putExtra("customerID", userInfoApplication.getSelectedCustomerID());
                startActivityForResult(chooseBenefitPersonIntent3, 101);
                break;
            case R.id.payment_benefit_share_btn_o:
                if (shareFlg == 0 && !checkBenefitPersonIsNull() && isComissionCalc) {
                    shareFlg = 1;
                    setBenefitPersonInfo(mBenefitPersonIDs, mBenefitPersonNames);
                }
                break;
            default:
                break;
        }
    }

    private boolean checkBenefitPersonIsNull() {
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]") || mBenefitPersonIDs.equals("[]"))
            return true;
        else
            return false;
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        if (resultCode != RESULT_OK) {
            return;
        }
        if (requestCode == 101) {
            namegetFlg = 1;
            setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
        }
    }

    private void setBenefitPersonInfo(String id, String name) {
        if (namegetFlg == 1) {
            mBenefitPersonIDs = id;
            mBenefitPersonNames = name;
            namegetFlg = 0;
        }
        ecardSlaverTablelayout.removeViews(5, ecardSlaverTablelayout.getChildCount() - 5);
        JSONArray idArray = null;
        try {
            idArray = new JSONArray(id);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        if (idArray != null && idArray.length() > 0) {
            String[] nameArray = name.split("、");
            for (int i = 0; i < nameArray.length; i++) {
                View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                benefitPersonNameText.setText(nameArray[i]);
                EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                benefitPersonPercentText.setOnTouchListener(new View.OnTouchListener() {
                    int touch_flag = 0;

                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        touch_flag++;
                        if (touch_flag == 2) {
                            touch_flag = 0;
                            if (shareFlg == 1) {
                                String[] nameArray = mBenefitPersonNames.split("、");
                                ecardSlaverTablelayout.removeViews(5, ecardSlaverTablelayout.getChildCount() - 5);
                                for (int j = 0; j < nameArray.length; j++) {
                                    View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                                    TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                    benefitPersonNameText.setText(nameArray[j]);
                                    EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                                    TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                                    EditText[] editText = new EditText[]{benefitPersonPercentText};
                                    NumberFormatUtil.setPricePointArray(editText, 2);
                                    benefitPersonPercentText.setText(String.valueOf(0));
                                    ecardSlaverTablelayout.addView(benefitPersonItemView, 5 + j);
                                }
                                shareFlg = 0;
                                return true;
                            }
                        }
                        return false;
                    }
                });
                TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                if (!isComissionCalc) {
                    benefitPersonPercentText.setVisibility(View.GONE);
                    benefitPersonPercentMark.setVisibility(View.GONE);
                }
                EditText[] editText = new EditText[]{benefitPersonPercentText};
                NumberFormatUtil.setPricePointArray(editText, 2);
                if (shareFlg == 1) {
                    benefitPersonPercentText.setText("均分");
                } else {
                    benefitPersonPercentText.setText(String.valueOf(0));
                }
                ecardSlaverTablelayout.addView(benefitPersonItemView, 5 + i);
            }
        }
    }

    private void rechargeToServer(String rechargeAmount) {
        RechargeEcardTask task = createRechargeTask(rechargeAmount);
        NetUtil netUtil = NetUtil.getNetUtil();
        netUtil.submitDownloadTask(task);
    }

    private RechargeEcardTask createRechargeTask(String rechargeAmount) {
        JSONArray giveJsonArray = new JSONArray();
        RechargeEcardTask.Builder builder = new RechargeEcardTask.Builder();
        int customerID = userInfoApplication.getSelectedCustomerID();
        String remark = "";
        if (remarkEditText.getText().toString() != null && !(remarkEditText.getText().toString().equals(""))) {
            remark = remarkEditText.getText().toString();
        }
        JSONArray benefitDetailJsonArray = new JSONArray();
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]"))
            ;
        else {
            try {
                JSONArray tmp = new JSONArray(mBenefitPersonIDs);
                for (int i = 5; i < ecardSlaverTablelayout.getChildCount(); i++) {
                    EditText percentEditText = ((EditText) ecardSlaverTablelayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                    double percent = 0;
                    if (percentEditText.getText() != null && shareFlg == 0)
                        percent = Double.valueOf(percentEditText.getText().toString()) / 100;
                    JSONObject benefitJson = new JSONObject();
                    benefitJson.put("SlaveID", tmp.get(i - 5));
                    benefitJson.put("ProfitPct", percent);
                    benefitDetailJsonArray.put(benefitJson);
                }
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        builder.setAmount(NumberFormatUtil.currencyFormat(rechargeAmount)).setChangeType(rechargeType).setCardType(ecardInfo.getUserEcardType()).setDepositMode(0).
                setUserCardNo(ecardInfo.getUserEcardNo()).setCustomerID(customerID).setHandler(mHandler)
                .setRemark(remark).setResponsiblePersonID(0).setSlaveIDs(benefitDetailJsonArray.toString()).setGiveJsonArray(giveJsonArray)
                .setAverageFlag(shareFlg).setBranchProfitRate(Double.valueOf(thisBenefitSharePercent.getText().toString()) / 100);
        return builder.create();
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (thread != null) {
            thread.interrupt();
            thread = null;
        }
    }
}
