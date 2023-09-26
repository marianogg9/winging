bring cloud;
bring aws;

interface CustomBucket extends std.IResource { 
  inflight store(data: str): void;
  inflight check(data: str): bool;
}

class CustomStorage impl CustomBucket {
    bucket: cloud.Bucket;
    
    init() { // Create a (cloud) bucket
      this.bucket = new cloud.Bucket() as "custom-bucket";
    }
    
    pub inflight store(data: str): void { // create a custom store method to upload a couple example files to the bucket
      let file = "upload";

      this.bucket.put("${file}.txt", data);
      this.bucket.putJson("${file}.json", Json { "data": data});
    }
    
    pub inflight check(data:str): bool { // another custom method to check the content of a given file(s)
        
        if (this.bucket.exists(data)) { // check if the file exists in the bucket

            let fileData = "";

            try {
                let fileData = this.bucket.getJson(data);
                assert(fileData.get("data") == "It works!");
                log("a JSON file");
            } catch e {
                if e.contains("is not a valid JSON") {
                    let fileData = this.bucket.get(data);
                    assert(fileData == "It works!");
                    log("a TXT file");
                } else {
                    log(e);
                }
            }

        } else { // if it doesn't exist, log an error
            log("File ${data} not found");
        }
    }
}