bring cloud;
bring aws;
bring "./classes.w" as customThings;

let b = new cloud.Bucket() as "the_bucket"; // create a bucket

let bucket_funct = new cloud.Function(inflight (data: str) => { // create a sample function
    b.put("some-file.txt","some text inside");
    
    log("added ${data}");
}) as "bucket_function";

let s = new cloud.Secret(name: "username1") as "the_secret";

let secret_funct = new cloud.Function(inflight () => {
    let sVal = s.value();
    b.put("${sVal}.txt",sVal);
    log("added secret");
}) as "secret_function";

let custom_bucket: customThings.CustomBucket = new customThings.CustomStorage() as "CustomBucket"; // create a bucket object from the CustomStorage class

let fput = new cloud.Function(inflight () => {
    custom_bucket.store("It works!");
}) as "put";

if let putFn = aws.Function.from(fput) {
    putFn.addPolicyStatements(
        aws.PolicyStatement {
            actions: ["s3:PutObject*"],
            effect: aws.Effect.ALLOW,
            resources: ["*"] // could not yet find a way of referencing the target bucket ARN
        }
    );
}

let fcheck = new cloud.Function(inflight () => { // declare the "check" function
    custom_bucket.check("upload.txt");
    custom_bucket.check("upload.json");
    custom_bucket.check("unexistent.file");
}) as "check";