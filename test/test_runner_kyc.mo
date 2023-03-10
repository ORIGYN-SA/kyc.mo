
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

import KYCTypes "../src/types";
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

          S.test("testNotification", switch(await testNotification()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
            S.test("testRoyalties", switch(await testProcess()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),

            S.test("testCache", switch(await testCache()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
            


            
                      
           
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

    public shared func take_a_hot_minute() : async Bool{
      return true;
    };

    public shared func testProcess() : async {#success; #fail : Text} {
        D.print("running testProcess");

        //
        

        let service_actor = await service.kyc_service(null);
        

        let kyc = KYC.kyc({timeout=null; time = null; cache=null});


        // test that it can return a syncrynous call

        let result = await* kyc.run_kyc({good_request with canister = Principal.fromActor(service_actor)}, null);

        var callback_result : KYCTypes.KYCResult = {kyc = #Fail; aml = #Fail; token = null; amount = null};

        let callback = func(result : KYCTypes.KYCResult): (){
          callback_result := result;
        };
        
        //test that we can use the callback
        let call_with_callback = kyc.run_kyc({good_request with canister = Principal.fromActor(service_actor)}, ?callback);

        ignore await take_a_hot_minute();
        ignore await take_a_hot_minute();

        //test that cache is used

        let beforeCallCounter = await service_actor.get_counter();



        let suite = S.suite("test kyc deposit", [

            S.test("fail if good request fails", switch(result.kyc, result.aml){case(#Pass, #Pass){"expected"};case(_, _){
               "failed unexpectedly"};}, M.equals<Text>(T.text("expected"))), //ENG-1470
            S.test("fail if good request fails via callback", switch(result.kyc, result.aml){case(#Pass, #Pass){"expected"};case(_, _){
               "failed unexpectedly"};}, M.equals<Text>(T.text("expected"))), //ENG-1470
        ]);

        S.run(suite);

        return #success;
    };
    var current_time = 0 : Int;

    func get_current_time() : Int{
      current_time;
    };

    func add_current_time(x : Int) : (){
      current_time += x;
    };

    let two_days = 60 * 60 *24 * 1000000000 * 2;

    public shared func testCache() : async {#success; #fail : Text} {
        D.print("running testCache");

        let service_actor = await service.kyc_service(null);

        let kyc = KYC.kyc({timeout = null; time = ?get_current_time;cache=null});

        // test that it can return a syncrynous call

        let result = await* kyc.run_kyc({good_request with canister = Principal.fromActor(service_actor)}, null);

        //test that cache is used

        let beforeCallCounter = await service_actor.get_counter();

        let result2 = await* kyc.run_kyc({good_request with canister = Principal.fromActor(service_actor)}, null);

        let afterCallCounter = await service_actor.get_counter();

        add_current_time(two_days);

        let result3 = await* kyc.run_kyc({good_request with canister = Principal.fromActor(service_actor)}, null);

        let afterDaysCallCounter = await service_actor.get_counter();

        let suite = S.suite("test kyc deposit", [
            S.test("fail if cache isn't used under timeout", beforeCallCounter, M.equals<Nat>(T.nat(afterCallCounter))),
            S.test("fail if cache is used after timout", afterDaysCallCounter, M.equals<Nat>(T.nat(2)))
        ]);

        S.run(suite);

        return #success;
    };

    let a_notification = {
      counterparty = #ICRC1{
        owner = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        subaccount = null;
      };
      token = ?#IC({
        canister = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        id = null;
        symbol = "OGY";
        decimals = 8;
        standard = #ICRC1;
        fee = ?200000
      });
      amount = ?500000000;
    };

    let a_request = {
      counterparty = #ICRC1{
        owner = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        subaccount = null;
      };
      token = ?#IC({
        canister = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        id = null;
        symbol = "OGY";
        decimals = 8;
        standard = #ICRC1;
        fee = ?200000
      });
      amount = ?2500000000;
    };


    public shared func testNotification() : async {#success; #fail : Text} {
        D.print("running testNotification");

        var service_actor = await service.kyc_service(?2);

        let kyc = KYC.kyc({timeout = null; time = ?get_current_time; cache=null});

        // test that notify is called
        let beforeCallCounter = await service_actor.get_notification_counter();

        let a_request_full = {a_request with canister = Principal.fromActor(service_actor)};

        let result = await* kyc.notify(a_request_full, a_notification);

        let afterCallCounter = await service_actor.get_notification_counter();

        //test that cache is updated

        D.print("about to call KYC");

        let result3 = await* kyc.run_kyc(a_request_full, null);

         D.print("KYC done");

        let oldcache = kyc.get_kyc_from_cache(a_request_full);

        D.print("oldcache 2");

        let oldcache2 = kyc.get_kyc_from_cache(a_request_full);

        D.print("Notifying");

        let result4 = await* kyc.notify(a_request_full, a_notification);

        D.print("Getting final cache");

        let newcache = kyc.get_kyc_from_cache(a_request_full);

        let suite = S.suite("test kyc deposit", [
            S.test("fail if notification isn't initialized", beforeCallCounter, M.equals<Nat>(T.nat(0))),
            S.test("fail if notification isn't recieved", afterCallCounter, M.equals<Nat>(T.nat(1))),
            S.test("fail if cache isnt set", switch(oldcache){
              case(null) 9999999999;
              case(?val){
                switch(val.result.amount){
                  case(null) 8888888;
                  case(?val) val;
                };
              }
            }, M.equals<Nat>(T.nat(2500000000))),
            S.test("fail if cache isnt set", switch(newcache){
              case(null) 9999999999;
              case(?val){
                switch(val.result.amount){
                  case(null) 8888888;
                  case(?val) val;
                };
              }
            }, M.equals<Nat>(T.nat(2000000000))),
        ]);

        S.run(suite);

        return #success;
    };
    

}