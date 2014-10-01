supervised_clust <- function(label, variable){
  
  library(party)
  library(plyr)
  
  if(!is.numeric(variable)){
    variable <- factor(variable)
  }
  
  df <- data.frame(label = factor(label), variable)
  
  tree <- partykit::ctree(label ~ variable, data = df)
  
  df$variable_clus <- predict(tree, newdata = df, type ="node")
  df$variable_clus <- factor(df$variable_clus)
  
  levels(df$variable_clus) <- paste("CAT", seq(length(levels(df$variable_clus))), sep = "_")
  
  df2 <- as.data.frame.matrix(table(df$variable, df$variable_clus))
  
  if(is.numeric(variable)){
    res <- llply(df2, function(x) c(min = min(as.numeric(rownames(d)[x!=0])),
                                    max = max(as.numeric(rownames(d)[x!=0]))))
    
    cod <- ldply(res, function(x) data.frame(x[[1]],x[[2]]))
    names(cod) <- c("Cluster", "Min", "Max")
    
  } else{
    res <- llply(df2, function(x) rownames(df2)[x!=0])
    cod <- ldply(df2, function(x) data.frame(rownames(df2)[x!=0]))
    names(cod) <- c("Cluster", "Element")
    
  }
 
  list(variable_clus = df$variable_clus, cod = cod, cod2 = res)
}

