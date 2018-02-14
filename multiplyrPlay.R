library(multidplyr)
library(dplyr)
library(parallel)
library(nycflights13)

numCores <- detectCores()

cluster <- create_cluster(numCores)

system.time(
  by_dest <- flights %>%
    count(dest) %>%
    filter(n >= 365) %>%
    semi_join(flights, .) %>%
    mutate(yday = lubridate::yday(ISOdate(year, month, day))) %>%
    partition(dest, cluster = cluster)
)

system.time(  
  cluster_library(by_dest, "mgcv")
)

system.time(
  models <- by_dest %>%
    do(mod = gam(dep_delay ~ s(yday) + s(dep_time), data = .))
)


foo <- collect(models)

goo <- foo$mod[[1]]

