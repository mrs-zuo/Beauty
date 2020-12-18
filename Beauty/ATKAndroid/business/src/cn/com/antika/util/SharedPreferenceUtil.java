package cn.com.antika.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class SharedPreferenceUtil {
	
	private Context mContext;
	private SharedPreferences mPreAdvancedFilter;
	private Editor mSharePreEdit;
	private static SharedPreferenceUtil sInstance;
	
	public enum AdvancedFilterFlag{
		RecordFLag,
		NoteFlag,
		OrderFlag,
		OpportunityFlag,
		BusinessGroupFlag,
		AppointmentTaskFlag,
		VisitTaskFlag,
		TodayServiceFlag;
	}
	
	private SharedPreferenceUtil(Context context){
		mContext = context;
		mPreAdvancedFilter = mContext.getSharedPreferences("GlmourPromiseCustomerTypeFilter",Context.MODE_PRIVATE);
		mSharePreEdit = mPreAdvancedFilter.edit();
	}
	
	public static SharedPreferenceUtil getSharePreferenceInstance(Context context){
		if(sInstance == null){
			sInstance = new SharedPreferenceUtil(context);
		}
		return sInstance;
	}
	
	public void putAdvancedFilter(String key, String value){
		mSharePreEdit.putString(key, value);
		mSharePreEdit.commit();
	}
	
	/**
	 * 生成Key
	 * @param accountID
	 * @param flag
	 * @return
	 */
	public String getAdvancedConditionKey(int branchID, int accountID, AdvancedFilterFlag flag){
		StringBuilder key = new StringBuilder("AdvancedCondition");
		if(flag == AdvancedFilterFlag.NoteFlag){
			key.append("-Note");
		}else if(flag == AdvancedFilterFlag.RecordFLag){
			key.append("-Record");
		}
		else if(flag == AdvancedFilterFlag.OrderFlag){
			key.append("-Order");
		}
		else if(flag==AdvancedFilterFlag.OpportunityFlag){
			key.append("-Opportunity");
		}
		else if(flag==AdvancedFilterFlag.AppointmentTaskFlag){
			key.append("-AppointmentTask");
		}
		else if(flag==AdvancedFilterFlag.BusinessGroupFlag){
			key.append("-BusinessGroup");
		}
		else if(flag==AdvancedFilterFlag.VisitTaskFlag){
			key.append("-VisitTask");
		}
		else if(flag==AdvancedFilterFlag.TodayServiceFlag){
			key.append("-TodayService");
		}
		key.append("-");
		key.append(branchID);
		key.append("-");
		key.append(accountID);
		return key.toString();
	}
	
	/**
	 * 获取Key对应的值
	 * @param key
	 * @return
	 */
	public String getValue(String key){
		return mPreAdvancedFilter.getString(key, "");
	}
}
