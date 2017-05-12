global class StartSandboxRefresh {
    
    global void startSandboxRefreshExecution() {
        
        LeadsOperationsForSandBoxRefresh b=new LeadsOperationsForSandBoxRefresh();
        Database.executeBatch(b);
    }
}