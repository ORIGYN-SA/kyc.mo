
import C "mo:matchers/Canister";
import D "mo:base/Debug";
import Blob "mo:base/Blob";
import Int "mo:base/Int";
import M "mo:matchers/Matchers";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Time "mo:base/Time";

import service "service_example";

import KYC "../src/";

shared (deployer) actor class test_runner() = this {

    let debug_channel = {
        throws = true;
        withdraw_detail = true;
    };

   

    let it = C.Tester({ batchSize = 8 });

    
    
    private func get_time() : Int{
        return Time.now();
    };

        

    public shared func test() : async {#success; #fail : Text} {
        
        //let Instant_Test = await Instant.test_runner_instant_transfer();

      

        let suite = S.suite("test nft", [
            S.test("testRoyalties", switch(await testProcess()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                      
           
            ]);
        S.run(suite);

        return #success;
    };

    let good_request = {
      counterparty = #ICRC1{
        owner = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        subaccount = null;
      };
      token = null;
      amount = null;
    };

    public shared func testProcess() : async {#success; #fail : Text} {
        D.print("running testProcess");

        //


        let service_actor = await service.kyc_service(null);

        let kyc = KYC.kyc({kyc_cansiter = Principal.fromActor(service_actor)});

        let result = await* kyc.run_kyc(good_request, null);


        let suite = S.suite("test kyc deposit", [

            S.test("fail good request fails", switch(result.kyc, result.aml){case(#Pass, #Pass){"expected"};case(_, _){
               "failed unexpectedly"};}, M.equals<Text>(T.text("expected"))), //ENG-1470
            
            
            
        ]);

        S.run(suite);

        return #success;
    };
    

}