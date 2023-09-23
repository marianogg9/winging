bring cloud;

class CustomStore {
    bucket: cloud.Bucket;

    init() {
        this.bucket = new cloud.Bucket() as "custom_store_bucket";
    }

    inflight store(data: str) {
        this.bucket.put("data.txt", data);
    }
}

let customStore = new CustomStore() as "CustomStore object";

new cloud.Function(inflight () => {
    customStore.store("alguna");
}) as "custom_function";