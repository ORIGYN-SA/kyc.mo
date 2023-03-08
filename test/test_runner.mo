
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import D "mo:base/Debug";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";

shared (deployer) actor class test_runner(tests : {
    test_runner_kyc: ?Principal; 
  }) = this {


    //D.print("tests are " # debug_show(tests));

    type test_runner_kyc_service = actor {
        test: () -> async ({#success; #fail : Text});
    };

    let it = C.Tester({ batchSize = 8 });

    public shared func test() : async Text {

      D.print("tests are " # debug_show(tests));

      
      //this is annoying, but it is gets around the "not defined bug";
      switch(tests.test_runner_kyc){
        case(null){
          D.print("skipping kyc tests" # debug_show(tests));
        };
        case(?test_runner_sale){
          D.print("running kyc tests" # debug_show(test_runner_sale));
          let KYCTestCanister : test_runner_kyc_service = actor(Principal.toText(test_runner_sale));
         
          it.should("run kyc tests", func () : async C.TestResult = async {
            //send testrunnner some dfx tokens
           
           
           

            let result = await KYCTestCanister.test();
            D.print("result");
            //D.print(debug_show(result));
            //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
            return result;
          }); 
        };
      };

      //D.print("about to run");
      await it.runAll()
      //await it.run()
    }
}