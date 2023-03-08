let aviate_labs = https://github.com/aviate-labs/package-set/releases/download/v0.1.3/package-set.dhall sha256:ca68dad1e4a68319d44c587f505176963615d533b8ac98bdb534f37d1d6a5b47

let vessel_package_set =
      https://github.com/dfinity/vessel-package-set/releases/download/mo-0.8.3-20230224/package-set.dhall

let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }


let additions =
    [
   
   { name = "candy_0_2_0"
    , repo = "https://github.com/icdevs/candy_library.git"
    , version = "0.2.0"
    , dependencies = ["base"]
   },
    
  { name = "map_7_0_0"
  , repo = "https://github.com/ZhenyaUsenko/motoko-hash-map"
  , version = "v7.0.0"
  , dependencies = [ "base"]
  },
  { name = "Map"
  , repo = "https://github.com/ZhenyaUsenko/motoko-hash-map"
  , version = "v7.0.0"
  , dependencies = [ "base"]
  },
  { name = "candid"
      , version = "v1.0.1"
      , repo = "https://github.com/gekctek/motoko_candid"
      , dependencies = ["xtendedNumbers", "base"] : List Text
      },
      { name = "candy_0_1_12"
      , version = "v0.1.12"
      , repo = "https://github.com/icdevs/candy_library"
      , dependencies = ["base"] : List Text
      },
      { name = "xtendedNumbers"
      , version = "v1.0.2"
      , repo = "https://github.com/gekctek/motoko_numbers"
      , dependencies = [] : List Text
      },
       { name = "stable_buffer"
  , repo = "https://github.com/skilesare/StableBuffer"
  , version = "v0.2.0"
  , dependencies = [ "base"]
  }
  ] : List Package
let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  aviate_labs # vessel_package_set # additions # overrides
