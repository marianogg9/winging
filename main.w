bring cloud;

let b = new cloud.Bucket() as "the_bucket";

let bucket_funct = new cloud.Function(inflight (data: str) => {
    b.put("some-file.txt","some text inside");
    
    log("added ${data}");
}) as "bucket_function";

let s = new cloud.Secret(name: "username") as "the_secret";

let secret_funct = new cloud.Function(inflight () => {
    let sVal = s.value();
    b.put("${sVal}.txt",sVal);
    log("added secret");
}) as "secret_function";


/* works in 0.26.5 */
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
