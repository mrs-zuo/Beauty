package com.GlamourPromise.Beauty.Business;

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
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.RechargeEcardTask;
import com.GlamourPromise.Beauty.implementation.RechargeEcardTask.Builder;
import com.GlamourPromise.Beauty.manager.NetUtil;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import org.json.JSONArray;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Timer;

public class EcardTypeOtherMoneyOut extends BaseActivity implements OnClickListener {
    private EcardTypeOtherMoneyOutHandler mHandler = new EcardTypeOtherMoneyOutHandler(this);
    private ProgressDialog progressDialog;
    private EditText remarkEditText;
    private UserInfoApplication userInfoApplication;
    private EcardInfo ecardInfo;
    private Thread thread;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    private String ecardTypeName;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class EcardTypeOtherMoneyOutHandler extends Handler {
        private final EcardTypeOtherMoneyOut ecardTypeOtherMoneyOut;

        private EcardTypeOtherMoneyOutHandler(EcardTypeOtherMoneyOut activity) {
            WeakReference<EcardTypeOtherMoneyOut> weakReference = new WeakReference<EcardTypeOtherMoneyOut>(activity);
            ecardTypeOtherMoneyOut = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (ecardTypeOtherMoneyOut.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (ecardTypeOtherMoneyOut.progressDialog != null) {
                ecardTypeOtherMoneyOut.progressDialog.dismiss();
                ecardTypeOtherMoneyOut.progressDialog = null;
            }
            if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(ecardTypeOtherMoneyOut, "提示信息", ecardTypeOtherMoneyOut.ecardTypeName + "支出成功！");
                alertDialog.show();
                Intent destIntent = new Intent(ecardTypeOtherMoneyOut, CustomerEcardActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("customerEcard", ecardTypeOtherMoneyOut.ecardInfo);
                destIntent.putExtras(bundle);
                ecardTypeOtherMoneyOut.startActivity(destIntent);
                ecardTypeOtherMoneyOut.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, ecardTypeOtherMoneyOut.dialogTimer, ecardTypeOtherMoneyOut, destIntent);
                ecardTypeOtherMoneyOut.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(ecardTypeOtherMoneyOut, ecardTypeOtherMoneyOut.ecardTypeName + "支出失败，请重试!");
            } else if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR)
                DialogUtil.createShortDialog(ecardTypeOtherMoneyOut, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(ecardTypeOtherMoneyOut, ecardTypeOtherMoneyOut.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(ecardTypeOtherMoneyOut);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + ecardTypeOtherMoneyOut.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(ecardTypeOtherMoneyOut);
                ecardTypeOtherMoneyOut.packageUpdateUtil = new PackageUpdateUtil(ecardTypeOtherMoneyOut, ecardTypeOtherMoneyOut.mHandler, fileCache, downloadFileUrl, false, ecardTypeOtherMoneyOut.userInfoApplication);
                ecardTypeOtherMoneyOut.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                ecardTypeOtherMoneyOut.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = ecardTypeOtherMoneyOut.getFileStreamPath(filename);
                file.getName();
                ecardTypeOtherMoneyOut.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (ecardTypeOtherMoneyOut.thread != null) {
                ecardTypeOtherMoneyOut.thread.interrupt();
                ecardTypeOtherMoneyOut.thread = null;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_ecard_type_other_money_out);
        Intent intent = getIntent();
        ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
        if (ecardInfo.getUserEcardType() == 2)
            ecardTypeName = "积分";
        else if (ecardInfo.getUserEcardType() == 3)
            ecardTypeName = "现金券";
        userInfoApplication = (UserInfoApplication) getApplication();
        initView();
    }

    private void initView() {
        if (ecardInfo.getUserEcardType() == 2)
            ((TextView) findViewById(R.id.balance)).setText(NumberFormatUtil.currencyFormat(ecardInfo.getUserEcardBalance()));
        else if (ecardInfo.getUserEcardType() == 3)
            ((TextView) findViewById(R.id.balance)).setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(ecardInfo.getUserEcardBalance()));
        ((TextView) findViewById(R.id.ecard_type_other_money_other_title_text)).setText(ecardTypeName + "支出");
        ((TextView) findViewById(R.id.money_out_balance_title)).setText("剩余" + ecardTypeName);
        ((TextView) findViewById(R.id.money_out_amount_prompt_title)).setText("支出" + ecardTypeName);
        ((TextView) findViewById(R.id.customer_name)).setText(userInfoApplication.getSelectedCustomerName());
        ((Button) findViewById(R.id.make_sure_btn)).setOnClickListener(this);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
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
                        DialogUtil.createShortDialog(EcardTypeOtherMoneyOut.this, ecardTypeName + "支出金额超出！");
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
                    final String rechargeAmount = ((EditText) findViewById(R.id.money_out_amount)).getText().toString();
                    if (rechargeAmount == null || ("").equals(rechargeAmount))
                        DialogUtil.createShortDialog(this, ecardTypeName + "支出不能为空!");
                    else if (Float.parseFloat(rechargeAmount.toString()) == 0)
                        DialogUtil.createShortDialog(this, ecardTypeName + "支出不能为0!");
                    else {
                        String dialogMsg = "";
                        dialogMsg = "本次支出合计:" + rechargeAmount;
                        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                                .setTitle(getString(R.string.delete_dialog_title))
                                .setMessage(dialogMsg)
                                .setPositiveButton(getString(R.string.delete_confirm),
                                        new DialogInterface.OnClickListener() {

                                            @Override
                                            public void onClick(DialogInterface dialog,
                                                                int which) {
                                                dialog.dismiss();
                                                progressDialog = ProgressDialogUtil.createProgressDialog(EcardTypeOtherMoneyOut.this);
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
            default:
                break;
        }
    }

    private void rechargeToServer(String rechargeAmount) {
        RechargeEcardTask task = createRechargeTask(rechargeAmount);
        NetUtil netUtil = NetUtil.getNetUtil();
        netUtil.submitDownloadTask(task);
    }

    private RechargeEcardTask createRechargeTask(String rechargeAmount) {
        JSONArray giveJsonArray = new JSONArray();
        RechargeEcardTask.Builder builder = new Builder();
        int customerID = userInfoApplication.getSelectedCustomerID();
        String remark = "";
        if (remarkEditText.getText().toString() != null && !(remarkEditText.getText().toString().equals(""))) {
            remark = remarkEditText.getText().toString();
        }
        builder.setAmount(NumberFormatUtil.currencyFormat(rechargeAmount)).setChangeType(5).setCardType(ecardInfo.getUserEcardType()).setDepositMode(0).
                setUserCardNo(ecardInfo.getUserEcardNo()).setCustomerID(customerID).setHandler(mHandler)
                .setRemark(remark).setResponsiblePersonID(0).setGiveJsonArray(giveJsonArray);
        return builder.create();
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
        if (thread != null) {
            thread.interrupt();
            thread = null;
        }
    }
}
