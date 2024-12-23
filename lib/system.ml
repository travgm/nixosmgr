open Base
open Unix

type commands =
  | Clean
  | Optimise
  | Usage
  | Rebuild of string
  | Package of string * string

let cmd_success status =
  match status with
  | WEXITED 0 -> true
  | _ -> false
;;

let command_to_s = function
  | Clean -> [ "nix-collect-garbage"; "nix-collect-garbage -d"; "rm -rf ~/.cache/nix" ]
  | Optimise -> [ "nix-store --optimise" ]
  | Usage -> [ "nix path-info -Sh /run/current-system" ]
  | Rebuild config -> [ "sudo nixos-rebuild switch -I nixos-config=" ^ config ]
  | Package (_, _) -> []
;;

let process_commands (cmd : commands list) =
  let run_command cmd =
    match cmd with
    | Package (config, package) ->
      let _ =
        Nix_printer.running_message ("Adding package " ^ package ^ " to " ^ config);
        ignore (Add_package.AddPackage.add_package ~config package);
        Nix_printer.success_message "Finished running command!"
      in
      ()
    | cmd ->
      let cmd_s = String.concat ~sep:" && " (command_to_s cmd) in
      Nix_printer.running_message cmd_s;
      let status = system cmd_s in
      if cmd_success status
      then (
        Nix_printer.success_message "Finished running command!";
        ())
      else (
        Nix_printer.error_message "Error running command!";
        ())
  in
  List.iter ~f:run_command cmd
;;
