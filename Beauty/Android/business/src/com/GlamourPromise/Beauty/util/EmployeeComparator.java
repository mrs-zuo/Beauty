package com.GlamourPromise.Beauty.util;
import java.util.Comparator;
import com.GlamourPromise.Beauty.bean.Customer;
public class EmployeeComparator implements Comparator<Customer>{
	
	@Override
	public int compare(Customer c1, Customer c2) {
		// TODO Auto-generated method stub
		if(c2.getIsSelected()>c1.getIsSelected())
			return 1;
		else if(c1.getIsSelected()==c2.getIsSelected())
			return 0;
		else
			return -1;
	}
}
