

# Risk
A R package for make simpler the validation procedures of models.

## Installation
You can install `risk` from `github` using the `devtools` package.


```r
if (!require("devtools"))
  install.packages("devtools")
devtools::install_github("jbkunst/risk")
```

## Valdation

This package assume: `1` for a good characteristic, `0` otherwise. 




```r
data(predictions)
head(predictions)
```

```
##     score label
## 1 0.20233     1
## 2 0.80582     1
## 3 0.51344     1
## 4 0.05247     0
## 5 0.32882     1
## 6 0.24568     0
```

```r
score <- predictions$score*1000
label <- predictions$label

# Some indicators
ks(score, label)
```

```
## [1] 0.2544
```

```r
aucroc(score, label)
```

```
## [1] 0.6765
```

```r
# A lot of indicators
score_indicators(score, label)
```

```
##    Size Goods Bads BadRate     KS AUCROC   Gini Divergence Gain10 Gain20
## 1 10000  6990 3010   0.301 0.2544 0.6765 0.3529     0.4077  0.191 0.3306
##   Gain30 Gain40 Gain50
## 1 0.4561 0.5764 0.6771
```

```r
# Odds Table
oddstable(score, label)
```

```
##           Class Freq FreqRel FreqRelAcum FreqRelDesAcum FreqBad FreqRelBad
## 1  [0.991,90.6] 1000     0.1         0.1            1.0     575    0.19103
## 2    (90.6,164] 1000     0.1         0.2            0.9     420    0.13953
## 3     (164,239] 1000     0.1         0.3            0.8     378    0.12558
## 4     (239,331] 1000     0.1         0.4            0.7     362    0.12027
## 5     (331,430] 1000     0.1         0.5            0.6     303    0.10066
## 6     (430,526] 1000     0.1         0.6            0.5     275    0.09136
## 7     (526,630] 1000     0.1         0.7            0.4     227    0.07542
## 8     (630,738] 1000     0.1         0.8            0.3     197    0.06545
## 9     (738,848] 1000     0.1         0.9            0.2     161    0.05349
## 10    (848,996] 1000     0.1         1.0            0.1     112    0.03721
##    FreqRelBadAcum FreqRelBadDesAcum BadRate BadRateAcum BadRateDesacum
## 1          0.1910           1.00000   0.575      0.5750         0.3010
## 2          0.3306           0.80897   0.420      0.4975         0.2706
## 3          0.4561           0.66944   0.378      0.4577         0.2519
## 4          0.5764           0.54385   0.362      0.4338         0.2339
## 5          0.6771           0.42359   0.303      0.4076         0.2125
## 6          0.7684           0.32292   0.275      0.3855         0.1944
## 7          0.8439           0.23156   0.227      0.3629         0.1742
## 8          0.9093           0.15615   0.197      0.3421         0.1567
## 9          0.9628           0.09070   0.161      0.3220         0.1365
## 10         1.0000           0.03721   0.112      0.3010         0.1120
##      Odds
## 1  0.7391
## 2  1.3810
## 3  1.6455
## 4  1.7624
## 5  2.3003
## 6  2.6364
## 7  3.4053
## 8  4.0761
## 9  5.2112
## 10 7.9286
```

```r
oddstable(score, label, breaks = 0:5*200)
```

```
##         Class Freq FreqRel FreqRelAcum FreqRelDesAcum FreqBad FreqRelBad
## 1     (0,200] 2511  0.2511      0.2511         1.0000    1201    0.39900
## 2   (200,400] 2176  0.2176      0.4687         0.7489     733    0.24352
## 3   (400,600] 2047  0.2047      0.6734         0.5313     547    0.18173
## 4   (600,800] 1813  0.1813      0.8547         0.3266     348    0.11561
## 5 (800,1e+03] 1453  0.1453      1.0000         0.1453     181    0.06013
##   FreqRelBadAcum FreqRelBadDesAcum BadRate BadRateAcum BadRateDesacum
## 1         0.3990           1.00000  0.4783      0.4783         0.3010
## 2         0.6425           0.60100  0.3369      0.4126         0.2416
## 3         0.8243           0.35748  0.2672      0.3684         0.2025
## 4         0.9399           0.17575  0.1919      0.3310         0.1620
## 5         1.0000           0.06013  0.1246      0.3010         0.1246
##    Odds
## 1 1.091
## 2 1.969
## 3 2.742
## 4 4.210
## 5 7.028
```

```r
# Confussion matrix
conf_matrix(ifelse(score<500, 0, 1), label)
```

```
## $confusion.matrix
##     prediction
## true    0    1
##    0 2231  779
##    1 3480 3510
## 
## $Accuracy
## [1] 0.5741
## 
## $`True Positive rate (BB)`
## [1] 0.5021
## 
## $`False Positive rate`
## [1] 0.2588
## 
## $`True Negative rate (MM)`
## [1] 0.7412
## 
## $`False Negative rate`
## [1] 0.4979
## 
## $Precision
## [1] 0.8184
```


## Ploting

```r
plot_roc(score, label)
```

![plot of chunk unnamed-chunk-5](./README_files/figure-html/unnamed-chunk-51.png) 

```r
plot_gain(score, label)
```

![plot of chunk unnamed-chunk-5](./README_files/figure-html/unnamed-chunk-52.png) 
