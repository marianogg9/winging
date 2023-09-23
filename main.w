bring cloud;
bring aws;
bring "./classes.w" as customThings;

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

let custom_bucket: customThings.CustomBucket = new customThings.CustomStorage() as "CustomBucket"; // create a bucket object from the CustomStorage class

let put_smth = inflight (b: customThings.CustomBucket): void => { // decouple inflight method for readability
    b.store("It works!");
};

let fput = new cloud.Function(inflight () => { // declare the "put" function
    put_smth(custom_bucket);
}) as "put";

if let putFn = aws.Function.from(fput) {
    putFn.addPolicyStatements(
        aws.PolicyStatement {
            actions: ["s3:PutObject*"],
            effect: aws.Effect.ALLOW,
            resources: ["*"] // the aws library does not yet cover buckets, nor cloud library accepts naming a bucket
        }
    );
}

let check_smth = inflight (b: customThings.CustomBucket): void => { // decouple inflight method (to be used in the below function) for readability
    b.check("upload.txt");
    b.check("upload.json");
    b.check("unexistent.file");
};

let fcheck = new cloud.Function(inflight () => { // declare the "check" function
    check_smth(custom_bucket);
}) as "check";

if let checkFn = aws.Function.from(fcheck) {
    checkFn.addPolicyStatements(
        aws.PolicyStatement {
            actions: ["s3:GetObject*"],
            effect: aws.Effect.ALLOW,
            resources: ["*"] // the aws library does not yet cover buckets, nor cloud library accepts naming a bucket
        }
    );
}