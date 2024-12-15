open Cmdliner

type arg_commands =
  { arg_clean : bool
  ; arg_optimise : bool
  ; arg_usage : bool
  ; arg_rebuild : bool
  ; arg_package : string option
  }

let version = "nix-mgr 1.0.0"

let get_config () =
  match Sys.getenv_opt "NIXMGR_CONFIG" with
  | Some v -> v
  | None -> Nix_printer.error_message "NIXMGR_CONFIG not set to configuration.nix path";
            exit 1

let create_command_list { arg_clean; arg_optimise; arg_usage; arg_rebuild; arg_package } =
  let commands = [] in
  let commands = if arg_clean then System.Clean :: commands else commands in
  let commands = if arg_optimise then System.Optimise :: commands else commands in
  let commands = if arg_usage then System.Usage :: commands else commands in
  let commands = if arg_rebuild then System.Rebuild (get_config ()) :: commands else commands in
  let commands =
    match arg_package with
    | Some pkg -> System.Package (get_config (), pkg) :: commands
    | None -> commands
  in
  List.rev commands
;;

let arg_clean =
  let doc = "Clean the system (Note: This also runs rm -rf ~/.cache/nix)" in
  Arg.(value & flag & info [ "c"; "clean" ] ~doc)
;;

let arg_optimise =
  let doc = "Optimise the nix store" in
  Arg.(value & flag & info [ "o"; "optimise" ] ~doc)
;;

let arg_usage =
  let doc = "Show nix store usage" in
  Arg.(value & flag & info [ "u"; "usage" ] ~doc)
;;

let arg_rebuild =
  let doc = "Rebuild and switch system" in
  Arg.(value & flag & info [ "r"; "rebuild" ] ~doc)
;;

let arg_package =
  let doc = "Add a package to the user packages in configuration.nix" in
  Arg.(value & opt (some string) None & info [ "a"; "package" ] ~doc)
;;

let cmd =
  let doc = "Manage various nix system components" in
  let info = Cmd.info "nix-mgr" ~version ~doc in
  let make_commands arg_clean arg_optimise arg_usage arg_rebuild arg_package =
    match arg_clean, arg_optimise, arg_usage, arg_rebuild, arg_package with
    | false, false, false, false, None -> `Help (`Pager, None)
    | _ ->
      let args = { arg_clean; arg_optimise; arg_usage; arg_rebuild; arg_package } in
      let commands = create_command_list args in
      System.process_commands commands;
      `Ok ()
  in
  Cmd.v
    info
    Term.(
      ret (const make_commands $ arg_clean $ arg_optimise $ arg_usage $ arg_rebuild $ arg_package))
;;

let run = Cmd.eval cmd
