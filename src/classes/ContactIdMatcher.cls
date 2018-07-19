public class ContactIdMatcher {

    public ContactIdMatcher() {
        Attachment a = [SELECT Body FROM Attachment WHERE Id = '00P1h000000Sl1OEAS' LIMIT 1];
        String tmp = a.Body.toString();
        tmp += 'BANANANA';
        a.Body = Blob.valueOf(tmp);
        update a;
        System.debug(a.Body.toString());
    }
    
}