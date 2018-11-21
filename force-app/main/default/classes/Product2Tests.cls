@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @testSetup static void SetupTestData (){
    	
        TestDataFactory.InsertTestData(1);
        
    }//SetupTestData
    
    private TestMethod static  void Product2Extension_UnitTest(){
        
        setupTestData();
        Test.setCurrentPage(Page.Product2New);
        Test.startTest();
        	List<Product2> lProducts = [select id, name ,Family from Product2  ];
        	string strFamily = lProducts[0].family;
        	//delete lProducts;
            ApexPages.StandardController sc = new ApexPAges.StandardController(new Product2(name='a'));
            Product2Extension ext = new Product2Extension(sc);
        	ext.getFamilyOptions();
        	ext.save();
        	System.AssertEquals(Constants.DEFAULT_ROWS,ext.productsToInsert.size());
            ext.addRows();
        	System.AssertEquals(Constants.DEFAULT_ROWS*2,ext.productsToInsert.size());
        
        	for (integer i=0;i<Constants.DEFAULT_ROWS;i++){
                
                Product2Extension.ProductWrapper objPW = ext.productsToInsert[i];
                objPW.productRecord.Initial_Inventory__C = Constants.DEFAULT_ROWS;
                objPW.productRecord.Name = 'SKU' + '-Test'+i;
                objPW.productRecord.Family = strFamily ; //oP.Family;
                objPW.productRecord.isActive = true;
                objPW.pricebookEntryRecord.UnitPrice = Constants.DEFAULT_ROWS;
                
            }  
        		/*Product2Extension.ProductWrapper objPW = ext.productsToInsert[Constants.DEFAULT_ROWS];
                objPW.productRecord.Initial_Inventory__C = -10;
                objPW.productRecord.Name = oP.Name + '-T1';
                //objPW.productRecord.Family = 'ABC' ; //oP.Family;
                //objPW.productRecord.isActive = true;
                objPW.pricebookEntryRecord.UnitPrice = Constants.DEFAULT_ROWS;
        		*/
            ext.save();
        	ext.getInventory();
        	Test.stopTest();
        	List<Product2> lP = [select id, name from Product2 where id not in :lProducts ];
        	System.assertEquals(lp.size(),constants.DEFAULT_ROWS);
    }
	
    private TestMethod static void product2Trigger_UnitTest(){
         setupTestData();
         Test.startTest();
         List<Product2> lProducts = [select id, name ,Family from Product2  ];
        for (Product2 objP : lProducts){
            objP.description = objP.name;
        }
        update lProducts;
         Test.stopTest();
    }	
}