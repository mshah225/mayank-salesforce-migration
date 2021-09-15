@isTest
public class GroupFactory {
    public class DefaultGroup extends TestFactory {
        public DefaultGroup() {
            super(new Group(Name = 'TestGroupName', Type = 'Queue'));
            this.addToFieldsToIncrement('Name');
        }
    }
}
