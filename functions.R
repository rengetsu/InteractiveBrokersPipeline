library(data.table)
library(magrittr)

in_pos_base_r <- function(dt0) {
  
  dt1 = dt0 %>%
    copy()
  
  price = dt1$close
  ex = dt1$ex
  enter = dt1$enter
  in_pos = rep(0, length(price))
  
  for(i in 2:length(price)){
    
    if(ex[i] == 1){
      in_pos[i] = 0
    }else if(enter[i] == 1 & ex[i] == 0){
      in_pos[i] = 1
    }else{
      in_pos[i] = in_pos[i-1] 
    }
    
  }
  
  return(in_pos)
  
}


get_strategy_positions <- function(dt_strategy,
                                 dt_prices,
                                 type = 'long',
                                 return_full = FALSE,
                                 cols_by = "equity",
                                 return_last_zerolen = FALSE,
                                 slippage = 0,
                                 slippage_in_pct = FALSE){
  
  slip_const <- ifelse(type == 'long', 1, -1)
  dtp <- get_positions(dt_strategy, cols_by)
  dt_positions_orig <- dtp %>%
    .[, list(
      date_start = min(date),
      date_end = max(date)),
      by = c('equity', 'phase', 'pos_type')]
  
  dt_positions_orig[, pos_mult := ifelse(pos_type == "position", 1, -1)]
  dt_positions_orig[, pos_mult := NULL]
  
  dt_positions_orig <- dt_positions_orig %>%
    copy()
  
  if(return_full){
    
    tmp <- dt_prices %>%
      .[, list(
        date,
        return = close / shift(close, fill = first(close))),
        by = 'equity']%>%
      .[dtp, on = c('equity', 'date')] %>%
      .[dt_positions_orig[, list(equity, phase, date_start)], on = c('equity', 'phase')] %>%
      .[date == date_start, return := 1] %>%
      .[, date_start := NULL]
    
    return(list(series = tmp,
                positions = dt_positions_orig[, list(equity, date_start, date_end, phase,
                                                     pos_type, return, buy_price, sell_price)]))
    
  } else {
    return(dt_positions_orig[, list(equity, date_start, date_end, phase, pos_type)])
  }
  
}

calculate_strategy <- function(dt_in1){
  
  dt_in1$ema_l <- TTR::EMA(dt_in1$close, 100)
  dt_in1$ema_s <- TTR::EMA(dt_in1$close, 40)
  dt_in1 <- cbind(dt_in1, TTR::aroon(dt_in1[, list(high, low)], n = 100))
  
  dt_in1[, ex := (ema_l > ema_s) & aroonDn > 75]
  dt_in1[, enter :=  aroonDn < 25]
  
  return(dt_in1)
  
}

get_positions <- function(dt_in, cols_by){

  res <- dt_in %>%
    copy() %>%
    .[, phase := cumsum(c(0, abs(diff(in_pos)))), by = cols_by]
  first_row <- res %>%
    .[, .SD[1], by = c(cols_by, 'phase')]
  pos_types <- first_row[, list(
    pos_type = ifelse(in_pos == 1, 'position', 'nothing')),
    by = c(cols_by, 'phase')]
  res <- rbind(
    res,
    first_row %>%
      .[, phase := phase - 1]
  ) %>%
    setorderv(c(cols_by, 'phase')) %>%
    .[phase >= 0] %>%
    pos_types[., on = c(cols_by, 'phase')]

  res

}
