public with sharing class TransactionTriggerHandler {
  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public TransactionTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(Transaction__c[] newTransactionRecords){
    
    Category__c def = [SELECT Id, Name,Type__c FROM Category__c WHERE Name = 'Uncategorized' Limit 1];
    
    for(Transaction__c newRecord : newTransactionRecords){
      
        if(newRecord.TransactionCategory__c == null){
          System.debug('The transaction ' + newRecord.Name + ' has Category null. Setting the defailt category ' + def.Name);
          newRecord.TransactionCategory__c = def.Id;
          newRecord.Type__c = def.Type__c;
        }
    }
    
  }

  public void OnAfterInsert(Transaction__c[] newTransactionRecords){
    
    
  }

  @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){
    //Example usage
    //List<Transaction__c> newTransactionRecords = [select Id, Name from Transaction__c where Id IN :newRecordIDs];
  }

  public void OnBeforeUpdate(Transaction__c[] oldRecords, Transaction__c[] updatedRecords, Map<ID, Transaction__c> recordMap){
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where Transaction__cId IN :recordMap.keySet()] );
    Category__c def = [SELECT Id, Name,Type__c FROM Category__c WHERE Name = 'Uncategorized' Limit 1];
    //Assign the default category if removed by user
    for(Transaction__c newRecord : updatedRecords){
      
        if(newRecord.TransactionCategory__c == null){
          Category__c cat = def;
          System.debug('The transaction ' + newRecord.Name + ' has Category null. Setting the defailt category ' + def.Name);
          newRecord.TransactionCategory__c = def.Id;
          newRecord.Type__c = def.Type__c;
        }
    }

  }

  public void OnAfterUpdate(Transaction__c[] oldRecords, Transaction__c[] updatedRecords, Map<ID, Transaction__c> recordMap){

    Map<String,Transaction__c> expeseTransactions = new Map<String, Transaction__c>();
    Map<String,Transaction__c> incomeTransactions = new Map<String, Transaction__c>();
    List<String> expTransIds = new List<String>();
    List<String> incTransIds = new List<String>();
    
    //Get the list of expense type transaction
    for(Transaction__c newRecord : updatedRecords){
      
        if(newRecord.TransactionCategory__c != null){
          if(newRecord.Type__c == 'Expense'){
              expeseTransactions.put(newRecord.Transaction_ID__c, newRecord);
              expTransIds.add(newRecord.Transaction_ID__c);
          }else{
              incomeTransactions.put(newRecord.Transaction_ID__c, newRecord);
              incTransIds.add(newRecord.Transaction_ID__c);
          }
          
        }
    }
    List<Expense__c> expEntries;
    List<Income__c> incEntries;

    //Get the list of updated expense entry
    if(expeseTransactions.size() > 0){
        expEntries = new List<Expense__c>([SELECT Id, Name, Amount__c,Category__c, Entry_Date__c,Tranaction__c FROM Expense__c WHERE Tranaction__c IN :expeseTransactions.keySet()]);

        for(Expense__c e:expEntries){
          Transaction__c t =  expeseTransactions.get(e.Tranaction__c);
          e.Amount__c = t.Amount__c;
          e.Name = t.Name;
          e.Entry_Date__c = t.Entry_Date__c;
          e.Category__c = t.TransactionCategory__c;
        }
    }
    
    //Get the list of updated income entry
    if(incomeTransactions.size() > 0){
         incEntries = new List<Income__c>([SELECT Id, Name, Amount__c,Category__c, Entry_Date__c,Transaction__c From Income__c WHERE Transaction__c IN :incomeTransactions.keySet()]);

         for(Income__c e:incEntries){
          Transaction__c t =  incomeTransactions.get(e.Transaction__c);
          e.Amount__c = t.Amount__c;
          e.Name = t.Name;
          e.Entry_Date__c = t.Entry_Date__c;
          e.Category__c = t.TransactionCategory__c;
        }
    }
    
    if(expEntries != null && expEntries.size() > 0){
      System.debug('List of Expense need to update: ' + expEntries);
      update expEntries;
    }
    if(incEntries != null && incEntries.size() > 0){
      System.debug('List of income need to update: ' + incEntries);
      update incEntries;
    }

  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){
    //List<Transaction__c> updatedRecords = [select Id, Name from Transaction__c where Id IN :updatedRecordIDs];
  }

  public void OnBeforeDelete(Transaction__c[] recordsToDelete, Map<ID, Transaction__c> recordMap){

  }

  public void OnAfterDelete(Transaction__c[] deletedRecords, Map<ID, Transaction__c> recordMap){
      Set<String> tranIdTODelExp = new Set<String>();
      Set<String> tranIdTODelInc = new Set<String>();
      for(Transaction__c d: deletedRecords){
        if(d.Type__c == 'Income'){
          tranIdTODelInc.add(d.Transaction_ID__c);
        }else{
            tranIdTODelExp.add(d.Transaction_ID__c);
        }
        
      }

      System.debug('Expense to Delete:: ' + tranIdTODelExp);
      System.debug('Income to Delete:: ' + tranIdTODelInc);
      List<Income__c> expToDelInc;
      List<Expense__c> expToDelExp;
      //get the Expense/Income with related transaction
      if(tranIdTODelInc.size() > 0){
        expToDelInc = new List<Income__c>([SELECT Id, Name  FROM Income__c WHERE Transaction__c =:tranIdTODelInc]);
      }

      if(tranIdTODelExp.size() > 0){
        expToDelExp = new List<Expense__c>([SELECT Id, Name  FROM Expense__c WHERE Tranaction__c =:tranIdTODelExp]);
      }
      
      If(expToDelInc != null && expToDelInc.size() > 0){
          try{
              delete expToDelInc;
          }catch(exception e){
            System.debug('Error while Deleting Income: ' + e.getMessage());
          }
          
      }
      If(expToDelExp != null && expToDelExp.size() > 0){
          try{
              delete expToDelExp;
          }catch(exception e){
            System.debug('Error while Deleting Expense: ' + e.getMessage());
          }
          
      }

  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){

  }

  public void OnUndelete(Transaction__c[] restoredRecords){

  }

  public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }

  public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
  }
}