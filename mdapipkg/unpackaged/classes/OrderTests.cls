@isTest(seeAllData=false)
private class OrderTests {
	
    @testSetup static void SetupTestData(){
    	
        TestDataFactory.InsertTestData(10);
         string s = Constants.ACTIVATED_ORDER_STATUS;
          s = Constants.ERROR_MESSAGE;
          s = constants.INVENTORY_LEVEL_LOW;
        
    }//SetupTestData
	
    @isTest 
     private static void OrderUpdate_UnitTest(){
        
        setupTestData();
        Test.startTest();
        List<Order> lUpdatedOrders = [Select id, status 
                                      from Order 
                                      where status = :Constants.DRAFT_ORDER_STATUS ];
        
        ID oPBEId = [select id, PriceBookEntryId 
                   			     from OrderItem
                   				 where OrderID = :lUpdatedOrders[0].id
                   				 limit 1].PriceBookEntryId;
        
        Product2 objProduct1 = [Select id, Quantity_Ordered__c 
                               from Product2 
                               where id in (Select Product2Id from PriceBookEntry 
                                            where id = :oPBEId) limit 1];   
        
        for (Order o : lUpdatedOrders){
            o.status = Constants.ACTIVATED_ORDER_STATUS;
        }
        update lUpdatedOrders;
        Product2 objProduct2 = [Select id, Quantity_Ordered__c 
                               from Product2 
                               where id in (Select Product2Id from PriceBookEntry 
                                            where id = :oPBEId) limit 1];   
		
        TestDataFactory.VerifyQuantityOrdered(objProduct1, objProduct2, Constants.DEFAULT_ROWS);
		Test.stopTest();        
    }//OrderUpdate_UnitTest 
    
    @isTest
    private static void  orderExtension_unitTest(){
        
        setupTestData();
        Account testAccount = new Account();
		testAccount.Name = 'test';
		insert testAccount;
        // Instantiate the Pricebook2 record first, setting the Id
		Pricebook2 standardPricebook = new Pricebook2(
				Id = Test.getStandardPricebookId(),
				IsActive = true
	     );

        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        system.debug('constants.STANDARD_PRICEBOOK_ID ' + constants.STANDARD_PRICEBOOK_ID);
        List<PriceBookEntry> l = [select id,pricebook2.id, Product2Id , UnitPrice ,isActive, Product2.isActive ,
                                     Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                                     from PriceBookEntry 
                                     where pricebook2.id =  :constants.STANDARD_PRICEBOOK_ID
                                     //and isActive = true
                                     //and Product2.isActive = true
                                    ];
        	system.debug('PriceBookEntry ' + l);
            orderExtension ext = new orderExtension(new apexPages.standardController(new Order()));
            ext.orderRecord.AccountId = testAccount.Id;
            ext.orderRecord.EffectiveDate = system.today();
            ext.orderRecord.Status = constants.DRAFT_ORDER_STATUS;
            ext.orderRecord.Pricebook2Id = constants.STANDARD_PRICEBOOK_ID;
            ext.orderItemList[0].Quantity = 1; 
            ext.orderItemList[0].UnitPrice = 1;
            ext.orderItemList[1].Quantity = 2;
            ext.orderItemList[1].UnitPrice = 2;
            ext.OnFieldChange();
            ext.save();
        	ext.selectedFamily=Constants.select_one;
        	ext.SelectFamily();
        	ext.first();
        	ext.next();
        	ext.last();
        	ext.previous();
        	ext.GetTotalPages();
        	ext.GetPageNumber();
        	ext.getPageSize();
        	ext.GetFamilyOptions();
        	ext.GetHasNext();
        	ext.GetHasPrevious();
        	ext.selectedFamily='Side';
        	ext.SelectFamily();
            List<Order> savedOrders = [SELECT Id, (SELECT Quantity, UnitPrice FROM OrderItems ORDER BY Quantity) FROM Order WHERE AccountId = :testAccount.Id];
            system.assert( savedOrders.size() == 1 );
            system.assert( savedOrders[0].OrderItems.size() == 2 );
            system.assert( savedOrders[0].OrderItems[0].Quantity == 1 && savedOrders[0].OrderItems[0].UnitPrice == 1);
            system.assert( savedOrders[0].OrderItems[1].Quantity == 2 && savedOrders[0].OrderItems[1].UnitPrice == 2);
        
            ext = new orderExtension(new apexPages.standardController(savedOrders[0]));
            ext.orderItemList[0].Quantity = 0;
            ext.OnFieldChange();
            ext.save();
        
        	
            savedOrders = [SELECT Id, (SELECT Quantity, UnitPrice FROM OrderItems ORDER BY Quantity) FROM Order WHERE AccountId = :testAccount.Id];
            system.assert( savedOrders.size() == 1 );
            system.assert( savedOrders[0].OrderItems.size() == 1 );
            system.assert( savedOrders[0].OrderItems[0].Quantity == 2 && savedOrders[0].OrderItems[0].UnitPrice == 2);
            
            delete savedOrders;
            ext.save();
        	delete testAccount;
           
    	}//OrderExtn 
    
    private TestMethod static void AnnouncementQueueableTest(){
        
	        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
            ConnectApi.AnnouncementInput a =  new ConnectApi.AnnouncementInput();
            ConnectApi.MessageBodyInput msgInput= new ConnectApi.MessageBodyInput();
            	ConnectApi.TextSegmentInput inputSegment = new ConnectApi.TextSegmentInput();
            	inputSegment.text =   Constants.INVENTORY_LEVEL_LOW;
            msgInput.messageSegments = new List<ConnectApi.TextSegmentInput>{inputSegment};
            a.body = msgInput;
            a.expirationDate =  DateTime.Now().addDays(1);
            a.isArchived = false;
            a.sendEmails = false;
            toPost.add(a);
        
        Test.startTest();
        AnnouncementQueueable q = new AnnouncementQueueable();
        q.toPost=toPost;
        System.enqueueJob(q);
        Test.stopTest();
    }
}