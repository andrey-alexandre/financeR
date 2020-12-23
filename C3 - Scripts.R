# Creating Returns to evaluate stocks
## Data Importing
symbols <- c("SPY","EFA", "IJS", "EEM","AGG")

prices <-
getSymbols(symbols,
src = 'yahoo',
from = "2012-12-31",
to = "2017-12-31",
auto.assign = TRUE,
warnings = FALSE) %>%
map(~Ad(get(.))) %>%
reduce(merge) %>%
`colnames<-`(symbols)

## Data Transformation
asset_returns_dplyr_byhand <-
prices %>%
to.monthly(indexAt = "lastof", OHLC = FALSE) %>%
# convert the index to a date
data.frame(date = index(.)) %>%
# now remove the index because it got converted to row names
remove_rownames() %>%
gather(asset, prices, -date) %>%
group_by(asset) %>%
mutate(returns = (log(prices) - log(lag(prices)))) %>%
select(-prices) %>%
spread(asset, returns) %>%
select(date, symbols) %>%
na.omit()

asset_returns_long <-
asset_returns_dplyr_byhand %>%
gather(asset, returns, -date) %>%
group_by(asset)

## Data Visualization

### Unified Histogram
asset_returns_long <-
asset_returns_dplyr_byhand %>%
gather(asset, returns, -date) %>%
group_by(asset)

### Faceted Histogram
asset_returns_long %>%
ggplot(aes(x = returns, fill = asset)) +
geom_histogram(alpha = 0.45, binwidth = .01) +
facet_wrap(~asset) +
ggtitle("Monthly Returns Since 2013") +
theme_update(plot.title = element_text(hjust = 0.5))

### Faceted Histogram with density line
asset_returns_long %>%
ggplot(aes(x = returns)) +
geom_density(aes(color = asset), alpha = 1) +
geom_histogram(aes(fill = asset), alpha = 0.45, binwidth = .01) +
guides(fill = FALSE) +
facet_wrap(~asset) +
ggtitle("Monthly Returns Since 2013") +
xlab("monthly returns") +
ylab("distribution") +
theme_update(plot.title = element_text(hjust = 0.5))

# Building a Portifolio

## Define initial alocation
w <- c(0.25,
0.25,
0.20,
0.20,
0.10)

## Calculate portfolio returns
portfolio_returns_dplyr_byhand <-
asset_returns_long %>%
group_by(asset) %>%
mutate(weights = case_when(asset == symbols[1] ~ w[1],
asset == symbols[2] ~ w[2],
asset == symbols[3] ~ w[3],
asset == symbols[4] ~ w[4],
asset == symbols[5] ~ w[5]),
weighted_returns = returns * weights) %>%
group_by(date) %>%
summarise(returns = sum(weighted_returns))

## Visualize portfolio returns

### Scatterplot
portfolio_returns_tq_rebalanced_monthly %>%
ggplot(aes(x = date, y = returns)) +
geom_point(colour = "cornflowerblue")+
xlab("date") +
ylab("monthly return") +
theme_update(plot.title = element_text(hjust = 0.5)) +
ggtitle("Portfolio Returns Scatter") +
scale_x_date(breaks = pretty_breaks(n=6))

### Portfolio Returns Histogram
portfolio_returns_tq_rebalanced_monthly %>%
ggplot(aes(x = returns)) +
geom_histogram(binwidth = .005,
fill = "cornflowerblue",
color = "cornflowerblue") +
ggtitle("Portfolio Returns Distribution") +
theme_update(plot.title = element_text(hjust = 0.5))

### Portfolio Returns vs Assets Returns
asset_returns_long %>%
ggplot(aes(x = returns,
fill = asset)) +
geom_histogram(alpha = 0.15,
binwidth = .01) +
geom_histogram(data = portfolio_returns_tq_rebalanced_monthly,
fill = "cornflowerblue",
binwidth = .01) +
ggtitle("Portfolio and Asset Monthly Returns") +
theme_update(plot.title = element_text(hjust = 0.5))

### Portfolio Returns Histogram with Density Line
portfolio_returns_tq_rebalanced_monthly %>%
ggplot(aes(x = returns)) +
geom_histogram(binwidth = .01,
colour = "cornflowerblue",
fill = "cornflowerblue") +
geom_density(alpha = 1, color = "red") +
xlab("monthly returns") +
ylab("distribution") +
theme_update(plot.title = element_text(hjust = 0.5)) +
ggtitle("Portfolio Histogram and Density")