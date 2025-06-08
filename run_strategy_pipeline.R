source("functions.R")

args = commandArgs(trailingOnly=TRUE)
data_file <- args[1]

dtt <- fread(data_file)

dt1 <- calculate_strategy(dtt) %>%
  na.omit() 

dt1[, in_pos := in_pos_base_r(dt1)]

dt_prices <- dt1[, list(date, open, close, high, low)]

dt_out <- get_strategy_positions( dt1,
                                  dt_prices,
                                  type = 'long',
                                  return_full = FALSE,
                                  cols_by = "equity",
                                  return_last_zerolen = FALSE,
                                  slippage = 0,
                                  slippage_in_pct = FALSE)

fwrite(dt_out, "dt_positions.csv")
