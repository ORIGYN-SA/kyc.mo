import Types "../src/types";

import D "mo:base/Debug";
import Principal "mo:base/Principal";

shared (deployer) actor class kyc_service(a_counter : ?Nat) = this {

  var counter = switch(a_counter){
    case(null) 0;
    case(?val) val;
  };

  public shared func icrc17_kyc_request(request : Types.KYCRequest) : async Types.KYCResult {

    if(counter == 0){
      switch(request.counterparty){
        case(#ICRC1(account)){
          if(account.owner == Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai") and account.subaccount == null){
            return {kyc = #Pass; aml = #Pass; token = null; amount = null}
          };
        };
        case(_){
          return {kyc = #Fail; aml = #Fail; token = null; amount = null};
        }
      };
    };


    D.trap("Nothing handled");
    return {kyc = #Fail; aml = #Fail; token = null; amount = null};
  };

}