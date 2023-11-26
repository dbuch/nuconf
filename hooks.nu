$env.config.hooks = {
  pre_prompt: [
    (pre_prompt_hook)
  ]
  pre_execution: [{||
    null # replace with source code to run before the repl input is run
  }]
  env_change: {
    PWD: [
    ]
  }
  display_output: {||
    if (term size).columns >= 100 { table -e } else { table }
  }
}
