import Types "../src/types";

import D "mo:base/Debug";
import Principal "mo:base/Principal";

shared (deployer) actor class kyc_service(a_scenario : ?Nat) = this {

  var scenario = switch(a_scenario){
    case(null) 0;
    case(?val) val;
  };

  var counter = 0;
  var notification_counter = 0;

  public query(msg) func get_counter() : async Nat{
    return counter;
  };

  public query(msg) func get_notification_counter() : async Nat{
    return notification_counter;
  };

  public shared func icrc17_kyc_request(request : Types.KYCRequest) : async Types.KYCResult {
    counter += 1;
    if(scenario == 0){
      switch(request.counterparty){
        case(#ICRC1(account)){
          if(account.owner == Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai") and account.subaccount == null){
            scenario += 1;
            return {kyc = #Pass; aml = #Pass; token = null; amount = null; message=?"pass"}
          };
        };
        case(_){
          return {kyc = #Fail; aml = #Fail; token = null; amount = null; message=?"fail"};
        }
      };
    };

    if(scenario == 1){
      switch(request.counterparty){
        case(#ICRC1(account)){
          if(account.owner == Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai") and account.subaccount == null){
            scenario += 1;
            return {kyc = #Pass; aml = #Pass; token = null; amount = null; message=?"pass"}
          };
        };
        case(_){
          return {kyc = #Fail; aml = #Fail; token = null; amount = null; message=?"fail"};
        }
      };
    };

    if(scenario == 2){
      switch(request.counterparty){
        case(#ICRC1(account)){
          if(account.owner == Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai") and account.subaccount == null){
            scenario += 1;
            return {kyc = #Pass; aml = #Pass; token = ?#IC({
              canister = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
              id = null;
              symbol = "OGY";
              decimals = 8;
              standard = #ICRC1;
              fee = ?200000
            });
            amount = ?2500000000;
            message=?"pass"
            }
          };
        };
        case(_){
          return {kyc = #Fail; aml = #Fail; token = null; amount = null; message=?"fail"};
        }
      };
    };


    D.trap("Nothing handled");
    return {kyc = #Fail; aml = #Fail; token = null; amount = null; message=?"nothing handled"};
  };


  public shared func icrc17_kyc_notification(request : Types.KYCNotification) : () {
    notification_counter += 1;
  };

}