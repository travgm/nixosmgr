type commands =
    | Clean
    | Optimise
    | Usage
    | Rebuild of string
    | Package of string * string

val process_commands : commands list -> unit
