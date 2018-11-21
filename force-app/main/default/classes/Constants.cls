public class Constants {

    @TestVisible
    public static final Integer DEFAULT_ROWS = 5;
    @TestVisible
    public static final string SELECT_ONE  = System.Label.Select_one;
	@TestVisible public static final String INVENTORY_LEVEL_LOW  = System.Label.Inventory_Level_Low;    
    @TestVisible public static  final List<Schema.PicklistEntry> PRODUCT_FAMILY = Product2.Family.getDescribe().getPicklistValues();  // {get;private set;}
    @TestVisible public static final string DRAFT_ORDER_STATUS = 'Draft';
    @TestVisible public static final string ACTIVATED_ORDER_STATUS = 'Activated';
    @TestVisible public static final string ERROR_MESSAGE  = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    @TestVisible public static final string INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements' ; // {get;private set;}
    @TestVisible public static final string STANDARD_PRICEBOOK_ID = '01s5A000005I7QeQAK';
    
    /*
    public List<Schema.PicklistEntry> getProduct_Family(){
        Schema.DescribeFieldResult dfr = Product2.Family.getDescribe();
        return dfr.getPicklistValues();
    }*/
    
     
}