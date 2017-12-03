@isTest
private class TransactionTriggerHandlerTest {
	
	@isTest static void test_method_one() {
		setupTestData();

		List<Transaction__c> tlist = New List<Transaction__c>([Select t.Type__c, t.TransactionCategory__c, t.Place_of_Transaction__c, t.Payment_Mode__c, t.Name, t.Id, t.Entry_Date__c, t.Amount__c From Transaction__c t]);

		System.debug('Number of Transaction Found : ' + tlist.size());

	}
	
	@TestSetup 
	static void setupTestData() {
		TestUtile.createTransactions(200, true, 'Expense');
	}
	
}