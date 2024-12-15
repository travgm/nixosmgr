let running_message message = 
  print_endline ("\027[32mrunning command =>\027[0m " ^ message)

let success_message message = 
  print_endline ("\027[32m✓ =============\027[0m " ^ message)

let error_message message = 
  print_endline ("\027[31m✗ =============\027[0m " ^ message)

