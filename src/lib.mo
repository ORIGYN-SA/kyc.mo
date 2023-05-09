import Types "types";

import D "mo:base/Debug";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Prim "mo:prim";

import Candy "mo:candy_0_2_0/types";
import Conversion "mo:candy_0_2_0/conversion";

import Map "mo:map_7_0_0/Map";

class kyc(_init_args : Types.KYCClassInitArgs){ 

  let time = Option.get(_init_args.time, Time.now);
  let timeout = Option.get(_init_args.timeout, 60 * 60 *24 * 1000000000 : Int); 

  public func kyc_request_hash(x : Types.KYCRequest) : Nat {

    var accountHash = Principal.hash(x.canister);

    accountHash +%= switch(x.counterparty){
      case(#ICRC1(account)){
        var val = Principal.hash(account.owner);
        let amount = switch(account.subaccount){
          case(null) 0 : Nat32;
          case(?val) Conversion.candySharedToNat32(#Bytes(val));
        };
        val +%= amount;
       val;
      };
      case(#Account(val)){
        Conversion.candySharedToNat32(#Bytes(val));
      };
      case(#Extensible(val)){
        Nat32.fromNat(Candy.hashShared(val));
      }
    };

    let tokenHash = switch(x.token){
      case(null) 0 : Nat32;
      case(?val){
        switch(val){
          case(#IC(token)){
            var hash = Principal.hash(token.canister);
            hash +%= Prim.intToNat32Wrap(Option.get(token.id, 0));
            hash
          };
          case(#Extensible(token)){
            Nat32.fromNat(Candy.hashShared(token));
          };
        }
      }
    };

   /*  let amountHash = switch(x.amount){
      case(null) 0 : Nat32;
      case(?val){
        Prim.intToNat32Wrap(val);
      }
    }; */

    accountHash +%= tokenHash;
   /*  accountHash +%= amountHash; */

    /* switch(x.extensible){
      case(null){};
      case(?val){
        accountHash +%= Nat32.fromNat(Candy.hashShared(val));
      };
    }; */

    Nat32.toNat(accountHash);
  };

  public func kyc_request_eq(x : Types.KYCRequest, y : Types.KYCRequest) : Bool {
    let canister_result = (x.canister == y.canister);
    if(canister_result == false) return false;

    let account_result = switch(x.counterparty, y.counterparty){
      case(#ICRC1(x), #ICRC1(y)){
        x.owner == y.owner and x.subaccount == y.subaccount;
      };
      case(#Account(x), #Account(y)){
        x == y;
      };
      case(#Extensible(x), #Extensible(y)){
        Candy.eqShared(x,y);
      };
      case(_, _){
        return false;
      }
    };
    if(account_result == false) return false;

    let token_result = switch(x.token, y.token){
      case(null, null) true;
      case(?x, ?y){
        switch(x, y){
          case(#IC(x), #IC(y)) x.canister == y.canister and x.id == y.id;
          case(#Extensible(x), #Extensible(y)) Candy.eqShared(x, y);
          case(_,_) false;
        };
      };
      case(_,_) false;
    };

    if(token_result == false) return false;

    /* switch(x.amount, y.amount){
      case(null, null) return true;
      case(?x, ?y){
       return x == y
      };
      case(_, _) return false;
    }; */

    /* switch(x.extensible, y.extensible){
      case(null, null) return true;
      case(?x, ?y){
       return Candy.eqShared(x, y);
      };
      case(_, _) return false;
    }; */

    return true;
  };

  public let kyc_map_tool = (kyc_request_hash, kyc_request_eq);

  let cache = Option.get(_init_args.cache, Map.new<Types.KYCRequest, Types.KYCResultFuture>());

  public func get_kyc_from_cache(request : Types.KYCRequest) : ?Types.KYCResultFuture{
    D.print("getting cache" # debug_show(request));
    let ?x =  Map.get<Types.KYCRequest, Types.KYCResultFuture>(cache, kyc_map_tool, request) else{
      D.print("not found cache");
      return null;
    } ;
    D.print("testing cache timeout " # debug_show((x.timeout, time())));
    if(time() > x.timeout){
      D.print("cache timeout " # debug_show((x.timeout, time())));
      Map.delete(cache, kyc_map_tool, request);
      return null;
    };
    D.print("found cache" # debug_show(x));
    ?x;
  };

  public func run_kyc(request : Types.KYCRequest, callback: ?Types.KYCRequestCallBack) : async* Result.Result<Types.RunKYCResult, Text> {

    //check cache
     D.print("in run_kyc class");
    let kyc_canister : Types.Service = actor(Principal.toText(request.canister));

    

    let ?x = get_kyc_from_cache(request) else {
      let result = try{

         D.print("about to await");
        await kyc_canister.icrc17_kyc_request({
            counterparty = request.counterparty;
            token = request.token;
            amount =request.amount;
            extensible = request.extensible;
          });
    
      } catch (err){
        D.print("an error " # Error.message(err));
        return #err(Error.message(err));
      };

      //only cache Passing kyc
      if(result.kyc == #Pass and result.aml == #Pass){
        let store : Types.KYCResultFuture = {result = result; timeout =  time() + timeout};
        D.print("putting cache" # debug_show((request, store)));
        ignore Map.put(cache, kyc_map_tool, request, store);
      };

      let ?a_callback = callback else return #ok({did_async = true; result = result});
      a_callback(result);

      return #ok({did_async = true;result = result});
    };

    //cached doesn't call callback
    return #ok({did_async = false;result = x.result});
  };

  public func notify(request : Types.KYCRequest, usage: Types.KYCNotification) : async* () {

    //deduct from cache
    switch(usage.amount, get_kyc_from_cache(request)){
      case(?amount, ?a_cache){
        switch(a_cache.result.amount){
          case(null){};
          case(?val){
            let remaining = if(val > amount){
              val - amount;
            } else {
              //used it all
              0
            };
            D.print("fond remaining" # debug_show(remaining));

            let replaceCache = {
              a_cache with 
              result = {a_cache.result with amount = ?remaining}};

            D.print("updating cache to " # debug_show(replaceCache));

            ignore Map.put(cache, kyc_map_tool, request, replaceCache);
          };
        };
      };
      case(_,_){
        D.print("didn't find cache to update" # debug_show(usage.amount, get_kyc_from_cache(request), request));
      };
    };

    D.print("about to send notification");
    let kyc_canister : Types.Service = actor(Principal.toText(request.canister));


    D.print("sending but not awaiting");
    //send notification
    let result = kyc_canister.icrc17_kyc_notification({
      counterparty = request.counterparty;
      extensible = request.extensible;
      amount = usage.amount;
      token = request.token;
      metadata = usage.metadata;
    });

    return;
  };
};
