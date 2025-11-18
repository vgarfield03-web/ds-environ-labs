# Simulation-based hypothesis testing

##  Lecture summary: 

This chapter introduces model-based hypothesis testing with null and alternative hypotheses, simulation (permutation) to obtain an empirical null distribution, and interpreting p‑values. We then apply this to an ecological case study on hedgerows and bee communities, with a focus on trait differences and biodiversity metrics (α, β, γ).

###  Learning Objectives

By the end, you should be able to:

- Explain the **null** vs **alternative** model and choose a suitable **test statistic**.
- Simulate a **null distribution** and compute an **empirical p‑value**.
- Run an **A/B test** comparing two groups via permutation.
- Define and compute **alpha**, **beta**, and **gamma** diversity from sample data.
- Interpret results in an applied ecology setting (hedgerows vs controls).

###  Hypothesis testing

- **Models** are sets of assumptions about data; the question is **does the model fit?**
- **Null hypothesis**: a well‑defined probabilistic model for how data were generated; we can simulate data **under the null** to understand expected variation.  
- **Alternative hypothesis**: a different generative view; we choose a statistic whose large (or small) values favor the alternative.  
- **Assessing a model**: (1) choose a statistic; (2) simulate the statistic under the null; (3) compare the observed statistic to the simulated distribution (histogram).  
- **Conclusion**: If the observed statistic is inconsistent with the null distribution, the test **rejects the null** in favor of the alternative.  
- **p‑value**: the chance, **under the null**, of seeing the observed statistic or something **more extreme in the direction of the alternative**.

###  A/B testing
**What is A/B testing?**  
We compare outcomes between two conditions --- **A** (control; e.g., unrestored field edges) and **B** (treatment; e.g., hedgerows) --- to estimate a causal effect on a metric such as **species richness**.

**Design & notation.** Let groups be \(g\in\{A,B\}\). For site \(i\) in group \(g\), observe outcome \(Y_{ig}\) (e.g., Shannon diversity). A simple test statistic is the **difference in means**  
\[
 (T_{obs})= \bar{Y}_B - \bar{Y}_A 
\]

($\bar{Y}$ denotes average, pronouced y-bar)

**Randomization/permutation test.** To obtain a finite-sample null without distributional assumptions:

1. Compute the observed statistic ($T_{obs}$)  

2. **Shuffle** the group labels (respecting any blocks/years; see below) many times (e.g., 10,000 permutations).  

3. Recompute ($t_{sim}$) for each shuffle to form the **empirical null**, $T_{sim}$ 

4. The **two-sided p-value** is: `sum(abs(tsim) >= abs(Tobs))/nsim` or equivalently `mean(abs(T_perm) >= abs(T_obs))` (HINT: maybe it would be useful to write a function to use this euqation over and over again).

**Blocking and paired designs.** If sites are naturally paired (e.g., each hedgerow matched to a nearby control) or sampled across **years**, compute the statistic **within block/year**, then average across blocks. Permute **within** each block/year to preserve structure.


## Demo: A/B Testing with Mauna Loa CO₂

> **Goal.** Use the Mauna Loa monthly CO₂ record to run a two‑sided **A/B test** with a **permutation (randomization)** test.  
> **A** = 1960s, **B** = 2010s. Outcome: monthly change Δ ppm. We **block by month‑of‑year** to preserve seasonality.  
> Then tackle a **an in class challenge** on seasonal amplitude (per‑year max−min).



### Import CO₂ monthly data

The file is in `data/co2_mm_mlo.txt` (copied with this Rmd). We skip commented header lines and parse the monthly **average** and **de‑seasonalized** series. In this file, `-9.99` and `-0.99` flag missing metadata.


```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   year = col_double(),
##   month = col_double(),
##   decimal_date = col_double(),
##   average = col_double(),
##   deseasonalized = col_double(),
##   ndays = col_double(),
##   stdev_days = col_double(),
##   unc_month = col_double()
## )
```

```
## Rows: 809
## Columns: 8
## $ year           <dbl> 1958, 1958, 1958, 1958, 1958, 1958, 1958, 1958, 1958, 1…
## $ month          <dbl> 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8…
## $ decimal_date   <dbl> 1958.203, 1958.288, 1958.370, 1958.455, 1958.537, 1958.…
## $ average        <dbl> 315.71, 317.45, 317.51, 317.27, 315.87, 314.93, 313.21,…
## $ deseasonalized <dbl> 314.44, 315.16, 314.69, 315.15, 315.20, 316.21, 316.11,…
## $ ndays          <dbl> -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,…
## $ stdev_days     <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ unc_month      <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
```

### Create the outcome and define A/B groups

We compute **Δ ppm** month‑to‑month and subset to the **1960s** and **2010s**. We also keep `month_name` to block permutations by month (preserving seasonality).


```
## 
## A_1960s B_2010s 
##     120     120
```

### Observed effect (difference in means)

Our statistic: \(\Delta = \bar{\Delta}_{2010s} - \bar{\Delta}_{1960s}\). Positive values imply faster month‑to‑month increases in the 2010s.


```
##   T_obs 
## 0.13175
```

### Permutation test (two‑sided), **blocked by month**

We permute the **group labels within each month-of-year** to preserve seasonal structure while breaking any decade effect.


```
## [1] 0.0034
```

#### Visualize the permutation null

<img src="04-simulation-hypothesis-testing_files/figure-html/perm-plot-1.png" width="672" />
What is your conclusion? 
ANSWER... 


#### Sanity check: raw Δ distributions

<img src="04-simulation-hypothesis-testing_files/figure-html/delta-dists-1.png" width="672" />

---

### Challenge Problem — Seasonal amplitude A/B test

**Question.** Is the **seasonal amplitude** (per‑year `max(average) − min(average)`) larger in the **2010s** than in the **1960s**?

**First, make a plan:**
1) Compute yearly amplitudes.  
2) Define A (1960s years) and B (2010s years).  
3) Observed effect: mean(amplitude\_B) − mean(amplitude\_A).  
4) Permutation test at the **year level** by randomly reassigning years to A/B (keeping counts fixed).


```
## T_obs_amp 
##     0.425
```

```
## [1] 0.04
```

What is your conclusion? 
ANSWER... 

### Biodiversity metrics: α, β, γ diversity
- **Alpha (α) diversity**: **within‑site** diversity (e.g., species richness per site). It captures local diversity at the sampling unit.  

Common indices: **richness** \(S\), **Shannon** \(H'=-\sum_i p_i\ln p_i\) [@Shannon1948], **Simpson** \(1-\sum_i p_i^2\) [@Simpson1949], or **Hill numbers** \(^{q}\!D\) [@Hill1973].

- **Beta (\(\beta\)) diversity**: *compositional variation among sites* (how different communities are). The \(\alpha\)/\(\beta\)/\(\gamma\) framework was formalized by Whittaker [@Whittaker1972]. Two complementary ways to quantify \(\beta\):

Two equivalent views:
  1. **Multiplicative** (Whittaker): \(\beta_W = \dfrac{\gamma}{\bar{\alpha}}\) (or additive: \(\gamma - \bar{\alpha}\)).  
  2. **Dissimilarity/dispersion** [@Anderson2006]
  
  - Compute a site-by-site dissimilarity matrix
  - Dissimilarity \(\to\) ordination (e.g., PCoA),  
  - Compute each site's **distance to its group centroid**,  
  - Compare mean distances between groups with permutations.

- **Gamma (γ) diversity**: **regional** or pooled diversity across all sites in the study.  

**What's a dissimilarly matrix?**
A **dissimilarity matrix** (aka distance matrix) stores **pairwise differences** among *n* sites. It is an *n × n* square matrix with:

- **Zero diagonal**: distance of each site to itself is 0.  
- **Symmetry**: \(d(i,j) = d(j,i)\).  
- **Scale**: often in \([0,1]\) for indices like **Bray–Curtis** (0 = identical, 1 = completely different).

We measure abundance of three bee species at three sites:

| Species | Site1 | Site2 | Site3 |
|:-------:|:-----:|:-----:|:-----:|
| Bee_A   |   5   |   0   |   2   |
| Bee_B   |   3   |   4   |   1   |
| Bee_C   |   2   |   6   |   7   |

We’ll use **Bray–Curtis dissimilarity** between two sites \(x\) and \(y\):
\[
\mathrm{BC}(x,y) \;=\; \frac{\sum_i |x_i - y_i|}{\sum_i (x_i + y_i)} \,.
\]

|         | Site1 | Site2 | Site3 |
|:-------:|:-----:|:-----:|:-----:|
| Site1   |   0     |   0.5   |   0.5   |
| Site2   |   0.5   |   0     |   0.3   |
| Site3   |   0.5   |   0.3   |   0     |

If you ever need to calculate dissimilarity in R, use the `vegdist` function in the package `vegan`. 

**When to use which dissimilarity?**

- **Bray–Curtis** (abundances): robust, ignores joint absences, common for β‑diversity.  
- **Jaccard / Sørensen** (presence–absence): use when only detection/non-detection is reliable.  

###  Biotic homgenization and traits

**Biotic homogenization** means communities become **more similar** over space or through time (i.e., **β‑diversity decreases**). In the hedgerow context, the hypothesis is that restoration **counteracts homogenization** by creating habitat heterogeneity that supports distinct species sets across sites.

**Ecological (environmental) filtering**: abiotic and biotic conditions of a habitat *select* species/traits that can persist, favoring some strategies and excluding others. Filtering helps explain shifts in community composition and trait distributions across environments (see general synthesis in [@Legendre2012]).

- Ex: In conventional margins, frequent disturbance/resources may filter for **small, generalist, ground‑nesting** bees.  
- Restored **hedgerows** can **relax** filters, allowing a *wider trait set* and greater community heterogeneity.

**Functional Traits & Measures of Trait Diversity**

**What is a functional trait?** 
A measurable species life history or phenotypic characteristic that influences performance: **body size**, **diet breadth/specialization**, **tongue length**, **phenology**, **nesting substrate**, etc.

**Common trait diversity metrics**

- **Functional richness (FRic)** — volume of trait space occupied (convex hull) [@Villeger2008]. Usually trivially related to species richness ($\alpha$ diversity).
- **Functional evenness (FEve)** — how evenly abundances are distributed in trait space [@Villeger2008].  
- **Functional divergence (FDiv)** — degree to which abundances lie toward trait extremes [@Villeger2008].  
- **Functional dispersion (FDis)** / **Rao’s Q** — mean distance of individuals/species to the trait centroid [@Laliberte2010; @Rao1982]. Can be thought of as Functional richness but standardized for species richness.

**Interpretation guide** 

- Higher **FRic/FDis**: broader strategies; potential for complementarity.
- Higher **FEve**: reduced dominance by a single strategy; balanced species functions.  
- Higher **FDiv**: niche differentiation; extremes well represented.

**Traits as mechanisms.** Certain habitat types may shift **functional trait** composition (e.g., body size, nesting substrate, diet breadth), increasing **functional divergence** and **evenness**, which can **increase β** by promoting niche differentiation. 

**Community Nestedness vs. Turnover (Replacement)**

- **Nestedness**: communities with fewer species are **subsets** of richer ones (shared core + losses).  
  - Metric: **NODF** — Nestedness based on Overlap and Decreasing Fill [@AlmeidaNeto2008].
- **Turnover (replacement)**: differences across sites occur because **species are replaced**, not just lost.  
  - Partitioning \(\beta\) into **turnover vs. nestedness** components clarifies processes [@Baselga2010].

**Why it matters**  
- If patterns are **nested**, filters or gradients produce orderly species loss.  
- If patterns show **turnover**, environments/resources are heterogeneous; restoration may create distinct assemblages.  
- Elevated β with little nestedness \(\Rightarrow\) **replacement** is the dominant driver.

---


## Discussion & Reflection: Ponisio et al. (2016): On-farm habitat restoration counters biotic homogenization in intensively managed agriculture 

<div style="margin: 1rem 0;">
<embed src="readings/reading-Ponisio2016.pdf" type="application/pdf" width="100%" height="800px" />
</div>

### Pre‑class reflection (please submit short answers via canvas)

Use short, evidence-based answers linked to the paper. Where asked, reference the figure, method, or statistic that supports your claim. We will cover these same questions during our in class discussion.


1. **Core claim in one sentence.** In your own words, summarize the central finding about hedgerows and community heterogeneity (β-diversity). What *measure* of β-diversity did the study use, and why was a null-model correction necessary?

2. **Trait perspective.** Define *trait evenness, dispersion, divergence* and explain what it means that mature hedgerows increased all three relative to controls. 

3. **Ecological filter.** What evidence suggests conventional field margins act as an ecological filter on bee traits (e.g., body size, specialization, nesting)? Give one concrete example reported in the paper. 

4. **Nestedness vs. replacement.** What does it mean that communities were generally *not* nested (NODF), and why does this support species **replacement** as a source of β-diversity? How might a nested pattern have changed the interpretation?

5. **Measurement choice.** The paper uses an **abundance-based dissimilarity** estimator that accounts for unseen species and then computes **multivariate dispersion** (distance to group centroid) as β-diversity. Explain why naïvely comparing average pairwise dissimilarities could be misleading without these controls.

---


## Lab: Do the bees at hedgerows and weedy field margins (controls) have the same distribution of traits? 




 Our goal is to reproduce the analyses in Ponisio et al. 2016, On‐farm habitat restoration counters biotic homogenization in intensively managed agriculture, [Ponisio et al. 2016](https://doi.org/10.1111/gcb.13117)

Specifically, we are going to reproduce Figure 4 panels a-b, where we examine whether the bees at hedgerows (restored habitat) and controls (weedy field margins that would have a hedgerow) are random subset of the species pool.

**Conservation/ecology Topics** 

- Become familiar with different metrics of biodiversity, including trait diversity.  
- Become familiar with the concept of biotic homogenization. 

**Computational Topics**

- Join data 
- Make histograms 
- Subsetting, reshaping data using dplyr (more practice)
- Use logical indexing to subset data (more practice)
- Write functions (more practice)
- Write for loops (more practice)

**Statistical Topics**

- AB testing, simulating the null hypothesis 
- Calculate empirical p-values
- Hypothesis testings: reject or accept our null hypothesis

-------------------------------




```
## 'data.frame':	186842 obs. of  40 variables:
##  $ UniqueID      : chr  "M2007SR1Barger_001" "M2007SR1Barger_002" "M2007SR1Barger_003" "M2007SR1Barger_004" ...
##  $ TempID        : int  17590 17591 17598 17599 17600 17601 17602 17603 17604 17605 ...
##  $ Sex           : chr  "m" "f" "m" "f" ...
##  $ Determiner    : chr  "M. Hauser" "R. Thorp" "R. Thorp" "R. Thorp" ...
##  $ DateDetermined: chr  "4/12/11" "7/2/08" "7/2/08" "7/2/08" ...
##  $ Collector     : chr  "K. Ullmann" "K. Ullmann" "K. Ullmann" "K. Ullmann" ...
##  $ NetNumber     : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ Notes         : chr  "" "" "" "" ...
##  $ BeeNonbee     : chr  "non-bee" "bee" "bee" "bee" ...
##  $ Order         : chr  "Diptera" "Hymenoptera" "Hymenoptera" "Hymenoptera" ...
##  $ Family        : chr  "Syrphidae" "Halictidae" "Megachilidae" "Apidae" ...
##  $ Genus         : chr  "Eupeodes" "Lasioglossum" "Megachile" "Ceratina" ...
##  $ SubGenus      : chr  "" "(Dialictus)" "" "" ...
##  $ Species       : chr  "fumipennis" "incompletum" "gentilis" "acantha" ...
##  $ SubSpecies    : chr  "" "" "" "" ...
##  $ PlantGenus    : chr  "Brassica" "Brassica" "Marrubium" "Marrubium" ...
##  $ PlantSpecies  : chr  "sp." "sp." "vulgare" "vulgare" ...
##  $ Date          : chr  "4/24/07" "4/24/07" "4/24/07" "4/24/07" ...
##  $ SampleRound   : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ SiteStatus    : chr  "control" "control" "control" "control" ...
##  $ NetPan        : chr  "net" "net" "net" "net" ...
##  $ StartTime     : chr  "15:14:00" "15:14:00" "15:14:00" "15:14:00" ...
##  $ EndTime       : chr  "17:21:00" "17:21:00" "17:21:00" "17:21:00" ...
##  $ TempStart     : num  26.4 26.4 26.4 26.4 26.4 ...
##  $ TempEnd       : num  24.9 24.9 24.9 24.9 24.9 ...
##  $ WindStart     : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ WindEnd       : num  1.7 1.7 1.7 1.7 1.7 1.7 1.7 1.7 1.7 1.7 ...
##  $ SkyStart      : chr  "clear" "clear" "clear" "clear" ...
##  $ SkyEnd        : chr  "clear" "clear" "clear" "clear" ...
##  $ WeatherNotes  : chr  "" "" "" "" ...
##  $ Site          : chr  "Barger" "Barger" "Barger" "Barger" ...
##  $ Country       : chr  "USA" "USA" "USA" "USA" ...
##  $ State         : chr  "CA" "CA" "CA" "CA" ...
##  $ County        : chr  "Yolo" "Yolo" "Yolo" "Yolo" ...
##  $ GPS           : chr  "N38 34.575 W121 49.834" "N38 34.575 W121 49.834" "N38 34.575 W121 49.834" "N38 34.575 W121 49.834" ...
##  $ Year          : int  2007 2007 2007 2007 2007 2007 2007 2007 2007 2007 ...
##  $ JulianDate    : int  114 114 114 114 114 114 114 114 114 114 ...
##  $ GenusSpecies  : chr  "Eupeodes fumipennis" "Lasioglossum (Dialictus) incompletum" "Megachile gentilis" "Ceratina acantha" ...
##  $ SiteStatusBACI: chr  "hedgerow" "hedgerow" "hedgerow" "hedgerow" ...
##  $ ypr           : int  0 0 0 0 0 0 0 0 0 0 ...
```

Each row is a uniquely identified insect specimen and all of it's attributes. If we explore the species ID-related columns in more depth, we can see that there are many different types of insects in addition to bees. There are also some specimens that have never been IDed (missed data is a blank cell in these case). 


```
##  [1] "Diptera"     "Hymenoptera" "Coleoptera"  "Hemiptera"   "Lepidoptera"
##  [6] ""            "Araneae"     "Orthoptera"  "Odonata"     "Homoptera"  
## [11] "Mantodea"
```

```
##  [1] "Syrphidae"    "Halictidae"   "Megachilidae" "Apidae"       ""            
##  [6] "Pieridae"     "Lycaenidae"   "Colletidae"   "Vespidae"     "Nymphalidae" 
## [11] "Chrysididae"  "Andrenidae"   "Hesperiidae"  "Formicidae"   "Crabronidae" 
## [16] "Tachinidae"   "Sphecidae"    "Conopidae"    "Ulidiidae"    "Cicadellidae"
## [21] "Chloropidae"  "Simuliidae"   "Melittidae"   "Pipunculidae" "Papilionidae"
```

```
##   [1] ""                                         
##   [2] "Agapostemon texanus"                      
##   [3] "Allograpta exotica"                       
##   [4] "Allograpta micrura"                       
##   [5] "Allograpta obliqua"                       
##   [6] "Anasimyia lunulatus"                      
##   [7] "Ancistrocerus catskill"                   
##   [8] "Ancistrocerus lineativentris"             
##   [9] "Ancistrocerus spilogaster"                
##  [10] "Andrena angustitarsata"                   
##  [11] "Andrena astragali"                        
##  [12] "Andrena auricoma"                         
##  [13] "Andrena caerulea"                         
##  [14] "Andrena candida"                          
##  [15] "Andrena cerasifolii"                      
##  [16] "Andrena cercocarpi"                       
##  [17] "Andrena chlorogaster"                     
##  [18] "Andrena chlorura"                         
##  [19] "Andrena cressonii infasciata"             
##  [20] "Andrena knuthiana"                        
##  [21] "Andrena melanochroa"                      
##  [22] "Andrena microchlora"                      
##  [23] "Andrena misella"                          
##  [24] "Andrena nigrocaerulea"                    
##  [25] "Andrena orthocarpi"                       
##  [26] "Andrena piperi"                           
##  [27] "Andrena scurra"                           
##  [28] "Andrena semipunctata"                     
##  [29] "Andrena sp."                              
##  [30] "Andrena subaustralis"                     
##  [31] "Andrena subchalybea"                      
##  [32] "Andrena submoesta"                        
##  [33] "Andrena w-scripta"                        
##  [34] "Anthidiellum notatum robertsoni"          
##  [35] "Anthidium illustre"                       
##  [36] "Anthidium illustre robertsoni"            
##  [37] "Anthidium manicatum"                      
##  [38] "Anthidium utahense"                       
##  [39] "Anthidium utahense robertsoni"            
##  [40] "Anthophora curta"                         
##  [41] "Anthophora edwardsii"                     
##  [42] "Anthophora urbana"                        
##  [43] "Anthophorula chionura"                    
##  [44] "Aporinellus fasciatus"                    
##  [45] "Asemosyrphus polygrammus"                 
##  [46] "Ashmeadiella aridula"                     
##  [47] "Ashmeadiella aridula astragali"           
##  [48] "Ashmeadiella bucconis denticulata"        
##  [49] "Ashmeadiella cactorum basalis"            
##  [50] "Ashmeadiella californica"                 
##  [51] "Ashmeadiella gilletti"                    
##  [52] "Ashmeadiella salviae basalis"             
##  [53] "Ashmeadiella timberlakei"                 
##  [54] "Ashmeadiella timberlakei solida"          
##  [55] "Atalopedes campestris"                    
##  [56] "Atilides halesus"                         
##  [57] "Battus philenor"                          
##  [58] "Belomicrus sericeum"                      
##  [59] "Bembix americana"                         
##  [60] "Bombus"                                   
##  [61] "Bombus californicus"                      
##  [62] "Bombus crotchii"                          
##  [63] "Bombus melanopygus"                       
##  [64] "Bombus vandykei"                          
##  [65] "Bombus vosnesenskii"                      
##  [66] "Brephidium exilis"                        
##  [67] "Calliopsis boharti"                       
##  [68] "Calliopsis fracta"                        
##  [69] "Calliopsis hesperia equina"               
##  [70] "Calliopsis scitula"                       
##  [71] "Calliopsis scutellaris"                   
##  [72] "Callophrys augustinus"                    
##  [73] "Ceratina acantha"                         
##  [74] "Ceratina arizonensis"                     
##  [75] "Ceratina dallatorreana"                   
##  [76] "Ceratina nanula"                          
##  [77] "Ceratina punctigena"                      
##  [78] "Ceratina sequoiae"                        
##  [79] "Ceratina timberlakei"                     
##  [80] "Ceriana tridens"                          
##  [81] "Chalybion californicum"                   
##  [82] "Chelostoma phaceliae"                     
##  [83] "Chlorion aerarium"                        
##  [84] "Chrysis amala"                            
##  [85] "Chrysis scitule"                          
##  [86] "Chrysura inusitata"                       
##  [87] "Chrysura pacifica"                        
##  [88] "Chrysura sagmatis"                        
##  [89] "Coelioxys apacheorum"                     
##  [90] "Coelioxys gilensis"                       
##  [91] "Coelioxys novomexicanus"                  
##  [92] "Coelioxys octodentatus"                   
##  [93] "Coenonympha tullia"                       
##  [94] "Colias eurytheme"                         
##  [95] "Colletes fulgidus"                        
##  [96] "Colletes hyalinus"                        
##  [97] "Colletes hyalinus gaudialis"              
##  [98] "Copestylum mexicanum"                     
##  [99] "Cupido amyntula"                          
## [100] "Cylindromyia"                             
## [101] "Diadasia australis"                       
## [102] "Diadasia bituberculata"                   
## [103] "Diadasia chionura"                        
## [104] "Diadasia consociata"                      
## [105] "Diadasia diminuta"                        
## [106] "Diadasia enavata"                         
## [107] "Diadasia nigrifrons"                      
## [108] "Diadasia ochracea"                        
## [109] "Diadasia rinconis"                        
## [110] "Dianthidium pudicum"                      
## [111] "Dianthidium ulkei"                        
## [112] "Dufourea sp."                             
## [113] "Dufourea sp. 1"                           
## [114] "Ectemnius areuatus"                       
## [115] "Ectemnius spinifer"                       
## [116] "Eristalinus aeneus"                       
## [117] "Eristalis arbustorum"                     
## [118] "Eristalis hirta"                          
## [119] "Eristalis stipator"                       
## [120] "Eristalis tenax"                          
## [121] "Erynnis funeralis"                        
## [122] "Eucera actuosa"                           
## [123] "Eucera dorsata"                           
## [124] "Eucera edwardsii"                         
## [125] "Eucera frater"                            
## [126] "Eucera frater albopilosa"                 
## [127] "Eucera sp."                               
## [128] "Eucera virgata"                           
## [129] "Eumenes crucifera"                        
## [130] "Eumerus"                                  
## [131] "Eumerus strigatus"                        
## [132] "Euodynerus annulatus"                     
## [133] "Euodynerus foraminatus"                   
## [134] "Euodynerus hidalgo"                       
## [135] "Eupeodes fumipennis"                      
## [136] "Eupeodes volucris"                        
## [137] "Euxesta"                                  
## [138] "Ferdinandea"                              
## [139] "Gymnosoma"                                
## [140] "Gymnosomam"                               
## [141] "Habropoda tristissima"                    
## [142] "Halictus farinosus"                       
## [143] "Halictus ligatus"                         
## [144] "Halictus tripartitus"                     
## [145] "Hedychridium paulum"                      
## [146] "Hedychridium soliarellae"                 
## [147] "Helophilus latifrons"                     
## [148] "Heriades occidentalis"                    
## [149] "Hesperapis ilicifoliae"                   
## [150] "Hesperapis regularis"                     
## [151] "Hoplitis albifrons"                       
## [152] "Hoplitis albifrons maura"                 
## [153] "Hoplitis grinnelli"                       
## [154] "Hoplitis producta gracilis"               
## [155] "Hoplitis sambuci"                         
## [156] "Hylaeus"                                  
## [157] "Hylaeus calvus"                           
## [158] "Hylaeus conspicuus"                       
## [159] "Hylaeus episcopalis"                      
## [160] "Hylaeus leptocephalus"                    
## [161] "Hylaeus mesillae"                         
## [162] "Hylaeus rudbeckiae"                       
## [163] "Hylaeus sp."                              
## [164] "Hylaeus verticalis"                       
## [165] "Isodontia elegans"                        
## [166] "Junonia coenia"                           
## [167] "Lapposyrphus lapponicus"                  
## [168] "Lasioglossum (Dialictus)"                 
## [169] "Lasioglossum (Dialictus) brunneiventre"   
## [170] "Lasioglossum (Dialictus) diversopunctatum"
## [171] "Lasioglossum (Dialictus) impavidum"       
## [172] "Lasioglossum (Dialictus) incompletum"     
## [173] "Lasioglossum (Dialictus) knereri"         
## [174] "Lasioglossum (Dialictus) punctatoventre"  
## [175] "Lasioglossum (Dialictus) sp."             
## [176] "Lasioglossum (Dialictus) sp. BM"          
## [177] "Lasioglossum (Dialictus) tegulare group"  
## [178] "Lasioglossum (Evylaeus)"                  
## [179] "Lasioglossum (Evylaeus) diatretum"        
## [180] "Lasioglossum (Evylaeus) granosum"         
## [181] "Lasioglossum (Evylaeus) kincaidii"        
## [182] "Lasioglossum (Evylaeus) nigrescens"       
## [183] "Lasioglossum (Evylaeus) sp."              
## [184] "Lasioglossum (Evylaeus) sp. 3M"           
## [185] "Lasioglossum (Evylaeus) sp. 4"            
## [186] "Lasioglossum (Evylaeus) sp. B"            
## [187] "Lasioglossum (Evylaeus) sp. I"            
## [188] "Lasioglossum (Evylaeus) sp. P"            
## [189] "Lasioglossum diversopunctatum"            
## [190] "Lasioglossum mellipes"                    
## [191] "Lasioglossum olympiae"                    
## [192] "Lasioglossum ovaliceps"                   
## [193] "Lasioglossum punctatoventre"              
## [194] "Lasioglossum sisymbrii"                   
## [195] "Lasioglossum titusi"                      
## [196] "Leptochilus irwini"                       
## [197] "Leptochilus rufinodus"                    
## [198] "Lerodea eufala"                           
## [199] "Limentis lorquini"                        
## [200] "Lycaena helloides"                        
## [201] "Mallota sackeni"                          
## [202] "Megachile"                                
## [203] "Megachile angelarum"                      
## [204] "Megachile apicalis"                       
## [205] "Megachile brevis"                         
## [206] "Megachile coquilletti"                    
## [207] "Megachile fidelis"                        
## [208] "Megachile frugalis"                       
## [209] "Megachile gentilis"                       
## [210] "Megachile lippiae"                        
## [211] "Megachile montivaga"                      
## [212] "Megachile occidentalis"                   
## [213] "Megachile onobrychidis"                   
## [214] "Megachile parallela"                      
## [215] "Megachile prosopidis"                     
## [216] "Megachile rotundata"                      
## [217] "Megachile texana"                         
## [218] "Melissodes agilis"                        
## [219] "Melissodes communis alopex"               
## [220] "Melissodes lupinus"                       
## [221] "Melissodes robustior"                     
## [222] "Melissodes stearnsi"                      
## [223] "Melissodes tepida timberlakei"            
## [224] "Myathropa florea"                         
## [225] "Neocnemodon"                              
## [226] "Neocnemodon sp"                           
## [227] "Nomada hesperia"                          
## [228] "Nomada sp. 3"                             
## [229] "Nomada sp. 3M"                            
## [230] "Nomada sp. 5"                             
## [231] "Nomada sp. A"                             
## [232] "Nomada sp. AM"                            
## [233] "Nomada sp. CK-1"                          
## [234] "Nomada sp. CK-1M"                         
## [235] "Nomada sp. CK-2M"                         
## [236] "Nomada sp. CKM-2"                         
## [237] "Nomada sp. HS-Y-1"                        
## [238] "Odontomyia sp"                            
## [239] "Osmia"                                    
## [240] "Osmia aglaia"                             
## [241] "Osmia atrocyanea"                         
## [242] "Osmia brevis"                             
## [243] "Osmia californica"                        
## [244] "Osmia cara"                               
## [245] "Osmia coloradensis"                       
## [246] "Osmia cyanella"                           
## [247] "Osmia densa"                              
## [248] "Osmia gabrielis"                          
## [249] "Osmia gaudiosa"                           
## [250] "Osmia glauca"                             
## [251] "Osmia granulosa"                          
## [252] "Osmia laeta"                              
## [253] "Osmia lignaria propinqua"                 
## [254] "Osmia nemoris"                            
## [255] "Osmia odontogaster"                       
## [256] "Osmia pusilla"                            
## [257] "Osmia regulina"                           
## [258] "Osmia sp. CK-BR"                          
## [259] "Osmia sp. MB"                             
## [260] "Osmia sp. MD"                             
## [261] "Osmia sp. MG"                             
## [262] "Osmia sp. MJ"                             
## [263] "Osmia texana"                             
## [264] "Osmia trevoris"                           
## [265] "Palpada alhambra"                         
## [266] "Panurginus"                               
## [267] "Panurginus nigrellus"                     
## [268] "Panurginus sp."                           
## [269] "Papilio rutulus"                          
## [270] "Paragus"                                  
## [271] "Paragus haemorrhous"                      
## [272] "Paragus longistylus"                      
## [273] "Parhelophilus laetus"                     
## [274] "Peponapis pruinosa"                       
## [275] "Perdita salicis tristis"                  
## [276] "Pholisora catullus"                       
## [277] "Phyciodes mylitta"                        
## [278] "Pieris rapae"                             
## [279] "Pipiza"                                   
## [280] "Platycheirus"                             
## [281] "Platycheirus quadratus"                   
## [282] "Platycheirus stegnus"                     
## [283] "Platycheirus trichopus"                   
## [284] "Plebejus acmon"                           
## [285] "Poanes melane"                            
## [286] "Polistes aurifer"                         
## [287] "Polistes dominula"                        
## [288] "Polistes dorsalis"                        
## [289] "Pontia protodice"                         
## [290] "Prionyx attratus"                         
## [291] "Prionyx parkeri"                          
## [292] "Prionyx thomae"                           
## [293] "Protosmia rubifloris"                     
## [294] "Pyrgus communis"                          
## [295] "Pyrgus scriptura"                         
## [296] "Scaeva affinis"                           
## [297] "Sceliphron caementarium"                  
## [298] "Sphaerophoria contigua"                   
## [299] "Sphaerophoria pyrrhina"                   
## [300] "Sphaerophoria sulphuripes"                
## [301] "Sphecodes"                                
## [302] "Sphecodes sp."                            
## [303] "Sphecodes sp. 1"                          
## [304] "Sphecodes sp. 1M"                         
## [305] "Sphecodes sp. AM"                         
## [306] "Sphecodes sp. B"                          
## [307] "Sphecodes sp. D"                          
## [308] "Sphecodes sp. GM"                         
## [309] "Sphex pensylvanicus"                      
## [310] "Stelis laticincta"                        
## [311] "Stelis montana"                           
## [312] "Stenodynerus blandus"                     
## [313] "Stenodynerus claremontensis"              
## [314] "Stenodynerus cochisensis"                 
## [315] "Strymon melinus"                          
## [316] "Svastra obliqua expurgata"                
## [317] "Syritta flaviventris"                     
## [318] "Syritta pipiens"                          
## [319] "Syrphus opinator"                         
## [320] "Syrphus torvus"                           
## [321] "Tachytes distinctus"                      
## [322] "Tetraloniella pomonae"                    
## [323] "Thecophora"                               
## [324] "Toxomerus marginatus"                     
## [325] "Toxomerus occidentalis"                   
## [326] "Trichopoda"                               
## [327] "Triepeolus concavus"                      
## [328] "Triepeolus heterurus"                     
## [329] "Triepeolus melanarius"                    
## [330] "Triepeolus sp. 1"                         
## [331] "Triepeolus sp. 1M"                        
## [332] "Triepeolus sp. 2M"                        
## [333] "Triepeolus sp. A"                         
## [334] "Triepeolus sp. CK-1"                      
## [335] "Triepeolus sp. D"                         
## [336] "Triepeolus sp. EM"                        
## [337] "Triepeolus sp. FM"                        
## [338] "Triepeolus sp. GM"                        
## [339] "Triepeolus sp. nr. lestes"                
## [340] "Triepeolus subnitens"                     
## [341] "Triepeolus timberlakei"                   
## [342] "Triepeolus utahensis"                     
## [343] "Tropidia quadrata"                        
## [344] "Vanessa cardui"                           
## [345] "Xeromelecta californica"                  
## [346] "Xylocopa"                                 
## [347] "Xylocopa sonorina"                        
## [348] "Xylocopa tabaniformis orpifex"
```

### Question 1: Practicing the data subsetting tools from dplyr

- 1a. Thinking back to the dplyr tools you learned last week, subset the data to only bees. The families of bees are "Halictidae", "Megachilidae", "Apidae", "Colletidae", "Andrenidae" and "Melittidae". In addition, drop all rows without anything in the 'Species' column, otherwise we could end up with specimens only identified to Genus.  

Keep the data object named spec (i.e., don't create a new name for the subsetted data.)  

HINT: %in% maybe useful, or remember how to string together Booleans in 'dplyr'.  



- 1b. Now take a look at the site statuses, or the site "treatments",



This data include many more site treatments than we need to reproduce the publication because it includes all of the sites ever surveyed in this landscape. We don't really care about the restored sites (that is the year the hedgerow was planted so they are between a hedgerow and a control). We don't have many "natural" sites  (we couldn't find any). Forbs are hedgerows with additional forb plantings, also not what we need.  

- 1c. Subset only to mature hedgerows and controls (weedy field margins). We also only care about the "hand-netted" data (the column 'NetPan') and female bees ('Sex') (male bees don't collect pollen). Do all of this subsetting in one call to filter (you will need to combine your comparisons using & or |. 

Similar to before keep the name of the data the same. The publication also includes the maturing sites, but we are going to make our lives a little easier by keeping our analysis to two treatments. 



- 1d. Lastly, drop all the random columns we don't care about. All we want to keep are "UniqueID", "GenusSpecies", "Site", "SiteStatus" and "Year". 



### Demo: Joining data 

Next, we want to add in species traits. 



We will often find ourselves in a situation where we want to combine two datasets by some shared column. In dyplyr, mutating joins add columns from y to x, matching observations based on the keys. There are four mutating joins: the inner join, and the three outer joins.

- Inner join: An inner_join() only keeps observations from x that have a matching key in y. The most important property of an inner join is that unmatched rows in either input are not included in the result, so data is dropped. 


```
##    x y
## 1  1 2
## 2  2 2
## 3  3 2
## 4  4 2
## 5 NA 2
```

```
##   x z
## 1 1 3
## 2 2 3
```

```
## Joining with `by = join_by(x)`
```

```
## [1] 2 3
```

```
##   x y z
## 1 1 2 3
## 2 2 2 3
```

- Outer joins: The three outer joins keep observations that appear in at least one of the data frames:

- A left_join() keeps all observations in x.


```
##   x y
## 1 1 2
## 2 2 2
## 3 3 2
## 4 4 2
## 5 5 2
## 6 6 2
```

```
##   x z
## 1 1 3
## 2 2 3
## 3 3 3
## 4 4 3
## 5 5 3
## 6 6 3
```

```
## Joining with `by = join_by(x)`
```

```
## [1] 100   3
```

```
##   x y z
## 1 1 2 3
## 2 2 2 3
## 3 3 2 3
## 4 4 2 3
## 5 5 2 3
## 6 6 2 3
```

- A right_join() keeps all observations in y.


```
##   x y
## 1 1 2
## 2 2 2
## 3 3 2
## 4 4 2
## 5 5 2
## 6 6 2
```

```
##   x z
## 1 1 3
## 2 2 3
## 3 3 3
## 4 4 3
## 5 5 3
## 6 6 3
```

```
## Joining with `by = join_by(x)`
```

```
## [1] 10  3
```

```
##   x y z
## 1 1 2 3
## 2 2 2 3
## 3 3 2 3
## 4 4 2 3
## 5 5 2 3
## 6 6 2 3
```

- A full_join() keeps all observations in x and y.


```
##       x y
## 1     1 2
## 2     2 2
## 3     3 2
## 4     4 2
## 5     5 2
## 6     6 2
## 7     7 2
## 8     8 2
## 9     9 2
## 10   10 2
## 11   11 2
## 12   12 2
## 13   13 2
## 14   14 2
## 15   15 2
## 16   16 2
## 17   17 2
## 18   18 2
## 19   19 2
## 20   20 2
## 21   21 2
## 22   22 2
## 23   23 2
## 24   24 2
## 25   25 2
## 26   26 2
## 27   27 2
## 28   28 2
## 29   29 2
## 30   30 2
## 31   31 2
## 32   32 2
## 33   33 2
## 34   34 2
## 35   35 2
## 36   36 2
## 37   37 2
## 38   38 2
## 39   39 2
## 40   40 2
## 41   41 2
## 42   42 2
## 43   43 2
## 44   44 2
## 45   45 2
## 46   46 2
## 47   47 2
## 48   48 2
## 49   49 2
## 50   50 2
## 51   51 2
## 52   52 2
## 53   53 2
## 54   54 2
## 55   55 2
## 56   56 2
## 57   57 2
## 58   58 2
## 59   59 2
## 60   60 2
## 61   61 2
## 62   62 2
## 63   63 2
## 64   64 2
## 65   65 2
## 66   66 2
## 67   67 2
## 68   68 2
## 69   69 2
## 70   70 2
## 71   71 2
## 72   72 2
## 73   73 2
## 74   74 2
## 75   75 2
## 76   76 2
## 77   77 2
## 78   78 2
## 79   79 2
## 80   80 2
## 81   81 2
## 82   82 2
## 83   83 2
## 84   84 2
## 85   85 2
## 86   86 2
## 87   87 2
## 88   88 2
## 89   89 2
## 90   90 2
## 91   91 2
## 92   92 2
## 93   93 2
## 94   94 2
## 95   95 2
## 96   96 2
## 97   97 2
## 98   98 2
## 99   99 2
## 100 100 2
```

```
##       x z
## 1     1 3
## 2     2 3
## 3     3 3
## 4     4 3
## 5     5 3
## 6     6 3
## 7     7 3
## 8     8 3
## 9     9 3
## 10   10 3
## 11  100 3
## 12  101 3
## 13  102 3
## 14  103 3
## 15  104 3
## 16  105 3
## 17  106 3
## 18  107 3
## 19  108 3
## 20  109 3
## 21  110 3
## 22  111 3
## 23  112 3
## 24  113 3
## 25  114 3
## 26  115 3
## 27  116 3
## 28  117 3
## 29  118 3
## 30  119 3
## 31  120 3
## 32  121 3
## 33  122 3
## 34  123 3
## 35  124 3
## 36  125 3
## 37  126 3
## 38  127 3
## 39  128 3
## 40  129 3
## 41  130 3
## 42  131 3
## 43  132 3
## 44  133 3
## 45  134 3
## 46  135 3
## 47  136 3
## 48  137 3
## 49  138 3
## 50  139 3
## 51  140 3
## 52  141 3
## 53  142 3
## 54  143 3
## 55  144 3
## 56  145 3
## 57  146 3
## 58  147 3
## 59  148 3
## 60  149 3
## 61  150 3
## 62  151 3
## 63  152 3
## 64  153 3
## 65  154 3
## 66  155 3
## 67  156 3
## 68  157 3
## 69  158 3
## 70  159 3
## 71  160 3
## 72  161 3
## 73  162 3
## 74  163 3
## 75  164 3
## 76  165 3
## 77  166 3
## 78  167 3
## 79  168 3
## 80  169 3
## 81  170 3
## 82  171 3
## 83  172 3
## 84  173 3
## 85  174 3
## 86  175 3
## 87  176 3
## 88  177 3
## 89  178 3
## 90  179 3
## 91  180 3
## 92  181 3
## 93  182 3
## 94  183 3
## 95  184 3
## 96  185 3
## 97  186 3
## 98  187 3
## 99  188 3
## 100 189 3
## 101 190 3
## 102 191 3
## 103 192 3
## 104 193 3
## 105 194 3
## 106 195 3
## 107 196 3
## 108 197 3
## 109 198 3
## 110 199 3
## 111 200 3
```

```
## Joining with `by = join_by(x)`
```

```
## [1] 200   3
```

```
##   x y z
## 1 1 2 3
## 2 2 2 3
## 3 3 2 3
## 4 4 2 3
## 5 5 2 3
## 6 6 2 3
```

Class discussion: What type of join do we want to use to to combine the individual bee data with their traits? 

### Question 2

- 2a. Join the trait data to the individual bee data. Before joining the data, subset the trait to only the bee IDs ('GenusSpecies'), body size ('MeanITD'), floral specialization ('d').  Call the joined data spec.traits




- 2b. How many specimens are missing body size data? 
HINT: the function 'is.na()' may be useful.
EXTRA HINT: Remember the TRUEs are counted as 1s in R.



- 2c. What are the unique species names missing body size data. 


- 2d. These were relatively rare species that didn't have enough individuals to accurately estimate body size. Since we cannot do much with them, go ahead and drop them. Keep the data named spec.traits. You can use the tools we have learned in dyplyr, or just clever indexing. 

HINT: There are several ways you can drop the rows without body size data, try to avoid hard coding by copy pasting the names above. What if you added new data and wanted to re-run the code? You might miss some species if you remove them "by hand". 
EXTRA HINT: Remember that ! reverses TRUEs and FALSEs (so TRUE because FALSE and vice versa).

EXTRA EXTRA HINT: If you decide to use indexing, remember that when we index a 2D object we need to specify the indexes of the rows and columns. 


### Lab Question 3

- 3a. Use 'group_by' and 'summarize' to calculate the average body size and specialization for each site, year, site status combination. Create a new object called sys.traits



- 3b. Visualize this data with a histograms for each trait.
HINT: 'geom_histogram()' is the function that makes histograms, and it only needs an x aesthetic. 




- 3c. Describe what you see.
-- ANSWER: 

### Demo: Do the bees at hedgerows and weedy field margins (controls) have the same distribution of traits? 

- Null hypothesis: Mature hedgerows and weedy field margins (controls) support bees with similar traits, so the average trait values at hedgerows and controls is similar. 
- Alternative hypothesis: The traits at mature hedgerows and controls are not the same. 
 a) Mature hedgerows have large bees and more specialized bees than would be expected if we were sampling randomly from the regional species pool. 
 b) Controls  have smaller bees and more generalized bees than would be expected if we were sampling randomly from the regional species pool.


In the study, we tested the hypothesis above by creating a null distribution of average trait values by shuffling individuals across sites within a year. This enabled us to constrain species abundance and richness at a site while changing the identity of the individuals. Creating this type of custom null model is a bit out of the scope of what we know how to do at this point in the class, so instead we will simplify our problem by shuffling the treatment columns (mature hedgerow vs. control) across sites within a year. We will then take the average trait value for the randomized data to calculate the null expectation of controls b

**Step 0**: Let's first try to do our randomization with 1 year of data then work out way up. 


**Step 1:**Shuffle the treatment column



**Step 2:** Add the shuffled column back on to the table


**Step 3:** Take the mean of the simulated data.



### Lab Question 4

- 4a. Combine Steps 1-3 into a function: Now that we have worked through all the steps with one year, write a function that takes yr and sys.traits. Don't forget to add a nice annotation in the first few line describing what the function does. Call your function 'randomizeTraits'



- 4b.  Test out your function on a 2013. Run your function a few times. Do the mean values for the traits change? Why? 

-- ANSWER: 

### Question 5
Now we want to use our function on each year of data and save our results. The perfect situation for a for loop! 

- 5a. We will want to loop over the different years in the data. Start by creating a vector of the unique year values, call it 'years'. It would be nice to sort that vector as well so that the years are in order. 



- 5b. We will do this together in class, but first try to think it through.

The next step was a bit tricky. Unlike before in class (lab 1),  where we saved the calculations from our function into a vector, we have a dataframe  I found that the easiest way to get the column names right was to start to the first year of data, then rbind() (row bind) that to the previous year. Call your randomized data random.traits

HINT: If you do as I suggested above, you will not want to include year one in your for loop. If you have a vector x, x[-1] will drop the first element of that vector.




- 5c. Take the mean body size and specialization for each site status across years of that simulated full dataset, call it mean.years



- 5d. Now combine all the steps above into a single function called repRandomComm that:
- shuffles year 1 using the randomizeTraits function
- loops over the remaining years, row binding the data to prior year each time 
- takes the mean of the traits across years, and returns that value. 

It should have two arguments years and sys.traits

NOTE: It isn't A+ to have argument names be the same as objects in your Global Environment (can you think of why?), but sometimes argument names can just too silly if you keep trying to tweak them. Let's just be kinda A- with our naming to avoid confusion. 



Try out your function! 



- 5d. Last step! Run your randomization 100 times using a for loop. Similar to our above for loop, it was helpful to run the randomization once to get the format of the dataframe correct, then just rbind the rest of the iterations onto that. 



###  Demo: Interpreting the results
To determine whether our randomized communities have similar trait values as our observed communities, we will calculate an empirical p-value. 

Empirical p-value is calculated as the number of permutation tests with a 'more extreme' (larger or smaller, depending on the null hypothesis) observed test statistic. 

In our case, our test statistic is the mean body size (MeanITD) and mean specialization (d). 

We will start by calculating our observed test statistic for both traits. 



To visualize our observed data in relation to our randomized data, we will plot a histogram of our simulated data and add a vertical line for our observed data. 


Our observed data looks quite different than our randomized data! 

If our null hypothesis that bees at mature hedgerows and controls have similar traits is true what is the probability we get bees as small as we did at the controls? Let's calculate that probability. We need to calculate how many times we got values equal to or more extreme than our observed value when we randomized the treatments (mature hedgerow, control) in the data.

Remember that we can sum the TRUEs. 


This is our empirical p-value. That is a pretty low probability that we would get our observed statistic if the null hypothesis (the traits in mature and control communities the same) was true. 

We generally reject our null hypothesis if our p-value is less than 0.05.  We can therefore reject our null hypothesis. 

Now for the mature communities: 



Again, that is a pretty low probability that we would get our observed statistic if the null hypothesis (the traits in mature and control communities the same) was true. Our p value is again less than 0.03. We can therefore reject our null hypothesis.  

###  Question 6

Follow the same steps for the specialization (d)
- 6a. Make a histogram with the randomized and observed values.


- 6b.  What is the probability that bees at controls are as generalized (so small values of d) as what we observed, given then null hypothesis is true?


- 6c. Do we accept or reject our null hypothesis? 
-- ANSWER: 

- 6d.  What is the probability that bees at mature hedgerows are as specialized (so large values of d) as what we observed, given then null hypothesis is true?

- 6f. Do we accept or reject our null hypothesis? 

-- ANSWER: 

With these analyses we have approximated the analysis of Ponisio et al. 2016. Congratulations :) 

