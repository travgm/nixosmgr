open Base
open Stdio

module type PackageManager = sig
  val add_package : config:string -> string -> int option
end

module AddPackage : PackageManager = struct
  let get_package_index (lines : string list) : int option =
    let rec parse_line idx in_users in_pkgs = function
      | [] -> None
      | line :: rest ->
        let module S = String in
        let len = String.length line - 1 in
        if (not in_users)
           && String.is_substring ~substring:"users.users" line
           && Char.equal (S.get line len) '{'
        then parse_line (idx + 1) true in_pkgs rest
        else if in_users
                && (not in_pkgs)
                && String.is_substring ~substring:"packages" line
                && Char.equal (S.get line len) '['
        then parse_line (idx + 1) in_users true rest
        else if in_users && in_pkgs
        then Some idx
        else parse_line (idx + 1) in_users in_pkgs rest
    in
    parse_line 0 false false lines
  ;;

  let parse_config (config : string) (package : string) =
    let pkg = [ package ] in
    let lines = In_channel.read_lines config in
    let insert_pkg = get_package_index lines in
    match insert_pkg with
    | Some 0 ->
      print_endline "No user package found";
      None
    | Some x ->
      let beg, tail = List.split_n lines x in
      let new_lines = beg @ pkg @ tail in
      Out_channel.write_lines config new_lines;
      Some x
    | None ->
      print_endline "Failed to find package index";
      None
  ;;

  let add_package ~config package = parse_config config package
end
