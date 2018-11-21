/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup cg = new CollaborationGroup( name='TEST' + Constants.INVENTORY_ANNOUNCEMENTS , 
                                                       description=Constants.INVENTORY_ANNOUNCEMENTS,
                                                       IsArchived=false,
                                                       //CanHaveGuests=true,
                                                       CollaborationType='Public');
        return cg;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        
        List<Product2> lP2 = new List<Product2>();
        for (integer i=0;i<cnt;i++){
            
            integer nSize = Constants.PRODUCT_FAMILY.size();
            string productFamily = Constants.PRODUCT_FAMILY[i>(nsize-1) ? Math.Mod(nSize-1,i):i].getvalue();
            lP2.add(new Product2(Name='Product'+i,isActive=true,Initial_Inventory__c=10,family=productFamily));
        }
        
        return lP2;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PriceBookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PriceBookEntry> lPBE = new List<PriceBookEntry>();
        for (Product2 oP : prods){
         	lPBE.add(  new PriceBookEntry(Pricebook2Id=Constants.STANDARD_PRICEBOOK_ID,
                                		  UnitPrice = oP.Initial_Inventory__c + 1,
                                          Product2Id = oP.id,
                                          isActive = true));
        }//for
        return lPBE;             
    }//ConstructPricebookEntries

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static list<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        list<Account> lA = new list<Account>();
        for (integer i=0;i<cnt;i++){
            lA.add(new Account(Name='Account'+i));
        }
        return lA;
    }//ConstructAccounts

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static list<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        list<Contact> lC = new list<Contact>();
        integer nSize = accts.size();
        for (integer i=0;i<cnt;i++){
            lC.add(new Contact(firstName='FN'+i,lastName='LN'+i,
                               email='FN'+i+'@test.com',
                               accountId=(accts[i>(nsize-1) ? Math.Mod(nSize-1,i):i].id)));
        }//for Accounts
        return lC;
    }//ConstructContacts

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static list<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        list<Order> lO = new list<Order>();
        integer nSize = accts.size();
        for (integer i=0;i<cnt;i++){
            ID accID = accts[i>(nsize-1) ? Math.Mod(nSize-1,i):i].id;
			string accName =  accts[i>(nsize-1) ? Math.Mod(nSize-1,i):i].Name;                                 
            lO.add(new Order(accountId=(accts[i>(nsize-1) ? Math.Mod(nSize-1,i):i].id),
                   Description='Order for '+accName,status='Draft',
                   Pricebook2Id=Constants.STANDARD_PRICEBOOK_ID,          
                   ShippingStreet ='123' +' Main Street' + ' Suite' + i,
                   ShippingCity = 'Irvine',
                   ShippingState='CA' ,
                   ShippingCountry='US',
                   ShippingPostalCode='92612',
                   BillingStreet ='123' +' Main Street' + ' Suite' + i,
                   BillingCity = 'Irvine',
                   BillingState='CA' ,
                   BillingCountry='US',
                   BillingPostalCode='92612',
                   EffectiveDate = Date.Today(),
                   EndDate = Date.Today().addDays(30)
                  ));
        }//for Accounts
        return lO;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static list<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        list<OrderItem> lItem = new list<OrderItem>();
        integer nOrderSize = ords.size();
        integer nPBESize = pbes.size();
        for (integer i=0;i<cnt;i++){
            ID t_orderID = ords[i>(nOrderSize-1) ? Math.Mod(nOrderSize-1,i):i].id;
            ID t_PBEId = pbes[i>(nPBESize-1) ? Math.Mod(nPBESize-1,i):i].Id;
            decimal productListPrice = pbes[i>(nPBESize-1) ? Math.Mod(nPBESize-1,i):i].UnitPrice;
            lItem.add(new OrderItem(OrderId=t_OrderId,
                     UnitPrice=productListPrice,
                     Quantity=Constants.DEFAULT_ROWS,
                     PriceBookEntryId=t_PBEId
                     ));
            
        }//for
        
        return lItem;
    }//ConstructOrderItems

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup cg = ConstructCollaborationGroup();
        try{insert cg;}catch(Exception ex){}
        List<Account> lA = ConstructAccounts(cnt);
        insert lA;
        List<Contact> lC = ConstructContacts(cnt,lA);
        insert lC;
		List<Product2> lP = ConstructProducts(cnt);
        insert lP;
        system.debug('TDF : LP ' + lP);
        List<PriceBookEntry> lPBE = ConstructPricebookEntries(lP);
        insert lPBE;
        system.debug('TDF : LPBE ' + lPBE);
        list<Order> lO = ConstructOrders(cnt,lA);
        insert lO;
 		list<OrderItem> lItem =  ConstructOrderItems(  cnt, lpbe , lO)   ;    
        insert lItem;
    }//InsertTestData

    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        
        System.AssertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered, updatedProduct.Quantity_Ordered__c);
        
    }//VerifyQuantityOrdered

}