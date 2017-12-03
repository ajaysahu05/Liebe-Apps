public with sharing class TestUtile {

	public static List<Transaction__c> createTransactions(Integer numberOfTrans, Boolean doInsert,String type) {
		List<Transaction__c> trsn = new List<Transaction__c>();
		Category__c ct = New Category__c(Name='Uncategorized',Type__c = 'Expense');
		insert ct;
		if(numberOfTrans > 1){
			
			for(Integer i=0;i< numberOfTrans; i++){
				Transaction__c t = New Transaction__c();
				t.Name = 'TestTransaction_' + 0; 
				t.Amount__c = Math.Random()*100;
				datetime myDate = datetime.newInstance(2016, 3, 1);
				t.Entry_Date__c = myDate;
				t.Payment_Mode__c = 'Cash';
				t.TransactionCategory__c = ct.id;
				/*
				if(category != null){
					t.TransactionCategory__c = category.id;
				}else{
					Category__c ct = New Category__c(Name='Uncategory',Type__c=type );
					insert ct;
					t.TransactionCategory__c = ct.id;
				}*/
				trsn.add(t);

			}
		}else{
			Transaction__c t = New Transaction__c();
			t.Name = 'TestTransaction_1';
			t.Amount__c = Math.Random()*100;
			datetime myDate = datetime.newInstance(2016, 3, 1);
			t.Entry_Date__c = myDate;
			t.Payment_Mode__c = 'Cash';
			t.TransactionCategory__c = ct.id;
			/*
			if(category != null){
				t.TransactionCategory__c = category.id;
			}else{
				Category__c ct = New Category__c(Name='Uncategory',Type__c=type );
				insert ct;
				t.TransactionCategory__c = ct.id;
			}*/

			trsn.add(t);
		}

		if(trsn.size() > 0 && doInsert){
			insert trsn;
		}

		return trsn;
	}
}