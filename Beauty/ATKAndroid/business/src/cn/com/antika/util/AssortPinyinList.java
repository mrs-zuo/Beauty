package cn.com.antika.util;
import cn.com.antika.bean.Customer;
import net.sourceforge.pinyin4j.PinyinHelper;
public class AssortPinyinList {
	private HashList<String,Customer> hashList = new HashList<String,Customer>(
			new KeySort<String,Customer>() {
				@Override
				public String getKey(Customer customer) {
					// TODO Auto-generated method stub
					return getFirstChar(customer.getPinYin());
				}
			});

	public String getFirstChar(String value) {
		char firstChar = 0;
		if(value!=null && !("").equals(value))
			firstChar= value.charAt(0);
		String first = null;
		String[] print = PinyinHelper.toHanyuPinyinStringArray(firstChar);
		if (print == null) {
			if ((firstChar >= 97 && firstChar <= 122)) {
				firstChar -= 32;
			}
			if (firstChar >= 65 && firstChar <= 90) {
				first = String.valueOf((char) firstChar);
			}else {
				first = "#";
			}
		} else {
			first = String.valueOf((char) (print[0].charAt(0) - 32));
		}
		/*if (first == null) {
			first = "?";
		}*/
		return first;
	}

	public HashList<String,Customer> getHashList() {
		return hashList;
	}
}
