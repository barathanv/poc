public without sharing class ChartHelper {
	
    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        AggregateResult[] groupedResults = [SELECT Family, Sum(Quantity_Remaining__c)
												FROM Product2
                    							WHERE isActive = true
                                                and Quantity_Remaining__c > 0
												GROUP BY Family
                                              ];
            for (AggregateResult ar : groupedResults) {
            	System.debug('Product2Id' + ar.get('Family'));
               
                string  t_Name = (String)ar.get('Family') ;
                Decimal t_Val  =  Integer.valueOf(ar.get('expr0')) ;
                ChartData objData = new ChartData(t_Name,t_Val);
                cht.add(objData);
            	//System.debug('Average amount' + ar.get('expr0'));
            }	
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}