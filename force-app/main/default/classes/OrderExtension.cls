/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public without sharing class OrderExtension {
    
    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
	public Map<string,Map<ID,OrderItem>> mapOrderItemList {get;set;}    
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    public ApexPages.StandardSetController standardSetController;
	
    
    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        pieData = new List<chartHelper.chartData>();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
            for (OrderItem ordItem : orderRecord.OrderItems){
                orderItemMap.put(ordItem.Product2Id, ordItem);
            }//existing order
        }
        selectedFamily = '';
        getOrderItemList();
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
      private void filterOrderItems(List<PriceBookEntry> plPBD){
          
          if (plPBD != null && plPBD.size() > 0){
              system.debug('plPBD ' + plPBD);
              system.debug('mapOrderItemList ' + mapOrderItemList);
              system.debug('selectedFamily ' + selectedFamily);
              orderItemList.clear();
              if (selectedFamily != null && selectedFamily != '' && selectedFamily != Constants.SELECT_ONE){
                map<ID,OrderItem> tmapItems = mapOrderItemList.get(selectedFamily);
                if (tmapItems != null){  
                    for (PriceBookEntry p : plPBD){
                        if (tmapItems.containsKey(p.Product2Id)){
                        	orderItemList.add(tmapItems.get(p.Product2Id));
                        }
                    }
                }
              }else{
                  for (string s : mapOrderItemList.keyset()){
                        map<ID,OrderItem> tmapItems = mapOrderItemList.get(s);
                        if (tmapItems != null){  
                            for (PriceBookEntry p : plPBD){
                                if (tmapItems.containsKey(p.Product2Id)){
                                	orderItemList.add(tmapItems.get(p.Product2Id));
                                }
                            }
                        }
                  }//for
              }//else
          }//check for plPBD = null       
    }//filterOrderItems
    
    public void getOrderItemList(){
        orderItemList = new List<OrderItem>();
        mapOrderItemList = new Map<string,Map<ID,OrderItem>>();
        if ( orderRecord.Id != null ){
            for (OrderItem ordItem : orderRecord.OrderItems){
                ordItem.Product2 = new Product2(id=ordItem.Product2Id,name=ordItem.Product2.Name,
                                             Family=ordItem.product2.family
                                             );
                orderItemList.add((ordItem));
            }//existing order
        }
        else{
            orderRecord =  new Order(Id=null,AccountId=null,status='Draft');
        }
        
        for (PriceBookEntry p : [select id, Product2Id , UnitPrice ,
                                     Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                     from PriceBookEntry 
                                     where pricebook2.id = :constants.STANDARD_PRICEBOOK_ID
                                     and isActive = true
                                     and Product2.isActive = true
                                    ]){
                   OrderItem oi = new OrderItem(Id=null);
                   oi.Product2Id = p.Product2Id;
                   oi.Product2 = new Product2(id=p.Product2Id,name=p.Product2.Name,
                                             Family=p.product2.family
                                             );
                   oi.Quantity = 0;
                   oi.UnitPrice = p.UnitPrice;
                   oi.PricebookEntryId = p.id;    
                   if (!orderItemMap.containsKey(p.Product2Id))    {
                   		orderItemList.add((oi));
                   }//if not already on orderItems list, add entry
          }//for pbe
         /*standardSetController = new ApexPages.StandardSetController(
             					    [select id, Product2Id , UnitPrice ,
                                     Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                     from PriceBookEntry 
                                     where pricebook2.id = :constants.STANDARD_PRICEBOOK_ID
                                     and isActive = true
                                     and Product2.isActive = true
                                     order by Product2.Family
                                    ]);
         standardSetController.setPageSize(constants.DEFAULT_ROWS);*/
         system.debug('getOrderItemList1 : orderItemList ' + orderItemList);
         initializeMapOfItems();
         ResetSSC();
        system.debug('getOrderItemList2 : orderItemList ' + orderItemList);
    }//getOrderItemList
	
    private void initializeMapOfItems(){
        
        for (OrderItem oi : orderItemList){
            if (! mapOrderItemList.containsKey(oi.Product2.Family)){
                mapOrderItemList.put(oi.Product2.Family, new Map<ID,OrderItem>());
            }
           mapOrderItemList.get(oi.Product2.Family).put(oi.Product2Id,oi);
        }   
        //if ( selectedFamily == null || selectedFamily == '' ){
          //  orderItemList.clear();
        //}
    }
    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        total = 0;
        pieData.clear();
        Map<string,decimal> mapOrderData =  new Map<string,decimal>();
        for(String s : mapOrderItemList.keySet()){
            List<OrderItem> lOI = mapOrderItemList.get(s).values();
            for (OrderItem oi : lOI){
                {
                    total += oi.Quantity * oi.UnitPrice;
                    if (oi.Quantity > 0 &&  oi.UnitPrice > 0){
                        //mapOrderData.put(oi.Product2.Name,oi.Quantity * oi.UnitPrice);
                        pieData.add(new ChartHelper.ChartData(oi.Product2.Name,oi.Quantity * oi.UnitPrice));
                    }    
                }
            }//for each item
         }
        	
    }//onFieldChange

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        //Copy from UI List to Xfer list
        TransferItems();
        //if (selectedFamily != Constants.SELECT_ONE)
              ResetSSC();
    }
    
    public  void ResetSSC(){
        if (selectedFamily != null && selectedFamily != ''  && selectedFamily != Constants.SELECT_ONE){
        standardSetController = new ApexPages.StandardSetController(
             					    [select id, Product2Id , UnitPrice ,
                                     Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                     from PriceBookEntry 
                                     where pricebook2.id = :constants.STANDARD_PRICEBOOK_ID
                                     and isActive = true
                                     and Product2.isActive = true
                                     and Product2.family = :selectedFamily
                                     order by Product2.Name
                                    ]);
        }
        else{
        standardSetController = new ApexPages.StandardSetController(
             					    [select id, Product2Id , UnitPrice ,
                                     Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                     from PriceBookEntry 
                                     where pricebook2.id = :constants.STANDARD_PRICEBOOK_ID
                                     and isActive = true
                                     and Product2.isActive = true
                                     order by Product2.Name
                                    ]);
        }
        standardSetController.setPageSize(constants.DEFAULT_ROWS);
        standardSetController.first();
        filterOrderItems(standardSetController.getRecords());
    }
	
    public void TransferItems(){
        
         for (OrderItem oi : orderItemList){
           mapOrderItemList.get(oi.Product2.Family).put(oi.Product2Id,oi);
        }   
    }
    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
		TransferItems();
        System.savePoint sp = Database.setSavepoint();
        try{
            	 orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
			 	 upsert orderRecord;
              
                 List<OrderItem> lUpsertList = new List<OrderItem>();
                 List<OrderItem> lDeleteList = new List<OrderItem>();
                 for (string s : mapOrderItemList.keySet()){
                     for (OrderItem oi : mapOrderItemList.get(s).values()){
                         if (oi.Quantity >0){
                             if (oi.OrderId == null )
                           		oi.OrderId =  orderRecord.Id ;
                           lupsertList.add(oi) ;
                         }
                         if (oi.Quantity <= 0 && oi.id != null){
                            lDeleteList.add(oi);                         
                         }
                                
                     }
                 }
                 if (lUpsertList.size() > 0)
                 upsert lUpsertList;
              	if (lDeleteList.size() > 0)
                 Delete lDeleteList;
			
            	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ' Order created/modified successfully : ' ));            
        }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Error when saving Order info : ' + Constants.ERROR_MESSAGE + ' ' + ex.getMessage()));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
		standardSetController.first();
        filterOrderItems(standardSetController.getRecords());
    }

   
    /**
     * @name Next
     * @description
    **/
    public void Next(){
        if (standardSetController.getHasNext()){
			standardSetController.next();
        	filterOrderItems(standardSetController.getRecords());
        }
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        if (standardSetController.GetHasPrevious()){
			standardSetController.previous();
        	filterOrderItems(standardSetController.getRecords());
        }
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
		standardSetController.last();
        filterOrderItems(standardSetController.getRecords());
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }
    
	/**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        Integer totalPages = (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
        System.debug('############ totalPages: ' + totalPages);
        return totalPages;
    }
    
    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber()  ;
    }
	
    public Integer getPageSize(){
        return standardSetController.getPageSize();
    }
    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        //return null;
        List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption(Constants.SELECT_ONE , Constants.SELECT_ONE ));	
       		 for (integer i=0; i< Constants.PRODUCT_FAMILY.size(); i++){
            options.add(new SelectOption(Constants.PRODUCT_FAMILY[i].getvalue(),Constants.PRODUCT_FAMILY[i].getlabel()));
    	}
		return options; 
    }//GetFamilyOptions

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }
	
     
}