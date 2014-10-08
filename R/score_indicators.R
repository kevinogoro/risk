ks <- function(score, label){
  library(ROCR)
  pred <- prediction(score,label)
  perf <- performance(pred,"tpr","fpr")
  ks <- max(abs(attr(perf,'y.values')[[1]]-attr(perf,'x.values')[[1]]))
  return(ks)
}

aucroc <- function(score, label){
  library(ROCR)
  pred <- prediction(score,label)
  perf <- performance(pred,"tpr","fpr")
  aucroc <- attr(performance(pred,"auc"),"y.values")[[1]]
  return(aucroc)
}

gini <- function(score, label){
  gini <- 2*as.numeric(aucroc(score, label)) - 1
  return(gini)
}

divergence <- function(score, label){
  s.good <- score[label == 1]
  s.bad <- score[label == 0]
  divergence <- (mean(s.good) - mean(s.bad))^2/(var(s.good) + var(s.bad))*2
  return(divergence)
}

gain <- function(score, label, percents = c(0.10, 0.20, 0.30, 0.40, 0.50)){
  library(scales)
  g <- ecdf(score[label==0])(quantile(score,percents))
  names(g) <- percent(percents)
  g
}

score_indicators <- function(score, label){ 
  
  res <- c(Size = length(score),
           Goods = length(score[label == 1]),
           Bads = length(score[label == 0]),
           BadRate = 1 - mean(label),
           KS = ks(score,label),
           AUCROC = aucroc(score,label),
           Gini = gini(score,label),
           Divergence = divergence(score,label),
           Gain = gain(score,label))
  
  res <- data.frame(t(res))
  
  names(res) <- gsub("\\.", "", names(res))
  
  return(res)
}

oddstable <- function(score, label, breaks = NULL, nclass = 10, quantile = TRUE){
  library(ggplot2)
  
  if(missing(breaks) & quantile){
    score_cat <- cut_number(score, n = nclass)
  } else if (missing(breaks) & !quantile) {
    score_cat <- cut_interval(score, n = nclass)
  } else {
    score_cat <- cut(score, breaks = breaks)
  }
  
  t <- table(score_cat, label)
  
  nclass <- dim(t)[1]
  
  N <- sum(t)
  
  ot <- data.frame(Class          = row.names(t),
                   Freq           = (t[,1]+t[,2]),
                   FreqRel        = (t[,1]+t[,2])/N,
                   FreqRelAcum    = cumsum((t[,1]+t[,2])/N),
                   FreqRelDesAcum = c(1,((sum(t[,1]+t[,2])-cumsum(t[,1]+t[,2]))/N)[1:(nclass-1)]),
                   FreqBad        = t[,1],
                   FreqRelBad     = t[,1]/sum(t[,1]),
                   FreqRelBadAcum = cumsum(t[,1]/sum(t[,1])),
                   FreqRelBadDesAcum  = c(1,((sum(t[,1])-cumsum(t[,1]))/sum(t[,1]))[1:(nclass-1)]),
                   BadRate        = t[,1]/(t[,1]+t[,2]),
                   BadRateAcum    = cumsum(t[,1])/cumsum((t[,1]+t[,2])),
                   BadRateDesacum = c((cumsum(t[,1])/cumsum((t[,1]+t[,2])))[nclass],((sum(t[,1])-cumsum(t[,1]))/(sum(t[,1]+t[,2])-cumsum(t[,1]+t[,2])))[1:(nclass-1)]),
                   Odds           =  t[,2]/ t[,1], row.names = NULL)
  
  return(ot)
}


conf_matrix <- function(pred_class, label) {
  
  t <- table( true = label, prediction = pred_class)
  # http://www2.cs.uregina.ca/~dbd/cs831/notes/confusion_matrix/confusion_matrix.html
  #                     Prediction
  #                 NegPred   PosPred
  # real NegOutcome
  # real PosOutcome
  AC <- sum(diag(t))/sum(t) #Accuracy (AC) is the he proportion of the total number of score that were correct.
  TP <- t[2,2]/sum(t[2,])   #Recall or true positive rate (TP) is the proportion of positive cases that were correctly identified. (BB)
  FP <- t[1,2]/sum(t[1,])   #False positive rate (FP) is the proportion of negatives cases that were incorrectly classified as positive
  TN <- t[1,1]/sum(t[1,])   #True negative rate (TN) is defined as the proportion of negatives cases that were classified correctly (MM)
  FN <- t[2,1]/sum(t[2,])   #False negative rate (FN) is the proportion of positives cases that were incorrectly classified as negative
  P <- t[2,2]/sum(t[,2])    #Precision (P) is the proportion of the predicted positive cases that were correct
  
  t2 <-  as.data.frame.matrix(t, row.names = NULL)
  names(t2) <- paste("pred", colnames(t))
  t2 <- cbind(class = paste("true", rownames(t)),  t2)
  
  t3 <- data.frame(term = c("Accuracy",  "Recall | True Positive rate (GG)",  "False Positive rate",
                            "True Negative rate (BB)", "False Negative rate", "Precision"),
                   term.short = c("AC", "Recall", "FP", "TN", "FN", "P"),
                   value = c(AC, TP, FP, TN, FN, P), stringsAsFactors=FALSE)
  
  response <- list(confusion.matrix = t2,
                   indicators = t3,
                   indicators.t = setNames(data.frame(t(t3$value)), t3$term.short))
  
  return(response)
}


conf_matrix_cut <- function(score, label, nbreaks = 100){
  
  cut_off_points <- as.numeric(quantile(score, seq(nbreaks-2)/(nbreaks-1)))
  
  cuts_indicators <- plyr::ldply(cut_off_points, function(cut_off_point){ # cut_off_point <- sample(cut_off_points, size = 1)
    daux <- cbind(score = cut_off_point,
                  conf_matrix(as.numeric(score > cut_off_point), label)$indicators[,c(2:3)])
    daux
  }, .progress="text")
  
  p <- ggplot2::ggplot(cuts_indicators) +
    geom_smooth(aes(score, value, color=term.short), size = 1.2) + 
    scale_y_continuous(labels = scales::percent) +
    scale_color_manual(values= c("#7CB5EC","#434348","#90ED7D","#F7A35C","#8085E9","#F15C80"))
  
  d <- reshape2::dcast(cuts_indicators, score ~ term.short)
  
  response <- list(score.values = d, plot = p)  
  return(response)
}
