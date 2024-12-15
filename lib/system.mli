type commands =
    | Clean
    | Optimise
    | Rebuild of string
    | Package of string * string

val process_commands : commands list -> unit
