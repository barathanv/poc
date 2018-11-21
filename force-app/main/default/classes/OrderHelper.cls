public without sharing class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    /*public static void AfterUpdate1(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == 'Activation' && oldList[i].Status != 'Activate' ){
                orderIds.add(newList[i].Id);
            }
        }
    } */
    
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds);

    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
			Map<ID,Product2> productMap = new Map<ID,Product2>(); 
            List<ID> lProductID  = new List<ID>();
        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
			for ( OrderItem oi : [
                    SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity
                    FROM OrderItem
                    WHERE OrderId in :activatedOrderIds
                ]){
                    lProductID.add(oi.Product2Id);
                }
        //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value	
	       productMap = new Map<ID,Product2>([select Id, Quantity_Ordered__c
                                                 from Product2 where Id in :lProductID
                                                ]);
        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
		   AggregateResult[] groupedResults = [SELECT Product2Id, Sum(Quantity)
												FROM OrderItem
                    							WHERE OrderId in :activatedOrderIds
												GROUP BY Product2Id
                                              ];
            for (AggregateResult ar : groupedResults) {
            	System.debug('Product2Id' + ar.get('Product2Id'));
                Id tempProductID = (Id)ar.get('Product2Id');
                Product2 op = productMap.get(tempProductID);
                op.Quantity_Ordered__c +=  (Decimal)ar.get('expr0') ;
                productMap.put(tempProductID,op);
            	//System.debug('Average amount' + ar.get('expr0'));
            }	
                    
        //ToDo: Perform an update on the records in the productMap
           List<Product2> lPUpdate = productMap.values();
           update(lPUpdate);
    }

}