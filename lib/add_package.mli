module type PackageManager = sig
    val add_package : config:string -> string -> int option
end
  
  module AddPackage : PackageManager
