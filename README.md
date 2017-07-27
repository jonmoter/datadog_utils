# datadog_utils
Ruby scripts useful for going through data in datadog

At the moment, all the scripts are run via rake tasks:

```
$ rake -T
rake metrics:count              # Count up information about metrics [MATCH, LIMIT, MIN_SIZE]
rake metrics:download           # Download metrics to data subdirectory
rake monitor:get[id]            # Download monitor from datadog (by id)
rake monitor:get_all            # Download all monitors from datadog
rake monitor:refresh[name]      # Download monitor from datadog (by filename)
rake monitor:update[name]       # Update datadog monitor (by filename)
rake screenboard:get[id]        # Download screenboard from datadog (by id)
rake screenboard:get_all        # Download all screenboards from datadog
rake screenboard:refresh[name]  # Download screenboard from datadog (by filename)
rake screenboard:update[name]   # Update datadog screenboard (by filename)
rake tags:count                 # Count up the number of tags used
rake tags:download              # Download tag data to temp files
rake timeboard:get[id]          # Download timeboard from datadog (by id)
rake timeboard:get_all          # Download all timeboards from datadog
rake timeboard:refresh[name]    # Download timeboard from datadog (by filename)
rake timeboard:update[name]     # Update datadog timeboard (by filename)
```

You'll need to copy `.env.example` to `.env`, and fill it out with your Datadog
API keys to run the scripts.
