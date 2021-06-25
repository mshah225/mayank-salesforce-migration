public class Hasher {
    public static String hashId(Id idIn) {
        Blob blobId = Blob.valueOf(idIn);
        Blob digestId = Crypto.generateDigest('SHA-512', blobId);
        String stringId = EncodingUtil.base64Encode((digestId));
        String encodedId = EncodingUtil.urlEncode(stringId, 'UTF-8');
        return encodedId;
    }
}
