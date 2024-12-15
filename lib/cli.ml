open Cmdliner

type arg_commands =
  { arg_clean : bool
  ; arg_optimise : bool
  ; arg_rebuild : bool
  ; arg_package : string option
  }

let version = "1.0.0"

let create_command_list { arg_clean; arg_optimise; arg_rebuild; arg_package } =
  let commands = [] in
  let commands = if arg_clean then System.Clean :: commands else commands in
  let commands = if arg_optimise then System.Optimise :: commands else commands in
  let commands = if arg_rebuild then System.Rebuild "switch" :: commands else commands in
  let commands =
    match arg_package with
    | Some pkg -> System.Package (pkg, "user") :: commands
    | None -> commands
  in
  List.rev commands
;;

let arg_clean =
  let doc = "Clean the system" in
  Arg.(value & flag & info [ "c"; "clean" ] ~doc)
;;

let arg_optimise =
  let doc = "Optimise the nix store" in
  Arg.(value & flag & info [ "o"; "optimise" ] ~doc)
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
  let make_commands arg_clean arg_optimise arg_rebuild arg_package =
    match arg_clean, arg_optimise, arg_rebuild, arg_package with
    | false, false, false, None -> `Help (`Pager, None)
    | _ ->
      let args = { arg_clean; arg_optimise; arg_rebuild; arg_package } in
      let commands = create_command_list args in
      System.process_commands commands;
      `Ok ()
  in
  Cmd.v
    info
    Term.(
      ret (const make_commands $ arg_clean $ arg_optimise $ arg_rebuild $ arg_package))
;;

let run = Cmd.eval cmd
