import Types "../src/types";

import D "mo:base/Debug";

shared (deployer) actor class kyc_service(a_counter : ?Nat) = this {

  var counter = switch(a_counter){
    case(null) 0;
    case(?val) val;
  };

  public shared func icrc17_kyc_request(request : Types.KYCCanisterRequest) : async Types.KYCResult {

    if(counter == 0){
      D.trap("Counter is 0");
    };


    D.trap("Nothing handled");
    return {kyc = #Fail; aml = #Fail; token = null; amount = null; message=?"nothing handled"};
  };

}