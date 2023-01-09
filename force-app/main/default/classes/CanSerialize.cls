public abstract class CanSerialize {
    public virtual String serialize() {
        return JSON.serialize(this);
    }
}