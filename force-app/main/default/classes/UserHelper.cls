public with sharing class UserHelper {
    /**
     * Retrieves the details of a "login as" user session within the last 24 hours.
     *
     * @return SubstituteUserWrapper containing the details of the "login as" user session.
     */
    public static SubstituteUserWrapper getSubstituteUserDetails() {
        // Query to find any AuthSession with the specified conditions within the last 24 hours
        List<AuthSession> authSessions = [
            SELECT Id, UsersId, LoginHistoryId
            FROM AuthSession
            WHERE
                CreatedDate >= :DateTime.now().addHours(-24)
                AND SessionType = 'SubstituteUser'
                AND UsersId = :UserInfo.getUserId()
        ];

        if (authSessions.isEmpty()) {
            return new SubstituteUserWrapper(null, null);
        }

        // Collect all relevant LoginHistory IDs from the AuthSessions
        Set<Id> loginHistoryIds = new Set<Id>();
        for (AuthSession session : authSessions) {
            loginHistoryIds.add(session.LoginHistoryId);
        }

        // Query all relevant LoginHistory records
        Map<Id, LoginHistory> loginHistoryMap = new Map<Id, LoginHistory>(
            [
                SELECT Id, UserId
                FROM LoginHistory
                WHERE Id IN :loginHistoryIds
            ]
        );

        // Iterate through AuthSessions and check against LoginHistory records
        for (AuthSession session : authSessions) {
            LoginHistory loginHistory = loginHistoryMap.get(session.LoginHistoryId);
            if (loginHistory?.UserId != session?.UsersId) {
                // Return the result with the user ID of the person logging into someone else's account
                return new SubstituteUserWrapper(loginHistory.UserId, session.UsersId);
            }
        }

        // Return default result indicating no "login as" session found
        return new SubstituteUserWrapper(null, null);
    }

    /**
     * Wrapper class to encapsulate the results of the login as user details.
     */
    public class SubstituteUserWrapper {
        public Boolean isSubstitutingAsAnotherUser { get; set; }
        public Id substituteUserId { get; set; }
        public Id loggedInUserId { get; set; }

        /**
         * Constructs an instance of the SubstituteUserWrapper class.
         *
         * @param substituteUserId The Id of the user that is logging into someone else's user account.
         * @param loggedInUserId The Id of the user who is logged in.
         */
        public SubstituteUserWrapper(Id substituteUserId, Id loggedInUserId) {
            this.substituteUserId = substituteUserId;
            this.loggedInUserId = loggedInUserId;
            this.isSubstitutingAsAnotherUser = substituteUserId != loggedInUserId ? true : false;
        }
    }
}