install.packages('rsconnect')
rsconnect::setAccountInfo(name='dipanjanabardhan',
                          token='6F4FDF39D089B1DCAD0824F5F9CD1447',
                          secret='4tmvzhtSKPqmz5cAdZ39koBl/NbkhMNyO1ycpHc3')
library(rsconnect)
rsconnect::deployApp()
