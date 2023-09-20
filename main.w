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

/* Works in 0.26.5
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
*/

/* Same as above for latest version */
interface CustomBucket extends std.IResource { 
  inflight store(data: str): void;
  inflight check(data: str): bool;
}

class CustomStorage impl CustomBucket {
    bucket: cloud.Bucket;
    init() { // Create a (cloud) bucket
      this.bucket = new cloud.Bucket() as "custom_bucket";
    }
    pub inflight store(data: str): void { // create a custom store method to upload a couple example files to the bucket
      let file = "upload";

      this.bucket.put("${file}.txt", data);
      this.bucket.putJson("${file}.json", Json { "data": data});
    }
    pub inflight check(data:str):bool { // another custom method to check the content of a given file(s)
        
        if (this.bucket.exists(data)) {

            let fileData = "placeholder";
            
            if (this.bucket.tryGet(data) == nil) { // still figuring it out why JS doesn't let me check for a nil/nul variable :D 
                let fileData = this.bucket.getJson(data);
                log("a JSON file");
                assert(fileData.get("data") == "It works!");
            } else {
                assert(fileData == "It works!");
                log("a TXT file");
            }
        } else {
            log("File ${data} not found");
            return false;
        }
    }
}

let custom_bucket: CustomBucket = new CustomStorage() as "CustomBucket"; // Create a bucket object from the CustomStorage class

let put_smth = inflight (b: CustomBucket): void => {
    // log("This is the puth_smth inflight method");
    b.store("It works!");
    b.check("upload.txt");
    b.check("upload.json");
    b.check("unexistent.file");
};

new cloud.Function(inflight () => {
    // log("This is the wrapper function");
    put_smth(custom_bucket);
});