global class CMG_Revenue_Calculater_Sch implements Schedulable {
   global void execute(SchedulableContext sc) {
      CMG_Revenue_Calculater_btch b = new CMG_Revenue_Calculater_btch(); 
      database.executebatch(b,100);
   }
}