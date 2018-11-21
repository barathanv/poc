/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements Queueable {

    public List<ConnectApi.AnnouncementInput> toPost;
	
    //ToDo: Modify this class to implement the Queueable interface and call the postAnnouncements method
    public  void execute(QueueableContext QC){
        
        while ( toPost.size() > 0 ){
            if ( Limits.getDMLStatements() < Limits.getLimitDMLStatements()  ){
                ConnectApi.AnnouncementInput a = toPost.remove(0);
                if(!test.isRunningTest())
                	ConnectApi.Announcements.postAnnouncement('Internal', a);
            }/* else {
                break;
            }*/
        }//while
         
        
            AnnouncementQueueable q = new AnnouncementQueueable();
            if ( toPost.size() > 0 ) {//&& !test.isRunningTest() ){
                q.toPost = toPost;
		
            //ToDo: Enqueue the above instance of announcementQueueable
            //if (!test.isRunningTest())
            	System.enqueueJob(q);
        	}
        
        
    }//execute
    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    public static void PostAnnouncements(List<ConnectApi.AnnouncementInput> announcements){
        /*while ( announcements.size() > 0 ){
            if ( Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !test.isRunningTest() ){
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            } else {
                break;
            }
        }
			*/
        if ( announcements.size() > 0  ){
            AnnouncementQueueable q = new AnnouncementQueueable();
            q.toPost = announcements;
		
            //ToDo: Enqueue the above instance of announcementQueueable
            //if (!test.isRunningTest())
            	System.enqueueJob(q);
        }
    }

}