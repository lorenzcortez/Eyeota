/*
    Name         : accountLookupController
    Author       : 
    Date         : 
    Description  : This class is used to Provide Custom lookup window on Mapping DashBoard page ...
    
*/

public class AccountLookupController{
    
    public list<account> accountList{get;set;} // create account list for show records on page
    public string filterText{get;set;}
    
   public AccountLookupController(){
       accountList = new list<account>();
       String txt = ApexPages.currentPage().getParameters().get('srchTxt');
       filterText = txt != null && txt.trim().length() > 0 ? txt : '';
       filterAccount();
    }
    
    public void filterAccount(){
        try{
            accountList = new list<account>();
            set<string> rcTypesSet;
            
            string columnName = ApexPages.currentPage().getParameters().get('rctype');
            
            string query = 'select id,Name,Type from account where RecordType.developerName = \'Buyer_Holding_Group\'';
            filterText = filterText.trim();
            string tempFText = filterText ;
            
            if(filterText!='*' && filterText!='' && !(filterText.contains('%'))){
              filterText+='%';
              query +=' and name like \''+filterText+'\'';   
            }else if(filterText.contains('%')){
              query +=' and name like \''+filterText+'\'';  
            }
            query +=' order By name';
            
            filterText  = tempFText;
            
            for(account accRc : DataBase.Query(query)){
                accountList.add(accRc);
            }
          }catch(exception e){
              Apexpages.addMessage(new apexPages.Message(apexPages.severity.Error,e.getMessage()));
              
          }  
    }
    
    
}