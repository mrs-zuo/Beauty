package com.GlamourPromise.Beauty.Jpush;
import java.util.UUID;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class RandomUUID {
	private static String uuidRaw;
	private static SharedPreferences sharedPreferences;
	public static String getRandomUUID(Context context, String lastLoginAccount){
		uuidRaw = "";
		sharedPreferences = context.getSharedPreferences("AccountInfo", Context.MODE_PRIVATE);
		if(sharedPreferences.getString("lastLoginAccount", "").equals(lastLoginAccount) && !sharedPreferences.getString("pushUUID", "").equals(""))
			uuidRaw = sharedPreferences.getString("pushUUID", "");
		else
			uuidRaw = createRandomUUID(context, lastLoginAccount);
		return uuidRaw;
	}
	
	public static String createRandomUUID(Context context, String accountID){
		//SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());
		//String data = sDateFormat.format(new java.util.Date());
		//data += accountID;
		String uuidRaw = UUID.randomUUID().toString();
		/*try {
			uuidRaw = UUID.nameUUIDFromBytes(data.getBytes("utf8")).toString();
			uuidRaw=UUID.randomUUID().toString();
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
		if(sharedPreferences == null)
			sharedPreferences = context.getSharedPreferences("AccountInfo", Context.MODE_PRIVATE);
		uuidRaw = uuidRaw.replaceAll("-","");
		Editor editor = sharedPreferences.edit();//获取编辑器
		editor.putString("pushUUID",uuidRaw);
		editor.commit();// 提交修改
		return uuidRaw;
	}
}
