import Types "types";

import Principal "mo:base/Principal";

class kyc(_init_args : Types.KYCClassInitArgs){ 

  let kyc_canister : Types.Service = actor(Principal.toText(_init_args.kyc_cansiter));


  public func run_kyc(request : Types.KYCRequest, callback: ?Types.KYCRequestCallBack) : async* Types.KYCResult {

    //todo: check cache
    let result = await kyc_canister.icrc17_kyc_request(request);

    let ?a_callback = callback else return result;

    a_callback(result);

    return result;
  };

};
