public without sharing class Product2Extension {
	
    public class ProductWrapper{
        
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        
        public ProductWrapper(){
            productRecord = new Product2();
            productRecord.Initial_Inventory__C = 0;
            pricebookEntryRecord = new PriceBookEntry();
            pricebookEntryRecord.priceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
			pricebookEntryRecord.UnitPrice = 0;            
        }//ProductWrapper constructor
        
    }//ProductWrapper
    
    public List<ProductWrapper> productsToInsert {get;set;}
    
    public List<SelectOption> getFamilyOptions(){ 
        List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption(Constants.SELECT_ONE , Constants.SELECT_ONE ));	
        for (integer i=0; i< Constants.PRODUCT_FAMILY.size(); i++){
            options.add(new SelectOption(Constants.PRODUCT_FAMILY[i].getvalue(),Constants.PRODUCT_FAMILY[i].getlabel()));
    	}
		return options;
    } 
        
    public Product2Extension(ApexPages.StandardController controller){
        
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }
    
    

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> getInventory(){
        return ChartHelper.GetInventory(); //chtData;
    }

    public PageReference Save(){
        try {
            boolean bError = false;
            integer nAddedCount = 0;
            //insert productsToInsert;
            for (ProductWrapper objPW : productsToInsert){
                
                Savepoint sp = Database.setSavepoint();
                
                    if ( objPW.productRecord.Name != null && objPW.productRecord.Name != ''){
                                try{
                                Product2 t_objProduct = new Product2();
                                t_objProduct.Name = objPW.productRecord.Name;
                                t_objProduct.Initial_Inventory__c = objPW.productRecord.Initial_Inventory__c;
                                t_objProduct.ProductCode = objPW.productRecord.Name.replace(' ','');
                                t_objProduct.Family = objPW.productRecord.Family;
                                t_objProduct.isActive = objPW.productRecord.isActive;
                                
                                insert t_objProduct;
                                
                                PriceBookEntry t_objPBE = new PriceBookEntry();
                                t_objPBE.Pricebook2Id = objPW.pricebookEntryRecord.Pricebook2Id ;
                                t_objPBE.UnitPrice = objPW.pricebookEntryRecord.UnitPrice ;
                                t_objPBE.Product2Id = t_objProduct.id;
                                t_objPBE.isActive = objPW.productRecord.isActive;
                                
                                insert t_objPBE;
                                    nAddedCount++;
                                }
                        catch(Exception ex){
                            Database.rollback(sp);
                            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error , 'Unable to add entry for ' + objPW + ' ' + Constants.ERROR_MESSAGE));        
                            bError = true;
                        }
            	}//if ProductName is entered, try to create records
            }//for
            //If successful clear the list and display an informational message
            if (!bError && nAddedCount>0){
            	apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, nAddedCount + ' Inserted'));
            	productsToInsert.clear();   //Do not remove
            	addRows();  //Do not remove
            }//bError  
            if ( nAddedCount == 0){
            	apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR , ' Only rows with Product Name will be processed'));
            }//bError 
        } catch (Exception e){
			apexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
        }
        return null;
    }

}