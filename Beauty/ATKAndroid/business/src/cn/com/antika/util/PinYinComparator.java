/**
 * PinYinCompartor.java
 * cn.com.antika.util
 * tim.zhang@bizapper.com
 * 2015年6月24日 下午3:46:40
 * @version V1.0
 */
package cn.com.antika.util;

import java.text.CollationKey;
import java.text.Collator;
import java.util.Comparator;
import cn.com.antika.bean.OrderInfo;
/**
 *PinYinCompartor
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年6月24日 下午3:46:40
 */
public class PinYinComparator implements Comparator<OrderInfo>{
	//0:按照顾客姓名  1：按照美丽顾问 
	private int  compareType;
	private Collator collator=Collator.getInstance(); 
	/**
	 *PinYinComparator
	 *@param 
	 *
	 */
	public PinYinComparator(int compareType) {
		super();
		this.compareType=compareType;
	}
	
	@Override
	public int compare(OrderInfo lhs, OrderInfo rhs) {
		// TODO Auto-generated method stub
		CollationKey key1=null;
		CollationKey key2=null;
		if(compareType==0){
			key1=collator.getCollationKey(lhs.getCustomerName().toLowerCase());
			key2=collator.getCollationKey(rhs.getCustomerName().toLowerCase());
		}
		else if(compareType==1){
			key1=collator.getCollationKey(lhs.getResponsiblePersonName().toLowerCase());
			key2=collator.getCollationKey(rhs.getResponsiblePersonName().toLowerCase());
		}
		return key1.compareTo(key2);
	}
}
