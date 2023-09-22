bring cloud;

let b = new cloud.Bucket() as "the_bucket"; // create a bucket

let bucket_funct = new cloud.Function(inflight (data: str) => { // create a sample function
    b.put("some-file.txt","some text inside");
    
    log("added ${data}");
}) as "bucket_function";

let s = new cloud.Secret(name: "username") as "the_secret";

let secret_funct = new cloud.Function(inflight () => {
    let sVal = s.value();
    b.put("${sVal}.txt",sVal);
    log("added secret");
}) as "secret_function";

// Works in winglang@0.26.5
// class CustomStore {
//     bucket: cloud.Bucket;

//     init() {
//         this.bucket = new cloud.Bucket() as "custom_store_bucket";
//     }

//     inflight store(data: str) {
//         this.bucket.put("data.txt", data);
//     }
// }

// let customStore = new CustomStore() as "CustomStore object";

// new cloud.Function(inflight () => {
//     customStore.store("alguna");
// }) as "custom_function";

// Same as above for winglang@0.31.0
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
        
        if (this.bucket.exists(data)) { // check if the file exists in the bucket

            let fileData = "";

            try {
                let fileData = this.bucket.getJson(data);
                assert(fileData.get("data") == "It works!");
                log("a JSON file");
            } catch e {
                if e.contains("is not valid JSON") {
                    let fileData = this.bucket.get(data);
                    assert(fileData == "It works!");
                    log("a TXT file");
                } else {
                    log(e);
                }
            }

        } else { // if it doesn't exist, log an error
            log("File ${data} not found");
            return false;
        }
    }
}

let custom_bucket: CustomBucket = new CustomStorage() as "CustomBucket"; // create a bucket object from the CustomStorage class

let put_smth = inflight (b: CustomBucket): void => { // decouple inflight method for readability
    b.store("It works!");
};

new cloud.Function(inflight () => { // declare the "put" function
    put_smth(custom_bucket);
}) as "put";

let check_smth = inflight (b: CustomBucket): void => { // decouple inflight method (to be used in the below function) for readability
    b.check("upload.txt");
    b.check("upload.json");
    b.check("unexistent.file");
};

new cloud.Function(inflight () => { // declare the "check" function
    check_smth(custom_bucket);
}) as "check";