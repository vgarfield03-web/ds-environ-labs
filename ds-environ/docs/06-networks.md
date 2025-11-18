# Ecological networks



## Lecture summary

### Learning objectives
By the end of this chapter you will be able to:

- Explain how empirical interaction data become network (matrix) representations.
- Define key linear‐algebra concepts (vectors, matrices) and compute matrix and vector–matrix products.
- Distinguish common ecological network types (e.g., food webs, host–parasitoid, plant–pollinator; uni‑ vs. bipartite; weighted vs. binary; directed vs. undirected).
- Describe how networks also arise from dynamic systems models (e.g., generalized Lotka–Volterra), and how Jacobians encode interaction strengths 
- Summarize important network‑level properties (size, connectance, nestedness NODF, modularity \(Q\), specialization \(H_2'\), redundancy, complementarity).
- Compare null‑model families (equiprobable/probabilistic vs. constrained marginals) and explain why they are needed for cross‑network standardization 
- Quantify species roles using centrality (degree, betweenness, closeness, eigenvector), species strength, and specialization \(d'\)


### From data to networks

**Empirical construction**

1. **Define nodes and edges**: species (or morphospecies) are nodes; an edge represents a recorded interaction (e.g., visit, predation event, parasitism).  
2. **Sampling design**: standardized time/area, repeated censuses to reduce detection bias; record identity and (ideally) frequency/weight of interactions [@delmas2019].  
3. **Matrix assembly**: unipartite (e.g., predator–prey, directed) or bipartite (e.g., plant–pollinator). Binary vs. quantitative matrices.  
4. **Data sources**: curated repositories (e.g., **Web of Life**, **Mangal**) provide matrices + metadata and programmatic access [@weboflife; @rmangal2019].

**Common network types**

- **Food webs (trophic)**: unipartite, directed edges from resource \(\to\) consumer [@pascualdunne2006; @may1972].
- **Mutualisms** (pollination, seed dispersal): bipartite, typically undirected and weighted [@bascompte2003; @delmas2019].
- **Antagonistic bipartite**: host–parasitoid, plant–herbivore.  
- **Parasite–host, disease**: may be multilayer (hosts–vectors–pathogens).
- **Multilayer/temporal**: replicate layers across sites/seasons.

**Networks from dynamic systems models**

Many community models define **interaction strengths** explicitly. In **generalized Lotka–Volterra (GLV)** models,
\[\frac{dN_i}{dt} = r_i N_i + \sum_{j} \alpha_{ij} N_i N_j,\]
where \(\alpha_{ij}\) is the per‑capita effect of species \(j\) on \(i\). The **Jacobian** at equilibrium,
\(\mathbf{J} = [\partial f_i / \partial N_j]\), encodes local stability and can be interpreted as a **weighted, signed network** [@may1972; @allesina2012].

- **Food webs**: \(\alpha_{ij}<0\) if \(j\) consumes \(i\); \(\alpha_{ji}>0\) for the consumer’s gain.  
- **Mutualisms**: \(\alpha_{ij},\alpha_{ji}>0\) (can be saturating).  
- **Competition**: \(\alpha_{ij},\alpha_{ji}<0\).

Stability depends on **size**, **connectance**, **mean/variance** of \(\alpha_{ij}\), and the **sign structure** (e.g., predator–prey increases stability relative to random interactions) [@may1972; @allesina2012].

---

## Linear‑algebra essentials for ecological networks

**Vectors** are ordered lists of numbers. We write a row vector as
\(\mathbf{x} = (x_1, x_2, \dots, x_S)\) and a column vector as
\(\mathbf{x} = (x_1, x_2, \dots, x_S)^\top\).

**Matrices** are rectangular arrays of numbers with \(S\) rows and \(T\) columns, e.g., an interaction (adjacency) matrix \(\mathbf{A} = [a_{ij}]\).
Typical encodings:

- **Binary**: \(a_{ij}\in\{0,1\}\) indicates presence/absence of an interaction.
- **Weighted**: \(a_{ij}\ge 0\) is an interaction frequency or strength.

**Matrix multiplication** \( \mathbf{A}_{S\times T}\mathbf{B}_{T\times U} \to \mathbf{C}_{S\times U} \)

**Goal:** compute \( \mathbf{C} = \mathbf{A}\mathbf{B} \).  
**Shape check:** inner dimensions must match (here both are \(T\)). Result has shape \(S\times U\).

**Recipe (for one entry \(c_{iu}\)):**

1. Pick **row \(i\)** from \(\mathbf{A}\).
2. Pick **column \(u\)** from \(\mathbf{B}\).
3. Multiply entries **pairwise** across the \(T\) positions.
4. **Sum** those \(T\) products:  
   \[
   c_{iu} = \sum_{j=1}^{T} a_{ij}\, b_{ju}.
   \]
5. Repeat for all rows \(i=1,\dots,S\) and columns \(u=1,\dots,U\).

**Interpretation:**

- Column view: each column of \(\mathbf{C}\) is a **linear combination of the columns of \(\mathbf{A}\)** with weights from the corresponding column of \(\mathbf{B}\).  
  \(\ \ \ \ \ \ \ \ \ \ \ \ \ \mathbf{C}_{\cdot u} = \mathbf{A}\, \mathbf{b}_{\cdot u}\).
- Row view: each row of \(\mathbf{C}\) is a **linear combination of the rows of \(\mathbf{B}\)** with weights from the corresponding row of \(\mathbf{A}\).  
  \(\ \ \ \ \ \ \ \ \ \ \ \ \ \mathbf{C}_{i \cdot} = \mathbf{a}_{i \cdot}\, \mathbf{B}\).

**Worked example (tiny):**

\[
\mathbf{A}=
\begin{bmatrix}
1 & 2 & 0\\
3 & -1 & 4
\end{bmatrix}_{2\times 3},\quad
\mathbf{B}=
\begin{bmatrix}
2 & 1\\
0 & -1\\
5 & 2
\end{bmatrix}_{3\times 2}.
\]

Compute \( \mathbf{C}=\mathbf{A}\mathbf{B} \) (result is \(2\times 2\)):

- \(c_{11} = 1\cdot 2 + 2\cdot 0 + 0\cdot 5 = 2\)  
- \(c_{12} = 1\cdot 1 + 2\cdot(-1) + 0\cdot 2 = -1\)  
- \(c_{21} = 3\cdot 2 + (-1)\cdot 0 + 4\cdot 5 = 26\)  
- \(c_{22} = 3\cdot 1 + (-1)\cdot(-1) + 4\cdot 2 = 12\)

\[
\Rightarrow\ 
\mathbf{C}=
\begin{bmatrix}
2 & -1\\
26 & 12
\end{bmatrix}.
\]


## Demo: Linear algebra for networks


**Matrix multiplication in R**

```
##      [,1] [,2]
## [1,]    2   -1
## [2,]   26   12
```


**Using matrix multiple or `sweep()` for fast row/column operations**

Another common need is to multiple a matrix by a vector, for example a species occurrence matrix with a vector that weights the species in some way. We can do this three ways: 1) create a matrix from the vector of the correct dimensions and do matrix multiplication, 2) matrix-vector multiplication with "recycling", 3) or use R's function `sweep(x, MARGIN, STATS, FUN)` to the setup and multiplication for us. 

`sweep(x, MARGIN, STATS, FUN)` applies a vector (`STATS`) across **rows** (`MARGIN = 1`) or **columns** (`MARGIN = 2`) of a matrix/data frame using a function (`FUN`, default `"-"`).

We’ll use a mini **site × species** abundance table:


```
##       Bee_A Bee_B Bee_C Bee_D
## Site1     5     3     2     0
## Site2     0     4     6     1
## Site3     2     1     7     3
```
**Column operations (species across sites)**

Let's standardize (x -mean/sd) our matrix of site occurrences. 


```
##      [,1]
## [1,]    1
## [2,]    1
## [3,]    1
```

```
##           [,1]      [,2]      [,3]      [,4]
## [1,] 0.3973597 0.0000000 0.0000000 0.0000000
## [2,] 0.0000000 0.6546537 0.0000000 0.0000000
## [3,] 0.0000000 0.0000000 0.3779645 0.0000000
## [4,] 0.0000000 0.0000000 0.0000000 0.6546537
```

```
##            Bee_A      Bee_B Bee_C      Bee_D
## Site1  2.6666667  0.3333333    -3 -1.3333333
## Site2 -2.3333333  1.3333333     1 -0.3333333
## Site3 -0.3333333 -1.6666667     2  1.6666667
```

```
##            Bee_A      Bee_B      Bee_C      Bee_D
## Site1  1.0596259  0.2182179 -1.1338934 -0.8728716
## Site2 -0.9271726  0.8728716  0.3779645 -0.2182179
## Site3 -0.1324532 -1.0910895  0.7559289  1.0910895
```



```
##    Bee_A    Bee_B    Bee_C    Bee_D 
## 2.333333 2.666667 5.000000 1.333333
```

```
##    Bee_A    Bee_A    Bee_A    Bee_B    Bee_B    Bee_B    Bee_C    Bee_C 
## 2.333333 2.333333 2.333333 2.666667 2.666667 2.666667 5.000000 5.000000 
##    Bee_C    Bee_D    Bee_D    Bee_D 
## 5.000000 1.333333 1.333333 1.333333
```

```
##            Bee_A      Bee_B      Bee_C      Bee_D
## Site1  1.0596259  0.2182179 -1.1338934 -0.8728716
## Site2 -0.9271726  0.8728716  0.3779645 -0.2182179
## Site3 -0.1324532 -1.0910895  0.7559289  1.0910895
```


```
##            Bee_A      Bee_B      Bee_C      Bee_D
## Site1  1.0596259  0.2182179 -1.1338934 -0.8728716
## Site2 -0.9271726  0.8728716  0.3779645 -0.2182179
## Site3 -0.1324532 -1.0910895  0.7559289  1.0910895
```

```
## [1] TRUE
```

```
## [1] TRUE
```

**Row operations (sites across species)**

```
##           Bee_A      Bee_B     Bee_C      Bee_D
## Site1 0.5000000 0.30000000 0.2000000 0.00000000
## Site2 0.0000000 0.36363636 0.5454545 0.09090909
## Site3 0.1538462 0.07692308 0.5384615 0.23076923
```

**Column weights example (apply species weights to each row)**

```
##       Bee_A Bee_B Bee_C Bee_D
## Site1     5   1.5   3.0     0
## Site2     0   2.0   9.0     2
## Site3     2   0.5  10.5     6
```

```
## Site1 Site2 Site3 
##   9.5  13.0  19.0
```

**Other examples in networks:**

- Multiplying an **adjacency matrix** \(\mathbf{A}\) by a vector of **species abundances** \(\mathbf{N}\) yields linear combinations of partner contributions.
- \(\mathbf{A}\mathbf{1}\) (where \(\mathbf{1}\) is a vector of ones) gives **row sums** (e.g., consumer breadth “generality”), and \(\mathbf{1}^\top\mathbf{A}\) gives **column sums** (resource breadth “vulnerability”) in bipartite mutualisms [@dormann2009].
- The **two‑step reach** between nodes is encoded by \(\mathbf{A}^2\) (paths of length 2).
- In our lab we will multiple occurrence body sizes and occurrence matrices to build foodwebs for different time periods. 

### In-class challenge: Matrix & vector multiplication with plant–pollinator data

We'll use a **plant × pollinator** visitation matrix `V` (rows = plants, columns = pollinators). You'll compute:

- a matrix–vector product (expected seeds per plant)
- row/column reweighting via diagonal matrices
- plant–plant and pollinator–pollinator overlaps via matrix–matrix products
- effectiveness-weighted visits.

We will use real data on pollination efficiency of sunflower @parker1981efficient.


```
##           Bombus Melissodes Apis Andrena
## Lupine        12          7    3       4
## Sunflower      5         19    8       2
## Sage           9          4   11       6
```

```
##     Bombus Melissodes       Apis    Andrena 
##        0.8       27.8        2.5       12.6
```

```
##    Lupine Sunflower      Sage 
##       1.1       0.9       1.0
```

```
##     Bombus Melissodes       Apis      Osmia 
##        0.8        2.2        3.0        1.1
```

**Q1. Dimensions & conformability (1 min)**

- What are the dimensions of `V`?  
- What are the dimensions of `a` (treat it as a **column** vector)?  
- Is `V %*% a` conformable? What will be the shape of the result?

*Hint:* \((S\times T)(T\times 1) \to (S\times 1)\).



---

**Q2. Expected seeds per plant (matrix–vector product) (5 min)**

Assume **linearity** of contributions by visits:
\[\mathbf{s} \;=\; V \, \mathbf{a},\]
where \(V\) is plants×pollinators and \(\mathbf{a}\) is per-visit effectiveness (pollinators×1).



**Q3. Plant co-visitation overlap (matrix–matrix product) (5 min)**

Compute **plant × plant** overlap:
\[\,
\mathbf{C}_{\text{plants}} \;=\; V\,V^\top.
\]
Entry \(c_{ij}\) is the total number of visits that plants \(i\) and \(j\) share across pollinators (diagonal = total visits per plant).


---

## Core network properties (formulas, intuition, tools)

Let \(S\) be number of species (nodes) and \(L\) number of realized links.

- **Size & density**: In bipartite networks with \(S_\mathrm{plants}\times S_\mathrm{animals}\) possible links, **connectance**
  \(C = L/(S_\mathrm{plants}\,S_\mathrm{animals})\). In directed unipartite graphs, \(C = L/[S(S-1)]\) [@may1972].
- **Degree distributions**: number of partners per species; in bipartite networks these are “generality” (rows) and “vulnerability” (cols) [@dormann2009].
- **Weighted counterparts**: **species strength** is the sum of a species’ dependence across partners; a meaningful complexity measure in mutualistic webs [@bascompte2006science].
- **Nestedness (NODF)**: specialists interact with subsets of generalists’ partners; computed via NODF (based on overlap and decreasing fill) [@almeidaneto2008; @ulrich2009].
- **Modularity (\(Q\))**: extent to which species form groups (modules) with dense internal links and sparse external links [@newman2006; @olesen2007].
- **Specialization \(H_2'\)** (network‑level): standardized interaction diversity; robust to unequal sampling [@bluthgen2006].
- **Redundancy & complementarity**: complementary pollinators visit **different** plants (functional complementarity), while redundancy captures **overlap** among species' functions; both relate to stability of ecosystem functions [@devoto2012; @magrach2021; @ponisio2020].

**Nestedness (NODF)**

NODF combines **paired overlap** and **decreasing fill** across ordered rows/columns [@almeidaneto2008]. Values range 0–100. Implementations: `bipartite::nested(web, method = "NODF"), `vegan::nestedtemp`.

**Modularity \(Q\)**

For a given partition of nodes into modules, modularity compares within‑module weight to a randomized expectation [@newman2006]:
\[ Q = \frac{1}{2m}\sum_{ij} \left(A_{ij} - \frac{k_i k_j}{2m}\right)\delta(g_i,g_j),\]
with \(m=\) total weight, \(k_i=\) node strength, and \(\delta\) equal to 1 if \(i\) and \(j\) share a module.
Pollination networks are often modular [@olesen2007]. Tools: `bipartite::computeModules`, `igraph::cluster_*`.

**Specialization \(H_2'\) (network) and \(d'\) (species)**

Information‑theoretic indices that standardize interaction diversity against marginals [@bluthgen2006]. In `bipartite`: `H2fun`

**Connectance**

\(C = L/M\) where \(M\) is the maximum possible links (see above). High \(C\) indicates dense interaction structure [@may1972]. Scales with network size (number of species) so can be easily misinterpreted when comparing the connectance of networks of different sizes. 

**Species roles**

- **Degree centrality**: number of unique partners
- **Betweenness centrality**: fraction of shortest paths that pass through a species (potential “bridges”) [@freeman1979].
- **Closeness centrality**: inverse of distances to all others (fast access) [@freeman1979].
- **Eigenvector centrality**: high if connected to other central species.
- **Species strength** (weighted degree by dependence) gauges importance as a mutualistic provider/consumer [@bascompte2006science].
**d'** recipocal specialization, similar to H2 but for a species [@bluthgen2006]. 

`bipartite::specieslevel`  can calculate about every metric you can imagine,  see `?bipartite::specieslevel`. 

**Null models for fair comparisons**

Because many metrics scale with **network size**, **fill**, and **sampling**, compare observed metrics to **null expectations** generated by randomization [@dormann2009; @ulrich2009].

**Families of null models**

1. **Equiprobable / probabilistic**: each cell has the same probability of being 1 (binary) or a probability proportional to row/column totals. Good for testing strong structure but can inflate Type I error (probability of false positives) with heterogeneous marginals [@gotelli2000].
2. **Constrained marginals**: preserve row and/or column totals to mimic sampling and abundance effects.
   - **Fixed–Fixed (FF)**: preserve both row and column sums via **swap**, **trial‑swap**, **curveball** algorithms [@miklos2004; @strona2014].  
   - **Fixed–Equiprobable (FE)** / **Equiprobable–Fixed (EF)**: preserve one margin, randomize the other [@ulrich2007].
   
In general with ecological networks we want to use **Constrained marginals** or **Equiprobable / probabilistic**.
Report **z‑scores** or **p‑values** based on the null distribution; when comparing many networks, use the same null model family for consistency [@dormann2009].



## Demo: Calculating network metrics and using null models


```
##  connectance modularity Q   nestedness           H2 
##    0.1604938    0.4300807   19.7967083    0.8537307
```

```
## $`higher level`
##                         degree         d
## Policana albopilosa          1 0.6905693
## Bombus dahlbomii             2 0.8581794
## Ruizantheda mutabilis        2 0.1554289
## Trichophthalma amoena        1 0.8474066
## Syrphus octomaculatus        3 0.3859789
## Manuelia gayi                1 0.3202602
## Allograpta.Toxomerus         4 0.6482363
## Trichophthalma jaffueli      1 0.2647268
## Phthiria                     2 0.3916793
## Platycheirus1                2 0.0000000
## Sapromyza.Minettia           1 0.2000132
## Formicidae3                  1 0.8115396
## Nitidulidae                  1 0.5510016
## Staphilinidae                2 0.4092484
## Ichneumonidae4               2 0.9007713
## Braconidae3                  1 0.6165417
## Chalepogenus caeruleus       1 0.9500994
## Vespula germanica            1 0.2834746
## Torymidae2                   1 0.8322740
## Phthiria1                    1 0.2000132
## Svastrides melanura          1 0.3083018
## Sphecidae                    1 0.2000132
## Thomisidae                   1 0.2000132
## Corynura prothysteres        2 0.1209998
## Ichneumonidae2               1 0.2834746
## Ruizantheda proxima          1 0.2834746
## Braconidae2                  1 0.0000000
## 
## $`lower level`
##                          degree         d
## Aristotelia chilensis         6 0.9613968
## Alstroemeria aurea           17 0.8043229
## Schinus patagonicus           1 0.9846607
## Berberis darwinii             2 0.5619798
## Rosa eglanteria               4 0.5590405
## Cynanchum diemii              4 1.0000000
## Ribes magellanicum            2 0.9036839
## Mutisia decurrens             1 0.6625752
## Calceolaria crenatiflora      2 0.9106928
```

```
## Warning in oecosimu(net, function(x) nestedtemp(x, "NODF")$statistic, method =
## "quasiswap", : nullmodel transformed 'comm' to binary data
```

```
## oecosimu object
## 
## Call: oecosimu(comm = net, nestfun = function(x) nestedtemp(x,
## "NODF")$statistic, method = "quasiswap", nsimul = 999)
## 
## nullmodel method 'quasiswap' with 999 simulations
## 
## alternative hypothesis: statistic is less or greater than simulated values
## 
##             statistic     SES   mean   2.5%    50%  97.5% Pr(sim.)
## temperature    19.815 0.38592 19.195 16.489 19.333 22.242    0.793
```

Interpretation tips: high \(H_2'\) means **specialized** interactions; high NODF indicates **nested** structure; high \(Q\) implies **modules** (compartments).

Now to standardize using null models.


```
## oecosimu object
## 
## Call: oecosimu(comm = net > 0, nestfun = null_fun, method =
## "quasiswap", nsimul = 1000)
## 
## nullmodel method 'quasiswap' with 1000 simulations
## 
## alternative hypothesis: statistic is less or greater than simulated values
## 
##             statistic     SES   mean   2.5%    50%  97.5% Pr(sim.)
## temperature    19.908 0.43557 19.189 16.503 19.205 22.275   0.7802
```


---

## Network visualization


## Demo: Create a graph from OBA data, visualize it

Let's load in our OBA data and make a network for all the bumble bees in Oregon. We will need to subset the data, then keep only the bee and plant species columns. 


```
## Rows: 240,752
## Columns: 58
## $ fieldNumber                   <chr> "1800001", "1800002", "1800003", "180000…
## $ catalogNumber                 <chr> "", "", "", "", "", "", "", "", "", "", …
## $ occurrenceID                  <chr> "https://osac.oregonstate.edu/OBS/OBA_18…
## $ userId                        <chr> "429964", "429964", "429964", "429964", …
## $ userLogin                     <chr> "amelathopoulos", "amelathopoulos", "ame…
## $ firstName                     <chr> "Andony", "Andony", "Andony", "Andony", …
## $ firstNameInitial              <chr> "A.", "A.", "A.", "A.", "A.", "A.", "A."…
## $ lastName                      <chr> "Melathopoulos", "Melathopoulos", "Melat…
## $ recordedBy                    <chr> "Andony Melathopoulos", "Andony Melathop…
## $ sampleId                      <chr> "", "", "", "", "", "", "", "", "", "", …
## $ specimenId                    <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ day                           <int> 4, 4, 4, 4, 16, 22, 22, 22, 22, 22, 22, …
## $ month                         <chr> "5", "5", "5", "5", "5", "6", "6", "6", …
## $ year                          <int> 2018, 2018, 2018, 2018, 2018, 2018, 2018…
## $ verbatimEventDate             <chr> "5/4/18", "5/4/18", "5/4/18", "5/4/18", …
## $ day2                          <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ month2                        <chr> "", "", "", "", "", "", "", "", "", "", …
## $ year2                         <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ startDayofYear                <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ endDayofYear                  <chr> "", "", "", "", "", "", "", "", "", "", …
## $ country                       <chr> "USA", "USA", "USA", "USA", "USA", "USA"…
## $ stateProvince                 <chr> "OR", "OR", "OR", "OR", "OR", "OR", "OR"…
## $ county                        <chr> "Benton", "Benton", "Benton", "Benton", …
## $ locality                      <chr> "Corvallis", "Corvallis", "Corvallis", "…
## $ verbatimElevation             <chr> "71", "71", "71", "71", "62", "1271", "1…
## $ decimalLatitude               <dbl> 44.5599, 44.5599, 44.5599, 44.5599, 45.6…
## $ decimalLongitude              <dbl> -123.2883, -123.2883, -123.2883, -123.28…
## $ coordinateUncertaintyInMeters <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ samplingProtocol              <chr> "aerial net", "aerial net", "aerial net"…
## $ relationshipOfResource        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ resourceID                    <chr> "https://osac.oregonstate.edu/OBS/OBA_18…
## $ relatedResourceID             <chr> "1444041d-1464-49d0-9c5c-f297aa90e2ae", …
## $ relationshipRemarks           <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ phylumPlant                   <chr> "Tracheophyta", "Tracheophyta", "Tracheo…
## $ orderPlant                    <chr> "Ranunculales", "Ranunculales", "Ranuncu…
## $ familyPlant                   <chr> "Berberidaceae", "Berberidaceae", "Berbe…
## $ genusPlant                    <chr> "", "", "", "", "Vicia", "Eschscholzia",…
## $ speciesPlant                  <chr> "", "", "", "", "Vicia villosa", "Eschsc…
## $ taxonRankPlant                <chr> "family", "family", "family", "family", …
## $ url                           <chr> "https://www.inaturalist.org/observation…
## $ phylum                        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ class                         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ order                         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ family                        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ genus                         <chr> "Andrena", "Andrena", "Andrena", "Andren…
## $ subgenus                      <chr> "", "", "", "", "", "", "", "", "", "", …
## $ specificEpithet               <chr> "prunorum", "", "hippotes", "angustitars…
## $ taxonomicNotes                <chr> "", "", "", "", "", "", "", "", "", "", …
## $ scientificName                <chr> "", "", "", "", "", "", "", "", "", "", …
## $ sex                           <chr> "male", "male", "male", "female", "femal…
## $ caste                         <chr> "", "", "", "", "worker", "worker", "", …
## $ taxonRank                     <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
## $ identifiedBy                  <chr> "L.R.Best", "L.R.Best", "A.S.Jackson", "…
## $ familyVolDet                  <chr> "", "", "", "", "", "", "", "", "", "", …
## $ genusVolDet                   <chr> "", "", "", "", "", "", "", "", "", "", …
## $ specificEpithetVolDet         <chr> "", "", "", "", "", "", "", "", "", "", …
## $ sexVolDet                     <chr> "", "", "", "", "", "", "", "", "", "", …
## $ casteVolDet                   <chr> "", "", "", "", "", "", "", "", "", "", …
```

The entire network would be difficult to visualize, so let's subset the data to just bumble bees. We need to extract only the columns that are relevant for the bee-plant interactions. The column "speciesPlant" has the floral species a bee was caught visiting, if it was caught on a flower.


```
##           GenusSpecies        PlantGenusSpecies
## 5  Bombus vosnesenskii            Vicia villosa
## 6  Bombus vosnesenskii Eschscholzia californica
## 8  Bombus vosnesenskii Eschscholzia californica
## 9  Bombus vosnesenskii Eschscholzia californica
## 10 Bombus vosnesenskii Eschscholzia californica
## 12     Bombus fervidus       Digitalis purpurea
```

There are a lot of blank rows from associated taxa for individuals not caught on a flower. We cannot do anything with those so we will just drop them. 


```
##   [1] "Abelia Ã— grandiflora"              
##   [2] "Abies grandis Ã— concolor"          
##   [3] "Abronia latifolia"                  
##   [4] "Acer circinatum"                    
##   [5] "Acer macrophyllum"                  
##   [6] "Achillea millefolium"               
##   [7] "Acmispon americanus"                
##   [8] "Acmispon decumbens"                 
##   [9] "Aconitum columbianum"               
##  [10] "Aconitum columbianum howellii"      
##  [11] "Actaea elata alpestris"             
##  [12] "Adelinia grandis"                   
##  [13] "Aegopodium podagraria"              
##  [14] "Aesculus hippocastanum"             
##  [15] "Agastache \nurticifolia"            
##  [16] "Agastache foeniculum"               
##  [17] "Agastache urticifolia"              
##  [18] "Ageratina occidentalis"             
##  [19] "Agoseris aurantiaca"                
##  [20] "Agoseris glauca"                    
##  [21] "Ajuga reptans"                      
##  [22] "Alcea biennis"                      
##  [23] "Alcea rosea"                        
##  [24] "Allium acuminatum"                  
##  [25] "Allium amplectens"                  
##  [26] "Allium cernuum"                     
##  [27] "Allium crenulatum"                  
##  [28] "Allium nevii"                       
##  [29] "Allium platycaule"                  
##  [30] "Allium schoenoprasum"               
##  [31] "Allium triquetrum"                  
##  [32] "Allium validum"                     
##  [33] "Allotropa virgata"                  
##  [34] "Amelanchier alnifolia"              
##  [35] "Amorpha fruticosa"                  
##  [36] "Amsinckia menziesii"                
##  [37] "Amsinckia tessellata"               
##  [38] "Anaphalis margaritacea"             
##  [39] "Anchusa officinalis"                
##  [40] "Angelica arguta"                    
##  [41] "Angelica capitellata"               
##  [42] "Angelica lucida"                    
##  [43] "Antennaria media"                   
##  [44] "Apocynum Ã— floribundum"            
##  [45] "Apocynum androsaemifolium"          
##  [46] "Apocynum cannabinum"                
##  [47] "Aquilegia formosa"                  
##  [48] "Aquilegia vulgaris"                 
##  [49] "Arbutus menziesii"                  
##  [50] "Arctium minus"                      
##  [51] "Arctostaphylos Ã— media"            
##  [52] "Arctostaphylos bakeri"              
##  [53] "Arctostaphylos canescens"           
##  [54] "Arctostaphylos columbiana"          
##  [55] "Arctostaphylos densiflora"          
##  [56] "Arctostaphylos manzanita"           
##  [57] "Arctostaphylos nevadensis"          
##  [58] "Arctostaphylos patula"              
##  [59] "Arctostaphylos uva-ursi"            
##  [60] "Arctostaphylos viscida"             
##  [61] "Argentina anserina"                 
##  [62] "Argentina pacifica"                 
##  [63] "Arnica chamissonis"                 
##  [64] "Arnica cordifolia"                  
##  [65] "Arnica lanceolata"                  
##  [66] "Arnica latifolia"                   
##  [67] "Arnica longifolia"                  
##  [68] "Arnica mollis"                      
##  [69] "Artemisia tridentata"               
##  [70] "Aruncus dioicus"                    
##  [71] "Asclepias fascicularis"             
##  [72] "Asclepias incarnata"                
##  [73] "Asclepias speciosa"                 
##  [74] "Asparagus officinalis"              
##  [75] "Astragalus accidens"                
##  [76] "Astragalus curvicarpus"             
##  [77] "Astragalus cusickii"                
##  [78] "Astragalus filipes"                 
##  [79] "Astragalus hoodianus"               
##  [80] "Astragalus iodanthus"               
##  [81] "Astragalus lentiginosus"            
##  [82] "Astragalus racemosus"               
##  [83] "Astragalus sheldonii"               
##  [84] "Astragalus whitneyi"                
##  [85] "Balsamorhiza careyana"              
##  [86] "Balsamorhiza deltoidea"             
##  [87] "Balsamorhiza hookeri"               
##  [88] "Balsamorhiza incana"                
##  [89] "Balsamorhiza sagittata"             
##  [90] "Barbarea orthoceras"                
##  [91] "Bellardia viscosa"                  
##  [92] "Bellis perennis"                    
##  [93] "Berberis aquifolium"                
##  [94] "Berberis darwinii"                  
##  [95] "Berberis piperiana"                 
##  [96] "Berberis repens"                    
##  [97] "Bidens cernua"                      
##  [98] "Bistorta bistortoides"              
##  [99] "Blepharipappus scaber"              
## [100] "Borago officinalis"                 
## [101] "Boykinia major"                     
## [102] "Brassica oleracea"                  
## [103] "Brassica rapa"                      
## [104] "Brodiaea elegans"                   
## [105] "Buddleja davidii"                   
## [106] "Cakile edentula"                    
## [107] "Cakile maritima"                    
## [108] "Calendula officinalis"              
## [109] "Calluna vulgaris"                   
## [110] "Calochortus eurycarpus"             
## [111] "Calochortus macrocarpus"            
## [112] "Calochortus subalpinus"             
## [113] "Calochortus tolmiei"                
## [114] "Caltha leptosepala"                 
## [115] "Calyptridium monospermum"           
## [116] "Calyptridium umbellatum"            
## [117] "Calystegia soldanella"              
## [118] "Camassia cusickii"                  
## [119] "Camassia leichtlinii"               
## [120] "Camassia leichtlinii suksdorfii"    
## [121] "Camassia quamash"                   
## [122] "Campanula scouleri"                 
## [123] "Canadanthus modestus"               
## [124] "Caragana arborescens"               
## [125] "Carduus nutans"                     
## [126] "Carduus pycnocephalus"              
## [127] "Castilleja ambigua"                 
## [128] "Castilleja applegatei"              
## [129] "Castilleja applegatei pinetorum"    
## [130] "Castilleja campestris"              
## [131] "Castilleja collegiorum"             
## [132] "Castilleja exserta"                 
## [133] "Castilleja hispida"                 
## [134] "Castilleja hispida hispida"         
## [135] "Castilleja miniata"                 
## [136] "Castilleja pilosa"                  
## [137] "Castilleja septentrionalis"         
## [138] "Castilleja tenuis"                  
## [139] "Ceanothus cordulatus"               
## [140] "Ceanothus cuneatus"                 
## [141] "Ceanothus gloriosus"                
## [142] "Ceanothus impressus"                
## [143] "Ceanothus integerrimus"             
## [144] "Ceanothus papillosus"               
## [145] "Ceanothus prostratus"               
## [146] "Ceanothus prostratus prostratus"    
## [147] "Ceanothus pumilus"                  
## [148] "Ceanothus thyrsiflorus"             
## [149] "Ceanothus thyrsiflorus thyrsiflorus"
## [150] "Ceanothus velutinus"                
## [151] "Centaurea Ã— moncktonii"            
## [152] "Centaurea cyanus"                   
## [153] "Centaurea diffusa"                  
## [154] "Centaurea jacea"                    
## [155] "Centaurea montana"                  
## [156] "Centaurea solstitialis"             
## [157] "Centaurea stoebe"                   
## [158] "Centaurium erythraea"               
## [159] "Centromadia fitchii"                
## [160] "Cercis occidentalis"                
## [161] "Chaenactis douglasii"               
## [162] "Chaenactis douglasii douglasii"     
## [163] "Chamaebatiaria millefolium"         
## [164] "Chamaenerion angustifolium"         
## [165] "Chimaphila umbellata"               
## [166] "Chondrilla juncea"                  
## [167] "Chrysolepis chrysophylla"           
## [168] "Chrysolepis sempervirens"           
## [169] "Chrysopsis mariana"                 
## [170] "Chrysothamnus viscidiflorus"        
## [171] "Cichorium intybus"                  
## [172] "Cicuta douglasii"                   
## [173] "Cirsium andersonii"                 
## [174] "Cirsium arvense"                    
## [175] "Cirsium brevistylum"                
## [176] "Cirsium cymosum"                    
## [177] "Cirsium cymosum canovirens"         
## [178] "Cirsium edule"                      
## [179] "Cirsium inamoenum"                  
## [180] "Cirsium inamoenum inamoenum"        
## [181] "Cirsium peckii"                     
## [182] "Cirsium remotifolium"               
## [183] "Cirsium remotifolium odontolepis"   
## [184] "Cirsium scariosum"                  
## [185] "Cirsium undulatum"                  
## [186] "Cirsium vulgare"                    
## [187] "Clarkia amoena"                     
## [188] "Clarkia amoena caurina"             
## [189] "Clarkia amoena lindleyi"            
## [190] "Clarkia pulchella"                  
## [191] "Clarkia purpurea"                   
## [192] "Clarkia rhomboidea"                 
## [193] "Claytonia sibirica"                 
## [194] "Cleomella lutea"                    
## [195] "Cleomella serrulata"                
## [196] "Clinopodium vulgare"                
## [197] "Collinsia grandiflora"              
## [198] "Collinsia linearis"                 
## [199] "Collinsia parviflora"               
## [200] "Collinsia sparsiflora"              
## [201] "Collinsia torreyi"                  
## [202] "Collomia grandiflora"               
## [203] "Collomia mazama"                    
## [204] "Columbiadoria hallii"               
## [205] "Convolvulus arvensis"               
## [206] "Cordylanthus tenuis"                
## [207] "Coreopsis verticillata"             
## [208] "Cornus sericea"                     
## [209] "Cornus unalaschkensis"              
## [210] "Cosmos bipinnatus"                  
## [211] "Cotinus coggygria"                  
## [212] "Cotoneaster coriaceus"              
## [213] "Cotoneaster franchetii"             
## [214] "Cotoneaster horizontalis"           
## [215] "Crassula tetragona"                 
## [216] "Crataegus douglasii"                
## [217] "Crataegus monogyna"                 
## [218] "Crepis acuminata"                   
## [219] "Crepis setosa"                      
## [220] "Croton setiger"                     
## [221] "Cryptantha intermedia"              
## [222] "Cucumis sativus"                    
## [223] "Cucurbita maxima"                   
## [224] "Cucurbita moschata"                 
## [225] "Cucurbita pepo"                     
## [226] "Cuscuta pacifica"                   
## [227] "Cynara cardunculus"                 
## [228] "Cynara cardunculus flavescens"      
## [229] "Cynoglossum officinale"             
## [230] "Cytisus scoparius"                  
## [231] "Dalea ornata"                       
## [232] "Damasonium californicum"            
## [233] "Dasiphora fruticosa"                
## [234] "Daucus carota"                      
## [235] "Delosperma cooperi"                 
## [236] "Delphinium leucophaeum"             
## [237] "Delphinium menziesii"               
## [238] "Delphinium nuttallianum"            
## [239] "Delphinium nuttallii"               
## [240] "Delphinium trolliifolium"           
## [241] "Descurainia sophia"                 
## [242] "Dicentra formosa"                   
## [243] "Dicentra formosa formosa"           
## [244] "Dieteria canescens"                 
## [245] "Digitalis purpurea"                 
## [246] "Dipsacus fullonum"                  
## [247] "Doellingeria breweri"               
## [248] "Doellingeria ledophylla"            
## [249] "Doellingeria ledophylla ledophylla" 
## [250] "Drymocallis glandulosa"             
## [251] "Drymocallis pseudorupestris"        
## [252] "Echinacea purpurea"                 
## [253] "Elaeagnus umbellata"                
## [254] "Epilobium brachycarpum"             
## [255] "Epilobium ciliatum"                 
## [256] "Epilobium densiflorum"              
## [257] "Eremogone congesta"                 
## [258] "Eremogone kingii"                   
## [259] "Erica Ã— darleyensis"               
## [260] "Erica carnea"                       
## [261] "Erica cinerea"                      
## [262] "Ericameria bloomeri"                
## [263] "Ericameria discoidea"               
## [264] "Ericameria greenei"                 
## [265] "Ericameria linearifolia"            
## [266] "Ericameria nauseosa"                
## [267] "Ericameria nauseosa glabrata"       
## [268] "Erigeron aliceae"                   
## [269] "Erigeron bloomeri"                  
## [270] "Erigeron divergens"                 
## [271] "Erigeron foliosus"                  
## [272] "Erigeron glacialis"                 
## [273] "Erigeron inornatus"                 
## [274] "Erigeron peregrinus"                
## [275] "Erigeron pumilus"                   
## [276] "Erigeron speciosus"                 
## [277] "Eriodictyon californicum"           
## [278] "Eriogonum compositum"               
## [279] "Eriogonum elatum"                   
## [280] "Eriogonum heracleoides"             
## [281] "Eriogonum inflatum"                 
## [282] "Eriogonum niveum"                   
## [283] "Eriogonum nudum"                    
## [284] "Eriogonum ovalifolium"              
## [285] "Eriogonum sphaerocephalum"          
## [286] "Eriogonum strictum"                 
## [287] "Eriogonum umbellatum"               
## [288] "Eriophyllum confertiflorum"         
## [289] "Eriophyllum lanatum"                
## [290] "Eriophyllum lanatum integrifolium"  
## [291] "Erodium cicutarium"                 
## [292] "Eryngium planum"                    
## [293] "Erysimum cheiranthoides"            
## [294] "Erythranthe decora"                 
## [295] "Erythranthe grandis"                
## [296] "Erythranthe guttata"                
## [297] "Erythranthe lewisii"                
## [298] "Erythranthe microphylla"            
## [299] "Escallonia rubra"                   
## [300] "Eschscholzia californica"           
## [301] "Eucryphia cordifolia"               
## [302] "Euonymus occidentalis"              
## [303] "Euphorbia esula"                    
## [304] "Euphorbia lathyris"                 
## [305] "Eurybia integrifolia"               
## [306] "Eurybia radulina"                   
## [307] "Euthamia occidentalis"              
## [308] "Fagopyrum esculentum"               
## [309] "Ficaria verna"                      
## [310] "Fragaria cascadensis"               
## [311] "Fragaria chiloensis"                
## [312] "Fragaria vesca"                     
## [313] "Frangula californica"               
## [314] "Frangula purshiana"                 
## [315] "Frasera albicaulis"                 
## [316] "Frasera albicaulis nitida"          
## [317] "Frasera speciosa"                   
## [318] "Fuchsia magellanica"                
## [319] "Gaillardia aristata"                
## [320] "Gaillardia pinnatifida"             
## [321] "Gaillardia pulchella"               
## [322] "Galanthus nivalis"                  
## [323] "Gaultheria shallon"                 
## [324] "Gentiana affinis"                   
## [325] "Gentiana andrewsii"                 
## [326] "Gentiana calycosa"                  
## [327] "Gentiana newberryi"                 
## [328] "Gentiana sceptrum"                  
## [329] "Geranium lucidum"                   
## [330] "Geranium oreganum"                  
## [331] "Geranium robertianum"               
## [332] "Geranium viscosissimum"             
## [333] "Geum coccineum"                     
## [334] "Geum macrophyllum"                  
## [335] "Geum triflorum"                     
## [336] "Gilia capitata"                     
## [337] "Gilia capitata capitata"            
## [338] "Glandora prostrata"                 
## [339] "Glebionis segetum"                  
## [340] "Glechoma hederacea"                 
## [341] "Glycyrrhiza lepidota"               
## [342] "Gratiola ebracteata"                
## [343] "Grindelia hirsutula"                
## [344] "Grindelia integrifolia"             
## [345] "Grindelia nana"                     
## [346] "Grindelia squarrosa"                
## [347] "Grindelia stricta"                  
## [348] "Gutierrezia sarothrae"              
## [349] "Gypsophila vaccaria"                
## [350] "Hackelia californica"               
## [351] "Hackelia micrantha"                 
## [352] "Helenium autumnale"                 
## [353] "Helenium bigelovii"                 
## [354] "Helenium bolanderi"                 
## [355] "Helianthella uniflora"              
## [356] "Helianthus annuus"                  
## [357] "Helianthus cusickii"                
## [358] "Helianthus exilis"                  
## [359] "Heliopsis helianthoides"            
## [360] "Heracleum maximum"                  
## [361] "Heracleum sphondylium"              
## [362] "Heuchera cylindrica"                
## [363] "Heuchera micrantha"                 
## [364] "Hirschfeldia incana"                
## [365] "Holodiscus discolor"                
## [366] "Holodiscus discolor microphyllus"   
## [367] "Horkelia fusca"                     
## [368] "Horkelia hendersonii"               
## [369] "Horkelia howellii"                  
## [370] "Hosackia crassifolia"               
## [371] "Hosackia gracilis"                  
## [372] "Hosackia oblongifolia"              
## [373] "Hosackia rosea"                     
## [374] "Hyacinthoides hispanica"            
## [375] "Hydrophyllum capitatum"             
## [376] "Hydrophyllum capitatum thompsonii"  
## [377] "Hydrophyllum fendleri"              
## [378] "Hydrophyllum occidentale"           
## [379] "Hydrophyllum tenuipes"              
## [380] "Hymenoxys hoopesii"                 
## [381] "Hypericum calycinum"                
## [382] "Hypericum perforatum"               
## [383] "Hypericum scouleri"                 
## [384] "Hypochaeris radicata"               
## [385] "Hyssopus officinalis"               
## [386] "Iliamna rivularis"                  
## [387] "Ipomopsis aggregata"                
## [388] "Iris douglasiana"                   
## [389] "Iris innominata"                    
## [390] "Iris missouriensis"                 
## [391] "Iris tenax"                         
## [392] "Ivesia gordonii"                    
## [393] "Jacobaea vulgaris"                  
## [394] "Jaumea carnosa"                     
## [395] "Kalmia microphylla"                 
## [396] "Kalmia polifolia"                   
## [397] "Kickxia elatine"                    
## [398] "Kniphofia uvaria"                   
## [399] "Kolkwitzia amabilis"                
## [400] "Kopsiopsis strobilacea"             
## [401] "Kyhosia bolanderi"                  
## [402] "Lactuca serriola"                   
## [403] "Ladeania lanceolata"                
## [404] "Lagerstroemia subcostata"           
## [405] "Lamium purpureum"                   
## [406] "Lapsana communis"                   
## [407] "Lasthenia californica"              
## [408] "Lathyrus hirsutus"                  
## [409] "Lathyrus japonicus"                 
## [410] "Lathyrus lanszwertii"               
## [411] "Lathyrus latifolius"                
## [412] "Lathyrus nevadensis"                
## [413] "Lathyrus palustris"                 
## [414] "Lathyrus polyphyllus"               
## [415] "Lathyrus sylvestris"                
## [416] "Lavandula angustifolia"             
## [417] "Lavandula dentata"                  
## [418] "Lavandula pedunculata"              
## [419] "Lavandula stoechas"                 
## [420] "Leontodon saxatilis"                
## [421] "Lepidium appelianum"                
## [422] "Leucanthemum maximum"               
## [423] "Leucanthemum vulgare"               
## [424] "Leucophysalis nana"                 
## [425] "Lewisia columbiana wallowensis"     
## [426] "Leycesteria formosa"                
## [427] "Ligusticum grayi"                   
## [428] "Lilium columbianum"                 
## [429] "Limnanthes douglasii"               
## [430] "Linaria dalmatica"                  
## [431] "Linaria dalmatica dalmatica"        
## [432] "Linaria maroccana"                  
## [433] "Linaria purpurea"                   
## [434] "Linaria vulgaris"                   
## [435] "Linnaea borealis"                   
## [436] "Linum lewisii"                      
## [437] "Lithospermum ruderale"              
## [438] "Lobelia erinus"                     
## [439] "Lomatium californicum"              
## [440] "Lomatium columbianum"               
## [441] "Lomatium dissectum"                 
## [442] "Lomatium hallii"                    
## [443] "Lomatium triternatum"               
## [444] "Lonicera caerulea"                  
## [445] "Lonicera conjugialis"               
## [446] "Lonicera hispidula"                 
## [447] "Lonicera involucrata"               
## [448] "Lotus corniculatus"                 
## [449] "Lotus pedunculatus"                 
## [450] "Lotus pedunculatus pedunculatus"    
## [451] "Luetkea pectinata"                  
## [452] "Lupinus albicaulis"                 
## [453] "Lupinus albifrons"                  
## [454] "Lupinus arboreus"                   
## [455] "Lupinus arbustus"                   
## [456] "Lupinus argenteus"                  
## [457] "Lupinus bicolor"                    
## [458] "Lupinus breweri"                    
## [459] "Lupinus burkei"                     
## [460] "Lupinus latifolius"                 
## [461] "Lupinus lepidus"                    
## [462] "Lupinus leucophyllus"               
## [463] "Lupinus littoralis"                 
## [464] "Lupinus polyphyllus"                
## [465] "Lupinus rivularis"                  
## [466] "Lupinus sericeus"                   
## [467] "Lupinus sulphureus"                 
## [468] "Lythrum salicaria"                  
## [469] "Madia elegans"                      
## [470] "Madia gracilis"                     
## [471] "Madia sativa"                       
## [472] "Mahonia aquifolium"                 
## [473] "Maianthemum stellatum"              
## [474] "Malus domestica"                    
## [475] "Malus fusca"                        
## [476] "Malus sylvestris"                   
## [477] "Malva arborea"                      
## [478] "Malva neglecta"                     
## [479] "Marah oregana"                      
## [480] "Marrubium vulgare"                  
## [481] "Medicago sativa"                    
## [482] "Melilotus albus"                    
## [483] "Melilotus officinalis"              
## [484] "Mentha Ã— piperita"                 
## [485] "Mentha canadensis"                  
## [486] "Mentha pulegium"                    
## [487] "Mentha spicata"                     
## [488] "Mentzelia albicaulis"               
## [489] "Mentzelia laevicaulis"              
## [490] "Mertensia ciliata"                  
## [491] "Mertensia longiflora"               
## [492] "Mertensia paniculata"               
## [493] "Microseris nutans"                  
## [494] "Monarda citriodora"                 
## [495] "Monarda didyma"                     
## [496] "Monarda fistulosa"                  
## [497] "Monardella odoratissima"            
## [498] "Monardella villosa"                 
## [499] "Muscari armeniacum"                 
## [500] "Myosotis discolor"                  
## [501] "Nemophila menziesii"                
## [502] "Nepeta Ã— faassenii"                
## [503] "Nepeta cataria"                     
## [504] "Nepeta faassenii"                   
## [505] "Nepeta grandiflora"                 
## [506] "Nepeta racemosa"                    
## [507] "Nothochelone nemorosa"              
## [508] "Oemleria cerasiformis"              
## [509] "Oenanthe sarmentosa"                
## [510] "Oenothera biennis"                  
## [511] "Oenothera lindheimeri"              
## [512] "Oenothera pallida"                  
## [513] "Olsynium douglasii"                 
## [514] "Onopordum acanthium"                
## [515] "Oreostemma alpigenum"               
## [516] "Origanum vulgare"                   
## [517] "Orthocarpus bracteosus"             
## [518] "Orthocarpus cuspidatus"             
## [519] "Orthocarpus imbricatus"             
## [520] "Packera hesperia"                   
## [521] "Packera macounii"                   
## [522] "Papaver somniferum"                 
## [523] "Pedicularis attollens"              
## [524] "Pedicularis groenlandica"           
## [525] "Pedicularis racemosa"               
## [526] "Pediomelum tenuiflorum"             
## [527] "Pelargonium amaryllidis"            
## [528] "Penstemon acuminatus"               
## [529] "Penstemon anguineus"                
## [530] "Penstemon attenuatus"               
## [531] "Penstemon cardwellii"               
## [532] "Penstemon cinicola"                 
## [533] "Penstemon confertus"                
## [534] "Penstemon davidsonii"               
## [535] "Penstemon deustus"                  
## [536] "Penstemon euglaucus"                
## [537] "Penstemon fruticosus"               
## [538] "Penstemon glaucinus"                
## [539] "Penstemon globosus"                 
## [540] "Penstemon hesperius"                
## [541] "Penstemon heterophyllus"            
## [542] "Penstemon humilis"                  
## [543] "Penstemon laetus"                   
## [544] "Penstemon ovatus"                   
## [545] "Penstemon parvulus"                 
## [546] "Penstemon peckii"                   
## [547] "Penstemon pinifolius"               
## [548] "Penstemon procerus"                 
## [549] "Penstemon richardsonii"             
## [550] "Penstemon rydbergii"                
## [551] "Penstemon serrulatus"               
## [552] "Penstemon speciosus"                
## [553] "Penstemon spectabilis"              
## [554] "Penstemon subserratus"              
## [555] "Penstemon venustus"                 
## [556] "Penstemon wilcoxii"                 
## [557] "Pentaglottis sempervirens"          
## [558] "Perideridia gairdneri"              
## [559] "Perideridia oregana"                
## [560] "Petasites frigidus palmatus"        
## [561] "Phacelia argentea"                  
## [562] "Phacelia corymbosa"                 
## [563] "Phacelia hastata"                   
## [564] "Phacelia hastata alpina"            
## [565] "Phacelia heterophylla"              
## [566] "Phacelia heterophylla virgata"      
## [567] "Phacelia imbricata"                 
## [568] "Phacelia linearis"                  
## [569] "Phacelia mutabilis"                 
## [570] "Phacelia nemoralis"                 
## [571] "Phacelia nemoralis oregonensis"     
## [572] "Phacelia procera"                   
## [573] "Phacelia ramosissima"               
## [574] "Phacelia sericea"                   
## [575] "Phacelia sericea ciliosa"           
## [576] "Phacelia tanacetifolia"             
## [577] "Philadelphus coronarius"            
## [578] "Philadelphus lewisii"               
## [579] "Phyllodoce empetriformis"           
## [580] "Physocarpus capitatus"              
## [581] "Picea pungens"                      
## [582] "Picea sitchensis"                   
## [583] "Pieris japonica"                    
## [584] "Pilosella caespitosa"               
## [585] "Plagiobothrys figuratus"            
## [586] "Plagiobothrys nothofulvus"          
## [587] "Plantago lanceolata"                
## [588] "Plectritis congesta"                
## [589] "Plectritis congesta congesta"       
## [590] "Polemonium californicum"            
## [591] "Polemonium carneum"                 
## [592] "Polemonium occidentale"             
## [593] "Polygonum douglasii"                
## [594] "Polygonum paronychia"               
## [595] "Polygonum phytolaccifolium"         
## [596] "Populus tremuloides"                
## [597] "Potentilla breweri"                 
## [598] "Potentilla flabellifolia"           
## [599] "Potentilla gracilis"                
## [600] "Potentilla norvegica"               
## [601] "Potentilla recta"                   
## [602] "Primula hendersonii"                
## [603] "Primula jeffreyi"                   
## [604] "Primula jeffreyi jeffreyi"          
## [605] "Primula pauciflora"                 
## [606] "Prosartes smithii"                  
## [607] "Prunella vulgaris"                  
## [608] "Prunella vulgaris lanceolata"       
## [609] "Prunus avium"                       
## [610] "Prunus domestica"                   
## [611] "Prunus emarginata"                  
## [612] "Prunus laurocerasus"                
## [613] "Prunus persica"                     
## [614] "Prunus serrulata"                   
## [615] "Prunus subcordata rubicunda"        
## [616] "Prunus virginiana"                  
## [617] "Purshia tridentata"                 
## [618] "Pyrrocoma carthamoides"             
## [619] "Pyrrocoma hirta"                    
## [620] "Ranunculus occidentalis"            
## [621] "Ranunculus repens"                  
## [622] "Raphanus raphanistrum"              
## [623] "Raphanus raphanistrum sativus"      
## [624] "Raphanus sativus"                   
## [625] "Reynoutria japonica"                
## [626] "Rhododendron catawbiense"           
## [627] "Rhododendron columbianum"           
## [628] "Rhododendron macrophyllum"          
## [629] "Rhododendron maximum"               
## [630] "Rhododendron menziesii"             
## [631] "Rhododendron occidentale"           
## [632] "Rhododendron ponticum"              
## [633] "Ribes aureum"                       
## [634] "Ribes cereum"                       
## [635] "Ribes inerme"                       
## [636] "Ribes nigrum"                       
## [637] "Ribes oxyacanthoides"               
## [638] "Ribes rubrum"                       
## [639] "Ribes sanguineum"                   
## [640] "Ribes uva-crispa"                   
## [641] "Ribes velutinum"                    
## [642] "Robinia pseudoacacia"               
## [643] "Rorippa indica"                     
## [644] "Rosa canina"                        
## [645] "Rosa gymnocarpa"                    
## [646] "Rosa multiflora"                    
## [647] "Rosa nutkana"                       
## [648] "Rosa rubiginosa"                    
## [649] "Rosa rugosa"                        
## [650] "Rosa woodsii"                       
## [651] "Rubus armeniacus"                   
## [652] "Rubus bifrons"                      
## [653] "Rubus fruticosus"                   
## [654] "Rubus idaeus"                       
## [655] "Rubus idaeus strigosus"             
## [656] "Rubus laciniatus"                   
## [657] "Rubus parviflorus"                  
## [658] "Rubus rolfei"                       
## [659] "Rubus spectabilis"                  
## [660] "Rubus ursinus"                      
## [661] "Rubus vestitus"                     
## [662] "Rudbeckia glaucescens"              
## [663] "Rudbeckia hirta"                    
## [664] "Rudbeckia occidentalis"             
## [665] "Rupertia physodes"                  
## [666] "Salix boothii"                      
## [667] "Salix hookeriana"                   
## [668] "Salix lucida"                       
## [669] "Salix planifolia"                   
## [670] "Salix sitchensis"                   
## [671] "Salvia dorrii"                      
## [672] "Salvia dorrii dorrii"               
## [673] "Salvia greggii"                     
## [674] "Salvia leucantha"                   
## [675] "Salvia nemorosa"                    
## [676] "Salvia officinalis"                 
## [677] "Salvia pratensis"                   
## [678] "Salvia rosmarinus"                  
## [679] "Salvia yangii"                      
## [680] "Sanguisorba officinalis"            
## [681] "Santolina chamaecyparissus"         
## [682] "Satureja montana"                   
## [683] "Saussurea americana"                
## [684] "Scorzoneroides autumnalis"          
## [685] "Scrophularia californica"           
## [686] "Scrophularia lanceolata"            
## [687] "Scutellaria angustifolia"           
## [688] "Scutellaria integrifolia"           
## [689] "Securigera varia"                   
## [690] "Sedum album"                        
## [691] "Sedum lanceolatum"                  
## [692] "Sedum obtusatum"                    
## [693] "Sedum oreganum"                     
## [694] "Sedum oregonense"                   
## [695] "Sedum spathulifolium"               
## [696] "Sedum stenopetalum"                 
## [697] "Sedum stenopetalum ciliosum"        
## [698] "Senecio crassulus"                  
## [699] "Senecio fremontii"                  
## [700] "Senecio hydrophiloides"             
## [701] "Senecio hydrophilus"                
## [702] "Senecio integerrimus"               
## [703] "Senecio serra"                      
## [704] "Senecio triangularis"               
## [705] "Senecio vulgaris"                   
## [706] "Sericocarpus oregonensis"           
## [707] "Sidalcea campestris"                
## [708] "Sidalcea malviflora"                
## [709] "Sidalcea nelsoniana"                
## [710] "Sidalcea oregana"                   
## [711] "Sidalcea virgata"                   
## [712] "Silphium perfoliatum"               
## [713] "Sinapis alba"                       
## [714] "Sisymbrium altissimum"              
## [715] "Sisymbrium irio"                    
## [716] "Sisyrinchium bellum"                
## [717] "Smithiastrum prenanthoides"         
## [718] "Solanum dulcamara"                  
## [719] "Solanum lycopersicum"               
## [720] "Solidago canadensis"                
## [721] "Solidago elongata"                  
## [722] "Solidago lepida"                    
## [723] "Solidago spathulata"                
## [724] "Solidago spathulata spathulata"     
## [725] "Solidago velutina"                  
## [726] "Solidago virgaurea"                 
## [727] "Sorbus aucuparia"                   
## [728] "Sorbus sitchensis"                  
## [729] "Spergularia macrotheca"             
## [730] "Sphaeralcea munroana"               
## [731] "Spiraea betulifolia"                
## [732] "Spiraea douglasii"                  
## [733] "Spiraea japonica"                   
## [734] "Spiraea lucida"                     
## [735] "Spiraea splendens"                  
## [736] "Stachys byzantina"                  
## [737] "Stachys chamissonis"                
## [738] "Stachys mexicana"                   
## [739] "Stachys rigida"                     
## [740] "Styrax americanus"                  
## [741] "Styrax japonicus"                   
## [742] "Swainsona formosa"                  
## [743] "Symphoricarpos albus"               
## [744] "Symphoricarpos mollis"              
## [745] "Symphoricarpos rotundifolius"       
## [746] "Symphyotrichum bracteolatum"        
## [747] "Symphyotrichum campestre"           
## [748] "Symphyotrichum chilense"            
## [749] "Symphyotrichum foliaceum"           
## [750] "Symphyotrichum novae-angliae"       
## [751] "Symphyotrichum patens"              
## [752] "Symphyotrichum spathulatum"         
## [753] "Symphyotrichum subspicatum"         
## [754] "Symphytum Ã— uplandicum"            
## [755] "Syringa vulgaris"                   
## [756] "Tagetes erecta"                     
## [757] "Tanacetum vulgare"                  
## [758] "Taraxacum officinale"               
## [759] "Taraxia tanacetifolia"              
## [760] "Tellima grandiflora"                
## [761] "Tephroseris helenitis"              
## [762] "Tetradymia canescens"               
## [763] "Teucrium Ã— lucidrys"               
## [764] "Teucrium chamaedrys"                
## [765] "Thelypodium laciniatum"             
## [766] "Thermopsis californica"             
## [767] "Thermopsis gracilis"                
## [768] "Thermopsis montana"                 
## [769] "Thermopsis rhombifolia"             
## [770] "Thymus vulgaris"                    
## [771] "Tiarella trifoliata"                
## [772] "Tiarella trifoliata unifoliata"     
## [773] "Tithonia rotundifolia"              
## [774] "Tolmiea menziesii"                  
## [775] "Tonella floribunda"                 
## [776] "Toxicoscordion venenosum"           
## [777] "Triantha occidentalis"              
## [778] "Trichostema lanceolatum"            
## [779] "Trifolium arvense"                  
## [780] "Trifolium eriocephalum"             
## [781] "Trifolium hirtum"                   
## [782] "Trifolium hybridum"                 
## [783] "Trifolium incarnatum"               
## [784] "Trifolium latifolium"               
## [785] "Trifolium longipes"                 
## [786] "Trifolium macrocephalum"            
## [787] "Trifolium pratense"                 
## [788] "Trifolium productum"                
## [789] "Trifolium repens"                   
## [790] "Trifolium variegatum"               
## [791] "Trifolium vesiculosum"              
## [792] "Trifolium willdenovii"              
## [793] "Trifolium wormskioldii"             
## [794] "Triteleia grandiflora"              
## [795] "Triteleia hyacinthina"              
## [796] "Vaccinium angustifolium"            
## [797] "Vaccinium corymbosum"               
## [798] "Vaccinium ovalifolium"              
## [799] "Vaccinium ovatum"                   
## [800] "Vaccinium parvifolium"              
## [801] "Vaccinium uliginosum"               
## [802] "Valeriana sitchensis"               
## [803] "Vancouveria hexandra"               
## [804] "Verbascum densiflorum"              
## [805] "Verbascum thapsus"                  
## [806] "Veronica odora"                     
## [807] "Veronica scutellata"                
## [808] "Viburnum davidii"                   
## [809] "Viburnum opulus"                    
## [810] "Vicia americana"                    
## [811] "Vicia cracca"                       
## [812] "Vicia gigantea"                     
## [813] "Vicia sativa"                       
## [814] "Vicia villosa"                      
## [815] "Vicia villosa villosa"              
## [816] "Viola Ã— wittrockiana"              
## [817] "Viola adunca"                       
## [818] "Viola glabella"                     
## [819] "Viola praemorsa"                    
## [820] "Viola wittrockiana"                 
## [821] "Whipplea modesta"                   
## [822] "Wyethia amplexicaulis"              
## [823] "Wyethia angustifolia"               
## [824] "Wyethia helianthoides"              
## [825] "Wyethia mollis"                     
## [826] "Zinnia elegans"
```

```
##  [1] "Bombus appositus"      "Bombus caliginosus"    "Bombus centralis"     
##  [4] "Bombus fervidus"       "Bombus flavidus"       "Bombus flavidus "     
##  [7] "Bombus flavifrons"     "Bombus griseocollis"   "Bombus huntii"        
## [10] "Bombus impatiens"      "Bombus insularis"      "Bombus melanopygus"   
## [13] "Bombus mixtus"         "Bombus morrisoni"      "Bombus nevadensis"    
## [16] "Bombus occidentalis"   "Bombus rufocinctus"    "Bombus sitkensis"     
## [19] "Bombus sitkensis "     "Bombus sylvicola"      "Bombus sylvicola "    
## [22] "Bombus vagans"         "Bombus vancouverensis" "Bombus vandykei"      
## [25] "Bombus vosnesenskii"
```
You all are a very lucky class because it previous years there were a ton of terrible looking names.

We can explore the species in our network. These will be the vertices. 

```
## 
##      Bombus impatiens      Bombus flavidus          Bombus vagans 
##                     1                     5                    21 
##     Bombus sylvicola       Bombus sylvicola      Bombus morrisoni 
##                    25                    39                    40 
##     Bombus sitkensis    Bombus occidentalis    Bombus rufocinctus 
##                    42                    54                   101 
##     Bombus nevadensis      Bombus appositus      Bombus insularis 
##                   115                   128                   165 
##      Bombus sitkensis       Bombus vandykei       Bombus flavidus 
##                   206                   276                   285 
##   Bombus griseocollis      Bombus centralis    Bombus caliginosus 
##                   334                   460                   473 
##         Bombus huntii    Bombus melanopygus       Bombus fervidus 
##                   482                   623                   848 
##     Bombus flavifrons         Bombus mixtus Bombus vancouverensis 
##                   873                  1718                  1877 
##   Bombus vosnesenskii 
##                  2996
```

```
## 
##                 Acmispon americanus              Actaea elata alpestris 
##                                   1                                   1 
##               Aegopodium podagraria                 Agoseris aurantiaca 
##                                   1                                   1 
##                       Alcea biennis                   Allium crenulatum 
##                                   1                                   1 
##                   Allotropa virgata               Amelanchier alnifolia 
##                                   1                                   1 
##                Amsinckia tessellata                 Anchusa officinalis 
##                                   1                                   1 
##                    Antennaria media                 Apocynum cannabinum 
##                                   1                                   1 
##                  Aquilegia vulgaris                       Arctium minus 
##                                   1                                   1 
##             Arctostaphylos Ã— media               Arctostaphylos bakeri 
##                                   1                                   1 
##                 Asclepias incarnata                 Astragalus accidens 
##                                   1                                   1 
##                 Astragalus cusickii                Astragalus iodanthus 
##                                   1                                   1 
##                Astragalus racemosus                Astragalus sheldonii 
##                                   1                                   1 
##                Balsamorhiza hookeri                     Berberis repens 
##                                   1                                   1 
##               Blepharipappus scaber                    Brodiaea elegans 
##                                   1                                   1 
##                     Cakile edentula               Calendula officinalis 
##                                   1                                   1 
##                  Caltha leptosepala                  Castilleja ambigua 
##                                   1                                   1 
##                  Castilleja hispida                 Ceanothus impressus 
##                                   1                                   1 
##     Ceanothus prostratus prostratus Ceanothus thyrsiflorus thyrsiflorus 
##                                   1                                   1 
##                Centaurium erythraea                 Cercis occidentalis 
##                                   1                                   1 
##          Chamaebatiaria millefolium                Chimaphila umbellata 
##                                   1                                   1 
##                   Chondrilla juncea                  Chrysopsis mariana 
##                                   1                                   1 
##                  Cirsium andersonii              Clarkia amoena caurina 
##                                   1                                   1 
##             Clarkia amoena lindleyi                    Clarkia purpurea 
##                                   1                                   1 
##                 Clinopodium vulgare                   Collinsia torreyi 
##                                   1                                   1 
##                     Collomia mazama                 Cordylanthus tenuis 
##                                   1                                   1 
##                  Crassula tetragona                 Crataegus douglasii 
##                                   1                                   1 
##                    Crepis acuminata               Cryptantha intermedia 
##                                   1                                   1 
##                     Cucumis sativus                  Cynara cardunculus 
##                                   1                                   1 
##       Cynara cardunculus flavescens             Damasonium californicum 
##                                   1                                   1 
##                  Delosperma cooperi              Delphinium leucophaeum 
##                                   1                                   1 
##                  Descurainia sophia         Drymocallis pseudorupestris 
##                                   1                                   1 
##                  Epilobium ciliatum                    Eremogone kingii 
##                                   1                                   1 
##                Ericameria discoidea                   Erigeron bloomeri 
##                                   1                                   1 
##                    Erigeron pumilus                  Eriogonum inflatum 
##                                   1                                   1 
##                    Eriogonum niveum               Eriogonum ovalifolium 
##                                   1                                   1 
##          Eriophyllum confertiflorum                     Eryngium planum 
##                                   1                                   1 
##                  Erythranthe decora                     Euphorbia esula 
##                                   1                                   1 
##                Eurybia integrifolia               Euthamia occidentalis 
##                                   1                                   1 
##                       Ficaria verna           Frasera albicaulis nitida 
##                                   1                                   1 
##                 Fuchsia magellanica                   Galanthus nivalis 
##                                   1                                   1 
##                    Gentiana affinis                  Gentiana newberryi 
##                                   1                                   1 
##                Geranium robertianum                      Geum coccineum 
##                                   1                                   1 
##                      Geum triflorum                  Glechoma hederacea 
##                                   1                                   1 
##                Glycyrrhiza lepidota                 Gypsophila vaccaria 
##                                   1                                   1 
##             Heliopsis helianthoides               Heracleum sphondylium 
##                                   1                                   1 
##                  Heuchera micrantha    Holodiscus discolor microphyllus 
##                                   1                                   1 
##                   Horkelia howellii             Hyacinthoides hispanica 
##                                   1                                   1 
##                Hyssopus officinalis                 Ipomopsis aggregata 
##                                   1                                   1 
##                    Iris douglasiana                     Iris innominata 
##                                   1                                   1 
##                     Ivesia gordonii                    Kalmia polifolia 
##                                   1                                   1 
##                 Kolkwitzia amabilis                    Lactuca serriola 
##                                   1                                   1 
##            Lagerstroemia subcostata               Lasthenia californica 
##                                   1                                   1 
##                Lathyrus lanszwertii                 Leontodon saxatilis 
##                                   1                                   1 
##                Leucanthemum maximum                  Leucophysalis nana 
##                                   1                                   1 
##      Lewisia columbiana wallowensis                 Leycesteria formosa 
##                                   1                                   1 
##                    Ligusticum grayi         Linaria dalmatica dalmatica 
##                                   1                                   1 
##                    Linaria vulgaris                    Linnaea borealis 
##                                   1                                   1 
##                      Lobelia erinus               Lomatium californicum 
##                                   1                                   1 
##                  Lomatium dissectum                Lomatium triternatum 
##                                   1                                   1 
##                     Lupinus breweri                      Madia gracilis 
##                                   1                                   1 
##                        Madia sativa               Maianthemum stellatum 
##                                   1                                   1 
##                    Malus sylvestris                       Malva arborea 
##                                   1                                   1 
##                  Mentha Ã— piperita                   Mentha canadensis 
##                                   1                                   1 
##                      Mentha spicata                Mertensia longiflora 
##                                   1                                   1 
##                   Microseris nutans                  Monarda citriodora 
##                                   1                                   1 
##               Oemleria cerasiformis                 Oenanthe sarmentosa 
##                                   1                                   1 
##                   Oenothera biennis                   Oenothera pallida 
##                                   1                                   1 
##                  Olsynium douglasii                    Packera hesperia 
##                                   1                                   1 
##                    Packera macounii                  Papaver somniferum 
##                                   1                                   1 
##              Pediomelum tenuiflorum             Pelargonium amaryllidis 
##                                   1                                   1 
##                  Penstemon globosus             Penstemon heterophyllus 
##                                   1                                   1 
##                    Penstemon peckii                Penstemon pinifolius 
##                                   1                                   1 
##                  Penstemon wilcoxii         Petasites frigidus palmatus 
##                                   1                                   1 
##             Phacelia hastata alpina       Phacelia heterophylla virgata 
##                                   1                                   1 
##                   Phacelia linearis             Philadelphus coronarius 
##                                   1                                   1 
##                Philadelphus lewisii                       Picea pungens 
##                                   1                                   1 
##                    Picea sitchensis        Plectritis congesta congesta 
##                                   1                                   1 
##                  Polemonium carneum                 Polygonum douglasii 
##                                   1                                   1 
##                Polygonum paronychia                  Potentilla breweri 
##                                   1                                   1 
##                   Prosartes smithii                        Prunus avium 
##                                   1                                   1 
##                    Prunus domestica                 Prunus laurocerasus 
##                                   1                                   1 
##         Prunus subcordata rubicunda                     Pyrrocoma hirta 
##                                   1                                   1 
##               Raphanus raphanistrum                    Raphanus sativus 
##                                   1                                   1 
##                 Reynoutria japonica              Rhododendron menziesii 
##                                   1                                   1 
##                        Ribes inerme                Ribes oxyacanthoides 
##                                   1                                   1 
##                        Ribes rubrum                    Ribes uva-crispa 
##                                   1                                   1 
##                     Rosa multiflora                     Rosa rubiginosa 
##                                   1                                   1 
##                         Rosa rugosa                       Salix boothii 
##                                   1                                   1 
##                        Salix lucida                Salvia dorrii dorrii 
##                                   1                                   1 
##          Santolina chamaecyparissus           Scorzoneroides autumnalis 
##                                   1                                   1 
##            Scutellaria angustifolia                   Sedum lanceolatum 
##                                   1                                   1 
##                     Sedum obtusatum                   Senecio crassulus 
##                                   1                                   1 
##                   Senecio fremontii                    Senecio vulgaris 
##                                   1                                   1 
##                Silphium perfoliatum                        Sinapis alba 
##                                   1                                   1 
##                     Sisymbrium irio                 Sisyrinchium bellum 
##                                   1                                   1 
##                Solanum lycopersicum                  Solidago virgaurea 
##                                   1                                   1 
##                    Sorbus aucuparia                Sphaeralcea munroana 
##                                   1                                   1 
##                      Stachys rigida                   Swainsona formosa 
##                                   1                                   1 
##        Symphyotrichum novae-angliae      Tiarella trifoliata unifoliata 
##                                   1                                   1 
##                    Trifolium hirtum                Trifolium latifolium 
##                                   1                                   1 
##                Trifolium variegatum               Triteleia grandiflora 
##                                   1                                   1 
##             Vaccinium angustifolium               Vaccinium ovalifolium 
##                                   1                                   1 
##               Vaccinium parvifolium               Verbascum densiflorum 
##                                   1                                   1 
##                      Veronica odora                 Veronica scutellata 
##                                   1                                   1 
##                    Viburnum davidii               Viola Ã— wittrockiana 
##                                   1                                   1 
##               Wyethia helianthoides              Aesculus hippocastanum 
##                                   1                                   2 
##             Agastache \nurticifolia                       Ajuga reptans 
##                                   2                                   2 
##                      Allium cernuum                        Allium nevii 
##                                   2                                   2 
##                   Allium triquetrum             Apocynum Ã— floribundum 
##                                   2                                   2 
##           Arctostaphylos columbiana           Arctostaphylos densiflora 
##                                   2                                   2 
##                   Arnica lanceolata                Artemisia tridentata 
##                                   2                                   2 
##                     Aruncus dioicus               Asparagus officinalis 
##                                   2                                   2 
##              Astragalus curvicarpus                 Balsamorhiza incana 
##                                   2                                   2 
##                 Barbarea orthoceras            Calyptridium monospermum 
##                                   2                                   2 
##             Calyptridium umbellatum                   Camassia cusickii 
##                                   2                                   2 
##               Carduus pycnocephalus              Castilleja collegiorum 
##                                   2                                   2 
##          Castilleja hispida hispida                  Ceanothus cuneatus 
##                                   2                                   2 
##                 Ceanothus gloriosus                 Centromadia fitchii 
##                                   2                                   2 
##                 Cirsium brevistylum         Cirsium inamoenum inamoenum 
##                                   2                                   2 
##    Cirsium remotifolium odontolepis                  Clarkia rhomboidea 
##                                   2                                   2 
##               Collinsia sparsiflora              Coreopsis verticillata 
##                                   2                                   2 
##               Cornus unalaschkensis              Cotoneaster franchetii 
##                                   2                                   2 
##                  Cucurbita moschata                    Cuscuta pacifica 
##                                   2                                   2 
##                        Dalea ornata            Dicentra formosa formosa 
##                                   2                                   2 
##                  Dieteria canescens                Doellingeria breweri 
##                                   2                                   2 
##                 Elaeagnus umbellata              Epilobium brachycarpum 
##                                   2                                   2 
##               Epilobium densiflorum                Erica Ã— darleyensis 
##                                   2                                   2 
##        Ericameria nauseosa glabrata                  Erigeron divergens 
##                                   2                                   2 
##                   Erigeron foliosus                  Erodium cicutarium 
##                                   2                                   2 
##                 Erythranthe grandis                Fragaria cascadensis 
##                                   2                                   2 
##                   Gentiana sceptrum                   Geum macrophyllum 
##                                   2                                   2 
##                  Glandora prostrata               Gutierrezia sarothrae 
##                                   2                                   2 
##                  Helenium bolanderi                 Helianthus cusickii 
##                                   2                                   2 
##                   Hosackia gracilis   Hydrophyllum capitatum thompsonii 
##                                   2                                   2 
##            Hydrophyllum occidentale                 Hypericum calycinum 
##                                   2                                   2 
##                 Ladeania lanceolata                   Lathyrus hirsutus 
##                                   2                                   2 
##                 Lathyrus nevadensis                  Lathyrus palustris 
##                                   2                                   2 
##                  Lavandula stoechas                       Linum lewisii 
##                                   2                                   2 
##                      Lupinus burkei                  Lupinus sulphureus 
##                                   2                                   2 
##                Mentzelia albicaulis                  Muscari armeniacum 
##                                   2                                   2 
##                   Myosotis discolor                    Nepeta faassenii 
##                                   2                                   2 
##                Penstemon acuminatus                 Penstemon anguineus 
##                                   2                                   2 
##                 Penstemon confertus                    Penstemon ovatus 
##                                   2                                   2 
##                  Penstemon parvulus           Pentaglottis sempervirens 
##                                   2                                   2 
##                  Phacelia imbricata      Phacelia nemoralis oregonensis 
##                                   2                                   2 
##             Polemonium californicum              Polemonium occidentale 
##                                   2                                   2 
##                 Populus tremuloides                 Primula hendersonii 
##                                   2                                   2 
##            Rhododendron catawbiense            Rhododendron occidentale 
##                                   2                                   2 
##               Rhododendron ponticum                     Ribes velutinum 
##                                   2                                   2 
##                      Rorippa indica                    Rubus fruticosus 
##                                   2                                   2 
##                    Salix planifolia                    Salvia leucantha 
##                                   2                                   2 
##                    Salvia pratensis                 Saussurea americana 
##                                   2                                   2 
##             Scrophularia lanceolata            Scutellaria integrifolia 
##                                   2                                   2 
##                         Sedum album            Sericocarpus oregonensis 
##                                   2                                   2 
##              Spergularia macrotheca             Symphytum Ã— uplandicum 
##                                   2                                   2 
##               Tephroseris helenitis                Teucrium Ã— lucidrys 
##                                   2                                   2 
##              Thermopsis californica                     Thymus vulgaris 
##                                   2                                   2 
##            Toxicoscordion venenosum               Triantha occidentalis 
##                                   2                                   2 
##                   Trifolium arvense             Trifolium macrocephalum 
##                                   2                                   2 
##                 Trifolium productum                     Viburnum opulus 
##                                   2                                   2 
##               Vicia villosa villosa                        Viola adunca 
##                                   2                                   2 
##                  Viola wittrockiana               Abelia Ã— grandiflora 
##                                   2                                   3 
##                   Abronia latifolia                 Amsinckia menziesii 
##                                   3                                   3 
##                  Argentina anserina                  Arnica chamissonis 
##                                   3                                   3 
##                   Arnica cordifolia                   Arnica longifolia 
##                                   3                                   3 
##             Astragalus lentiginosus                 Astragalus whitneyi 
##                                   3                                   3 
##                   Brassica oleracea                  Castilleja miniata 
##                                   3                                   3 
##                   Castilleja pilosa                Ceanothus papillosus 
##                                   3                                   3 
##                Chaenactis douglasii            Chrysolepis sempervirens 
##                                   3                                   3 
##                Collomia grandiflora                   Cotinus coggygria 
##                                   3                                   3 
##               Cotoneaster coriaceus                      Croton setiger 
##                                   3                                   3 
##                    Cucurbita maxima                      Cucurbita pepo 
##                                   3                                   3 
##             Delphinium nuttallianum            Delphinium trolliifolium 
##                                   3                                   3 
##                  Erigeron glacialis                 Erigeron peregrinus 
##                                   3                                   3 
##                  Eriogonum strictum             Erysimum cheiranthoides 
##                                   3                                   3 
##             Erythranthe microphylla                  Euphorbia lathyris 
##                                   3                                   3 
##             Gilia capitata capitata                 Grindelia hirsutula 
##                                   3                                   3 
##                  Iris missouriensis                 Lepidium appelianum 
##                                   3                                   3 
##                  Lilium columbianum                     Lomatium hallii 
##                                   3                                   3 
##                   Lonicera caerulea                  Lonicera hispidula 
##                                   3                                   3 
##               Oenothera lindheimeri               Pedicularis attollens 
##                                   3                                   3 
##                  Penstemon cinicola                Penstemon fruticosus 
##                                   3                                   3 
##               Penstemon spectabilis            Phacelia sericea ciliosa 
##                                   3                                   3 
##                Pilosella caespitosa          Polygonum phytolaccifolium 
##                                   3                                   3 
##            Potentilla flabellifolia                Potentilla norvegica 
##                                   3                                   3 
##                  Purshia tridentata                         Rosa canina 
##                                   3                                   3 
##             Sanguisorba officinalis                      Sedum oreganum 
##                                   3                                   3 
##                Sedum spathulifolium         Sedum stenopetalum ciliosum 
##                                   3                                   3 
##      Solidago spathulata spathulata                 Spiraea betulifolia 
##                                   3                                   3 
##            Symphyotrichum campestre          Symphyotrichum spathulatum 
##                                   3                                   3 
##                      Tagetes erecta                Tetradymia canescens 
##                                   3                                   3 
##                 Tiarella trifoliata                  Trifolium hybridum 
##                                   3                                   3 
##                      Viola glabella                     Viola praemorsa 
##                                   3                                   3 
##                   Allium platycaule            Arctostaphylos canescens 
##                                   4                                   4 
##            Arctostaphylos manzanita                  Argentina pacifica 
##                                   4                                   4 
##              Balsamorhiza deltoidea                       Bidens cernua 
##                                   4                                   4 
##                 Calochortus tolmiei               Castilleja applegatei 
##                                   4                                   4 
##                  Castilleja exserta          Castilleja septentrionalis 
##                                   4                                   4 
##                   Castilleja tenuis                  Collinsia linearis 
##                                   4                                   4 
##                      Cornus sericea            Cotoneaster horizontalis 
##                                   4                                   4 
##                       Crepis setosa                    Dicentra formosa 
##                                   4                                   4 
##                       Erica cinerea                  Erigeron inornatus 
##                                   4                                   4 
##                      Fragaria vesca                   Gentiana calycosa 
##                                   4                                   4 
##                 Gratiola ebracteata                          Iris tenax 
##                                   4                                   4 
##                  Kalmia microphylla                     Kickxia elatine 
##                                   4                                   4 
##              Kopsiopsis strobilacea                Lomatium columbianum 
##                                   4                                   4 
##     Lotus pedunculatus pedunculatus                    Lupinus sericeus 
##                                   4                                   4 
##                       Marah oregana                      Monarda didyma 
##                                   4                                   4 
##                 Nemophila menziesii              Orthocarpus bracteosus 
##                                   4                                   4 
##              Orthocarpus imbricatus                Penstemon attenuatus 
##                                   4                                   4 
##                   Penstemon humilis               Penstemon subserratus 
##                                   4                                   4 
##                 Perideridia oregana                  Phacelia corymbosa 
##                                   4                                   4 
##                  Primula pauciflora                      Prunus persica 
##                                   4                                   4 
##                    Prunus serrulata              Pyrrocoma carthamoides 
##                                   4                                   4 
##             Ranunculus occidentalis                    Satureja montana 
##                                   4                                   4 
##                  Sedum stenopetalum                  Trifolium longipes 
##                                   4                                   4 
##                      Vicia gigantea                      Wyethia mollis 
##                                   4                                   4 
##                   Acer macrophyllum       Aconitum columbianum howellii 
##                                   5                                   5 
##                Agastache foeniculum                         Alcea rosea 
##                                   5                                   5 
##                    Arnica latifolia                Astragalus hoodianus 
##                                   5                                   5 
##               Balsamorhiza careyana                     Bellis perennis 
##                                   5                                   5 
##                  Berberis piperiana                     Cakile maritima 
##                                   5                                   5 
##             Calochortus macrocarpus     Castilleja applegatei pinetorum 
##                                   5                                   5 
##               Castilleja campestris                   Cirsium inamoenum 
##                                   5                                   5 
##                     Cleomella lutea             Doellingeria ledophylla 
##                                   5                                   5 
##  Doellingeria ledophylla ledophylla                  Echinacea purpurea 
##                                   5                                   5 
##                Eriogonum compositum               Euonymus occidentalis 
##                                   5                                   5 
##                 Fragaria chiloensis              Gaillardia pinnatifida 
##                                   5                                   5 
##               Helianthella uniflora                 Hirschfeldia incana 
##                                   5                                   5 
##               Hosackia oblongifolia                   Lavandula dentata 
##                                   5                                   5 
##                Limnanthes douglasii                   Linaria dalmatica 
##                                   5                                   5 
##                    Linaria purpurea                Lupinus leucophyllus 
##                                   5                                   5 
##               Mentzelia laevicaulis                Rhododendron maximum 
##                                   5                                   5 
##                        Ribes nigrum                     Salvia nemorosa 
##                                   5                                   5 
##                    Securigera varia                 Senecio hydrophilus 
##                                   5                                   5 
##                 Solidago spathulata                   Sorbus sitchensis 
##                                   5                                   5 
##                   Stachys byzantina                 Stachys chamissonis 
##                                   5                                   5 
##                   Tolmiea menziesii                  Tonella floribunda 
##                                   5                                   5 
##             Trichostema lanceolatum                Trifolium incarnatum 
##                                   5                                   5 
##                      Zinnia elegans                      Allium validum 
##                                   5                                   6 
##                     Angelica lucida                   Berberis darwinii 
##                                   6                                   6 
##     Camassia leichtlinii suksdorfii                  Campanula scouleri 
##                                   6                                   6 
##            Chrysolepis chrysophylla                    Cicuta douglasii 
##                                   6                                   6 
##                Delphinium menziesii              Drymocallis glandulosa 
##                                   6                                   6 
##                        Erica carnea                    Eriogonum elatum 
##                                   6                                   6 
##                Eucryphia cordifolia                Gaillardia pulchella 
##                                   6                                   6 
##                  Gentiana andrewsii                    Geranium lucidum 
##                                   6                                   6 
##                      Hosackia rosea              Hydrophyllum capitatum 
##                                   6                                   6 
##                Lathyrus polyphyllus               Lavandula pedunculata 
##                                   6                                   6 
##                   Linaria maroccana                  Lupinus albicaulis 
##                                   6                                   6 
##                  Nepeta grandiflora                 Penstemon glaucinus 
##                                   6                                   6 
##                Penstemon serrulatus               Perideridia gairdneri 
##                                   6                                   6 
##           Plagiobothrys nothofulvus                   Ranunculus repens 
##                                   6                                   6 
##               Rudbeckia glaucescens                     Rudbeckia hirta 
##                                   6                                   6 
##                       Salvia dorrii               Trifolium vesiculosum 
##                                   6                                   6 
##                Valeriana sitchensis                    Whipplea modesta 
##                                   6                                   6 
##               Wyethia amplexicaulis           Abies grandis Ã— concolor 
##                                   6                                   7 
##                     Agoseris glauca                       Arnica mollis 
##                                   7                                   7 
##                Canadanthus modestus                   Centaurea montana 
##                                   7                                   7 
##                    Eurybia radulina                   Geranium oreganum 
##                                   7                                   7 
##                Hackelia californica               Hydrophyllum fendleri 
##                                   7                                   7 
##                    Kniphofia uvaria                  Lathyrus japonicus 
##                                   7                                   7 
##                   Luetkea pectinata                     Pieris japonica 
##                                   7                                   7 
##                    Salix hookeriana                      Salvia greggii 
##                                   7                                   7 
##                  Salvia officinalis                 Sidalcea malviflora 
##                                   7                                   7 
##                      Spiraea lucida         Symphyotrichum bracteolatum 
##                                   7                                   7 
##               Symphyotrichum patens               Taraxia tanacetifolia 
##                                   7                                   7 
##                 Tellima grandiflora              Thelypodium laciniatum 
##                                   7                                   7 
##              Thermopsis rhombifolia              Trifolium eriocephalum 
##                                   7                                   7 
##                  Acmispon decumbens                    Adelinia grandis 
##                                   8                                   8 
##                   Arbutus menziesii                    Buddleja davidii 
##                                   8                                   8 
##               Calystegia soldanella                Ceanothus cordulatus 
##                                   8                                   8 
##                Ceanothus prostratus                     Centaurea jacea 
##                                   8                                   8 
##      Chaenactis douglasii douglasii                   Clarkia pulchella 
##                                   8                                   8 
##                Collinsia parviflora                Convolvulus arvensis 
##                                   8                                   8 
##                    Erigeron aliceae                Frangula californica 
##                                   8                                   8 
##                    Lupinus arboreus                         Malus fusca 
##                                   8                                   8 
##                      Malva neglecta            Pedicularis groenlandica 
##                                   8                                   8 
##                   Phacelia argentea                    Phacelia procera 
##                                   8                                   8 
##                Phacelia ramosissima            Phyllodoce empetriformis 
##                                   8                                   8 
##             Plagiobothrys figuratus                 Plantago lanceolata 
##                                   8                                   8 
##                    Potentilla recta                    Salix sitchensis 
##                                   8                                   8 
##                    Sedum oregonense                   Solanum dulcamara 
##                                   8                                   8 
##                    Stachys mexicana                 Thermopsis gracilis 
##                                   8                                   8 
##                 Cleomella serrulata                  Crataegus monogyna 
##                                   9                                   9 
##              Grindelia integrifolia                      Grindelia nana 
##                                   9                                   9 
##                  Hackelia micrantha                  Helenium bigelovii 
##                                   9                                   9 
##                Hosackia crassifolia                   Iliamna rivularis 
##                                   9                                   9 
##                      Jaumea carnosa                     Nepeta racemosa 
##                                   9                                   9 
##                    Penstemon laetus              Penstemon richardsonii 
##                                   9                                   9 
##                   Prunus virginiana                   Rubus spectabilis 
##                                   9                                   9 
##              Senecio hydrophiloides                 Sidalcea nelsoniana 
##                                   9                                   9 
##                    Sidalcea virgata          Smithiastrum prenanthoides 
##                                   9                                   9 
##                    Spiraea japonica               Trifolium willdenovii 
##                                   9                                   9 
##                     Acer circinatum              Arctostaphylos viscida 
##                                  10                                  10 
##                  Borago officinalis                   Centaurea diffusa 
##                                  10                                  10 
##                Fagopyrum esculentum                Horkelia hendersonii 
##                                  10                                  10 
##                  Hypericum scouleri                    Lapsana communis 
##                                  10                                  10 
##                 Lathyrus sylvestris                  Mahonia aquifolium 
##                                  10                                  10 
##                     Medicago sativa              Orthocarpus cuspidatus 
##                                  10                                  10 
##                 Penstemon speciosus                    Phacelia sericea 
##                                  10                                  10 
##       Raphanus raphanistrum sativus                     Rosa gymnocarpa 
##                                  10                                  10 
##                Senecio integerrimus               Sisymbrium altissimum 
##                                  10                                  10 
##        Symphoricarpos rotundifolius                        Vicia cracca 
##                                  10                                  10 
##                   Amorpha fruticosa                       Brassica rapa 
##                                  11                                  11 
##                 Dasiphora fruticosa                  Eremogone congesta 
##                                  11                                  11 
##                  Erigeron speciosus                 Erythranthe guttata 
##                                  11                                  11 
##                  Frangula purshiana                  Frasera albicaulis 
##                                  11                                  11 
##                  Hymenoxys hoopesii               Lithospermum ruderale 
##                                  11                                  11 
##                   Lythrum salicaria                 Nepeta Ã— faassenii 
##                                  11                                  11 
##                Penstemon davidsonii                    Rubus laciniatus 
##                                  11                                  11 
##                   Salvia rosmarinus             Symphyotrichum chilense 
##                                  11                                  11 
##                    Syringa vulgaris                   Tanacetum vulgare 
##                                  11                                  11 
##               Tithonia rotundifolia              Trifolium wormskioldii 
##                                  11                                  11 
##           Arctostaphylos nevadensis                  Astragalus filipes 
##                                  12                                  12 
##              Balsamorhiza sagittata                    Calluna vulgaris 
##                                  12                                  12 
##          Cirsium cymosum canovirens                   Cosmos bipinnatus 
##                                  12                                  12 
##                 Gaillardia aristata                   Heracleum maximum 
##                                  12                                  12 
##                   Lupinus albifrons                Pedicularis racemosa 
##                                  12                                  12 
##              Rubus idaeus strigosus               Triteleia hyacinthina 
##                                  12                                  12 
##              Ageratina occidentalis                Allium schoenoprasum 
##                                  13                                  13 
##              Asclepias fascicularis                   Bellardia viscosa 
##                                  13                                  13 
##                   Cirsium scariosum   Eriophyllum lanatum integrifolium 
##                                  13                                  13 
##                  Helenium autumnale                Lonicera involucrata 
##                                  13                                  13 
##                   Marrubium vulgare                   Mertensia ciliata 
##                                  13                                  13 
##                Mertensia paniculata                  Penstemon venustus 
##                                  13                                  13 
##                    Primula jeffreyi                    Ribes sanguineum 
##                                  13                                  13 
##                    Styrax japonicus                   Verbascum thapsus 
##                                  13                                  13 
##             Arctostaphylos uva-ursi               Bistorta bistortoides 
##                                  14                                  14 
##              Centaurea solstitialis                     Cirsium cymosum 
##                                  14                                  14 
##              Eriogonum heracleoides                    Frasera speciosa 
##                                  14                                  14 
##                   Helianthus exilis                   Lupinus argenteus 
##                                  14                                  14 
##                     Malus domestica                      Rubus vestitus 
##                                  14                                  14 
##                   Styrax americanus              Calochortus eurycarpus 
##                                  14                                  15 
##                Columbiadoria hallii           Eriogonum sphaerocephalum 
##                                  15                                  15 
##                 Penstemon rydbergii                     Vicia americana 
##                                  15                                  15 
##                     Angelica arguta                      Boykinia major 
##                                  16                                  16 
##                Lonicera conjugialis                 Penstemon hesperius 
##                                  16                                  16 
##           Primula jeffreyi jeffreyi            Rhododendron columbianum 
##                                  16                                  16 
##                Robinia pseudoacacia                Vancouveria hexandra 
##                                  16                                  16 
##             Centaurea Ã— moncktonii                   Cirsium undulatum 
##                                  17                                  17 
##                Oreostemma alpigenum                       Salvia yangii 
##                                  17                                  17 
##                Camassia leichtlinii                 Erythranthe lewisii 
##                                  18                                  18 
##                   Glebionis segetum                   Kyhosia bolanderi 
##                                  18                                  18 
##                  Thermopsis montana                  Claytonia sibirica 
##                                  18                                  19 
##               Collinsia grandiflora                       Daucus carota 
##                                  19                                  19 
##               Physocarpus capitatus               Symphoricarpos mollis 
##                                  19                                  19 
##                  Asclepias speciosa                    Lamium purpureum 
##                                  20                                  20 
##                     Lupinus bicolor                   Monarda fistulosa 
##                                  20                                  20 
##                Aconitum columbianum                   Aquilegia formosa 
##                                  21                                  21 
##               Arctostaphylos patula            Eriodictyon californicum 
##                                  21                                  21 
##                Vaccinium uliginosum                Caragana arborescens 
##                                  21                                  22 
##                    Escallonia rubra                    Lupinus arbustus 
##                                  22                                  22 
##                Penstemon cardwellii                        Rosa nutkana 
##                                  22                                  22 
##                    Origanum vulgare                   Allium acuminatum 
##                                  23                                  24 
##                   Cytisus scoparius                 Teucrium chamaedrys 
##                                  24                                  24 
##                Angelica capitellata                   Ceanothus pumilus 
##                                  25                                  25 
##                    Centaurea cyanus                 Grindelia squarrosa 
##                                  25                                  25 
##                        Rubus idaeus            Scrophularia californica 
##                                  25                                  25 
##                   Solidago velutina              Cynoglossum officinale 
##                                  25                                  26 
##                Delphinium nuttallii                Senecio triangularis 
##                                  26                                  26 
##                     Eriogonum nudum                  Lotus pedunculatus 
##                                  27                                  27 
##               Nothochelone nemorosa                        Ribes aureum 
##                                  27                                  27 
##                 Heuchera cylindrica                 Penstemon euglaucus 
##                                  28                                  28 
##                 Sidalcea campestris              Calochortus subalpinus 
##                                  28                                  29 
##                 Berberis aquifolium                      Clarkia amoena 
##                                  30                                  30 
##             Ericameria linearifolia                      Gilia capitata 
##                                  30                                  30 
##                       Madia elegans        Prunella vulgaris lanceolata 
##                                  30                                  30 
##                Wyethia angustifolia                      Carduus nutans 
##                                  30                                  31 
##                      Horkelia fusca                Taraxacum officinale 
##                                  31                                  31 
##                   Allium amplectens                   Cichorium intybus 
##                                  32                                  32 
##                     Lupinus lepidus                        Rosa woodsii 
##                                  32                                  32 
##               Hydrophyllum tenuipes                 Lupinus polyphyllus 
##                                  33                                  33 
##                       Cirsium edule                  Lupinus latifolius 
##                                  34                                  34 
##                  Monardella villosa                   Rupertia physodes 
##                                  34                                  35 
##                   Solidago elongata                  Ericameria greenei 
##                                  35                                  36 
##                 Holodiscus discolor                   Spiraea splendens 
##                                  36                                  36 
##                Achillea millefolium                  Phacelia nemoralis 
##                                  38                                  38 
##                 Potentilla gracilis                Cirsium remotifolium 
##                                  38                                  39 
##                Vaccinium corymbosum                  Lupinus littoralis 
##                                  39                                  40 
##           Rhododendron macrophyllum                  Digitalis purpurea 
##                                  40                                  41 
##                       Senecio serra                    Camassia quamash 
##                                  41                                  42 
##                Leucanthemum vulgare                 Onopordum acanthium 
##                                  42                                  42 
##                  Phacelia mutabilis                  Penstemon procerus 
##                                  42                                  43 
##                 Plectritis congesta                        Vicia sativa 
##                                  43                                  43 
##                      Nepeta cataria                 Solidago canadensis 
##                                  44                                  44 
##              Ceanothus integerrimus                   Penstemon deustus 
##                                  46                                  46 
##           Apocynum androsaemifolium                Eriogonum umbellatum 
##                                  48                                  49 
##          Symphyotrichum subspicatum                   Prunus emarginata 
##                                  49                                  50 
##                    Rubus armeniacus                     Melilotus albus 
##                                  50                                  53 
##                 Eriophyllum lanatum                   Dipsacus fullonum 
##                                  54                                  55 
##                    Vaccinium ovatum              Geranium viscosissimum 
##                                  55                                  57 
##                   Grindelia stricta         Chrysothamnus viscidiflorus 
##                                  58                                  60 
##              Rudbeckia occidentalis                     Solidago lepida 
##                                  61                                  61 
##              Lavandula angustifolia                   Lupinus rivularis 
##                                  62                                  62 
##                        Ribes cereum              Anaphalis margaritacea 
##                                  64                                  65 
##                  Gaultheria shallon                        Rubus rolfei 
##                                  65                                  67 
##                    Sidalcea oregana                   Jacobaea vulgaris 
##                                  67                                  76 
##               Melilotus officinalis                  Lotus corniculatus 
##                                  77                                  80 
##            Symphyotrichum foliaceum                     Cirsium arvense 
##                                  80                                  87 
##                     Mentha pulegium             Monardella odoratissima 
##                                  90                                  90 
##               Phacelia heterophylla                 Lathyrus latifolius 
##                                  91                                  93 
##                    Centaurea stoebe                      Cirsium peckii 
##                                  96                                  97 
##                   Rubus parviflorus                   Prunella vulgaris 
##                                  98                                 104 
##                Hypericum perforatum                 Ceanothus velutinus 
##                                 107                                 115 
##                    Trifolium repens            Eschscholzia californica 
##                                 117                                 122 
##              Phacelia tanacetifolia                Hypochaeris radicata 
##                                 125                                 131 
##                   Helianthus annuus               Agastache urticifolia 
##                                 142                                 146 
##              Ceanothus thyrsiflorus                       Rubus ursinus 
##                                 151                                 167 
##                Symphoricarpos albus                   Spiraea douglasii 
##                                 203                                 212 
##                  Trifolium pratense                 Ericameria bloomeri 
##                                 216                                 224 
##                       Rubus bifrons                    Phacelia hastata 
##                                 253                                 270 
##                     Cirsium vulgare                       Vicia villosa 
##                                 274                                 284 
##                 Ericameria nauseosa          Chamaenerion angustifolium 
##                                 422                                 443
```
We have a variety of options for converting of data (which is basically an edge list) into a graph. One is to sum up our interactions but bee-plant combinations to make an bipartite adjacency matrix. Then convert that matrix to a igraph object. 


```
## [1]  25 826
```

```
##                     PlantGenusSpecies
## GenusSpecies         Abelia Ã— grandiflora Abies grandis Ã— concolor
##   Bombus appositus                       0                         0
##   Bombus caliginosus                     0                         0
##   Bombus centralis                       0                         0
##   Bombus fervidus                        0                         0
##   Bombus flavidus                        0                         0
##                     PlantGenusSpecies
## GenusSpecies         Abronia latifolia Acer circinatum Acer macrophyllum
##   Bombus appositus                   0               0                 0
##   Bombus caliginosus                 1               0                 0
##   Bombus centralis                   0               0                 0
##   Bombus fervidus                    2               0                 0
##   Bombus flavidus                    0               0                 0
```


```
## IGRAPH a32848a UNWB 851 2679 -- 
## + attr: type (v/l), name (v/c), weight (e/n)
## + edges from a32848a (vertex names):
##  [1] Bombus vosnesenskii  --Abelia Ã— grandiflora    
##  [2] Bombus vancouverensis--Abies grandis Ã— concolor
##  [3] Bombus vandykei      --Abies grandis Ã— concolor
##  [4] Bombus caliginosus   --Abronia latifolia        
##  [5] Bombus fervidus      --Abronia latifolia        
##  [6] Bombus mixtus        --Acer circinatum          
##  [7] Bombus vosnesenskii  --Acer circinatum          
##  [8] Bombus melanopygus   --Acer macrophyllum        
## + ... omitted several edges
```

To use the 'forceNetwork' function to make a beautiful visualization, we need to convert our graph into a dataframe. Luckily there is a function 'igraph_to_networkD3' to convert from graph objects to what the network3d package wants. That function also wants a each vertex assigned to a group. We have a variety of options on how to assign groups, one is to look for modules or compartments in the network. 


```{=html}
<div class="forceNetwork html-widget html-fill-item" id="htmlwidget-b911c034ae109840a4f5" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-b911c034ae109840a4f5">{"x":{"links":{"source":[24,23,22,3,1,24,12,24,17,12,11,3,21,23,7,4,22,11,1,24,12,6,14,24,24,21,6,22,12,23,0,22,6,24,23,1,12,6,24,1,22,14,24,3,23,20,24,23,3,15,0,10,21,12,22,4,7,13,11,14,2,6,8,12,10,4,22,22,22,2,3,23,0,7,2,11,12,2,0,22,24,3,24,11,12,12,4,24,24,22,11,12,24,24,11,4,22,1,24,7,24,11,1,24,2,6,1,24,5,22,12,4,16,16,22,6,24,4,12,10,24,2,3,22,19,24,6,12,19,7,22,0,14,3,16,7,24,2,12,8,23,22,7,24,6,3,12,23,12,11,12,24,12,17,24,24,11,1,12,24,24,6,12,6,24,4,22,11,11,24,22,4,1,22,11,24,12,1,6,12,17,11,24,11,24,18,24,12,22,24,22,4,17,6,4,2,12,22,19,15,3,8,17,4,7,14,22,4,6,24,7,24,14,12,8,24,1,11,8,0,2,7,14,8,3,2,6,8,24,14,2,11,2,2,8,23,7,14,24,12,4,8,14,2,23,3,14,7,22,24,12,15,11,3,0,24,18,24,7,17,3,24,11,6,12,12,1,4,11,24,11,11,12,24,24,10,11,22,4,24,24,6,8,12,17,22,11,6,4,24,12,12,23,24,16,11,12,3,24,12,1,24,12,24,3,12,11,3,12,24,7,22,3,24,2,3,11,24,22,12,24,24,12,11,22,24,12,3,11,24,16,22,3,12,24,12,24,8,24,23,3,6,11,17,12,22,14,24,22,12,6,12,23,22,12,3,14,8,7,22,24,24,15,3,7,0,6,8,23,10,2,24,3,3,3,8,24,22,6,22,12,24,22,6,3,6,3,4,10,3,24,11,12,24,12,12,24,11,23,11,24,10,22,1,6,3,12,11,2,22,24,11,12,12,24,11,12,24,11,17,18,6,23,16,1,11,24,2,12,6,15,8,23,1,22,11,22,3,4,7,24,12,6,12,4,24,6,3,8,16,2,7,23,24,8,7,2,12,24,4,12,22,6,24,13,6,15,24,12,23,3,7,14,8,16,11,2,1,4,22,3,23,24,11,2,24,2,8,22,24,22,18,6,19,23,3,8,11,1,5,7,2,0,4,15,17,12,10,6,24,22,12,24,24,22,22,8,10,23,0,19,3,24,15,1,22,2,6,22,16,11,6,2,3,24,1,12,1,22,24,0,8,4,2,7,22,24,3,1,16,6,15,12,19,0,18,6,10,3,1,2,22,13,14,2,0,3,8,7,17,22,6,12,3,1,4,2,3,3,6,22,20,12,8,19,0,14,3,2,23,4,6,0,12,24,24,6,10,24,0,2,3,14,13,24,3,2,7,5,8,23,21,13,2,1,3,4,22,6,24,0,17,10,12,7,0,7,24,1,3,12,6,17,14,1,24,0,2,24,1,24,24,11,1,12,18,17,8,7,12,8,7,13,24,17,12,24,6,11,23,22,24,10,24,12,6,24,22,24,3,6,18,22,4,24,6,7,16,3,8,19,24,24,24,24,8,12,15,11,24,11,1,12,24,11,12,11,1,12,24,12,11,4,24,14,24,7,24,24,24,7,3,7,24,1,12,3,24,3,8,12,6,22,2,7,11,24,12,3,1,17,13,14,24,22,24,11,12,3,24,4,24,3,0,6,6,3,8,3,24,23,12,6,0,3,8,6,24,3,12,22,24,4,3,17,1,6,12,24,12,14,1,7,8,3,2,6,16,0,22,10,24,22,22,24,11,22,24,12,4,22,24,3,7,17,24,2,24,24,24,2,22,19,22,24,24,11,24,12,23,10,24,22,15,5,8,11,4,12,19,24,12,22,6,24,15,8,22,14,10,13,7,8,0,16,3,2,22,24,15,19,8,2,17,23,4,10,22,10,24,15,12,22,24,22,22,10,22,8,24,16,10,19,12,3,22,4,11,24,1,12,3,24,22,24,12,22,10,2,22,24,24,22,12,24,11,8,4,23,24,24,23,10,22,2,8,6,11,6,18,6,24,12,10,7,0,4,8,3,22,22,4,24,12,10,24,7,24,6,22,12,24,2,24,12,22,0,6,8,3,22,11,24,12,24,24,12,17,4,1,11,3,17,7,1,12,24,24,12,24,22,23,24,10,12,24,22,6,10,6,12,24,24,22,24,24,12,17,24,12,12,24,11,11,12,3,12,2,22,4,20,22,1,12,24,22,7,2,22,10,8,24,10,24,17,12,4,24,6,1,11,0,22,3,6,22,6,1,22,24,11,12,24,11,1,12,6,11,16,8,20,4,22,12,6,2,12,22,22,12,4,3,22,16,6,24,24,6,11,16,12,24,6,7,24,24,1,23,3,24,1,0,12,16,8,22,22,8,16,24,4,10,19,24,16,11,3,12,1,22,3,24,4,10,12,11,2,24,12,6,4,22,11,3,12,24,16,7,22,10,4,11,12,22,2,3,13,24,23,7,8,22,16,10,14,2,4,2,22,24,24,17,6,12,6,11,8,10,24,22,2,1,8,12,22,13,2,24,6,17,12,15,24,4,6,10,22,2,11,20,3,12,24,22,10,4,24,24,4,6,1,24,4,1,12,17,6,23,6,22,3,2,12,23,4,24,12,22,6,4,17,12,1,6,12,15,19,10,22,6,12,3,21,22,18,0,24,23,1,6,12,7,11,22,24,17,1,6,12,11,10,7,17,4,22,24,9,3,16,6,2,12,22,16,15,24,6,24,11,6,6,24,11,22,11,24,22,7,0,17,12,4,16,1,24,1,12,22,12,11,24,3,12,6,8,12,24,24,22,10,8,8,7,24,24,6,17,1,4,12,12,23,24,6,3,3,3,24,1,3,11,24,7,11,8,14,3,6,0,24,1,6,1,6,6,24,3,24,23,2,6,12,1,7,3,24,14,8,24,11,24,12,24,22,24,4,24,12,3,1,6,15,11,7,10,2,24,22,6,4,24,12,6,7,2,14,3,3,1,3,24,12,3,24,22,8,24,3,7,23,2,12,24,14,24,24,12,11,24,12,24,2,3,10,4,22,23,11,24,6,12,11,3,22,3,24,6,17,16,11,1,4,22,6,7,12,24,18,24,12,22,24,24,24,22,17,3,24,6,12,24,22,13,8,2,6,12,24,22,12,24,23,1,11,22,22,24,12,22,3,17,18,1,6,8,7,22,12,23,6,14,24,17,22,2,6,3,11,24,1,12,14,6,12,23,3,16,11,24,22,11,6,3,24,1,12,22,2,23,14,2,12,1,8,7,24,24,2,0,24,24,8,12,15,23,24,2,24,4,1,6,12,24,12,4,24,11,22,22,24,16,8,24,18,6,12,8,24,3,22,13,8,7,3,14,24,11,8,2,22,16,7,3,21,24,12,23,4,16,14,7,24,3,8,22,4,2,24,10,7,24,3,0,22,12,24,8,13,24,14,19,8,12,6,17,22,11,12,22,17,24,12,11,6,10,6,6,7,22,2,23,24,13,15,14,3,6,8,21,19,24,6,10,16,14,23,0,11,2,4,12,22,3,12,4,6,24,5,23,17,12,12,24,12,3,24,23,7,8,12,6,1,6,13,11,0,12,24,7,3,14,2,23,16,8,1,24,6,24,6,7,24,0,22,23,6,17,24,11,12,24,12,1,24,1,3,24,24,0,8,2,3,7,22,14,22,4,17,12,24,10,23,11,12,6,24,3,3,22,22,24,22,6,24,24,24,22,11,17,17,12,6,24,18,22,2,2,3,14,24,22,6,6,12,22,24,22,6,6,21,12,2,16,24,22,3,11,19,21,22,3,23,14,16,6,11,10,2,24,0,6,3,24,17,23,22,12,24,22,3,2,22,23,24,0,3,24,11,6,12,6,23,2,3,24,6,22,11,22,6,23,11,22,12,10,4,2,24,23,8,3,8,23,6,4,24,22,22,6,24,3,2,22,8,12,22,11,12,24,22,16,0,2,8,6,6,11,12,22,24,24,22,24,11,1,24,18,17,12,12,24,8,13,11,16,6,2,23,19,1,22,20,7,3,17,4,10,22,7,23,8,22,16,24,1,6,2,10,3,12,2,24,24,2,12,1,24,22,6,4,17,23,12,23,24,22,6,1,12,1,12,10,24,2,24,23,20,22,19,10,22,10,7,11,3,24,16,1,12,13,6,8,17,24,24,12,19,22,24,24,12,11,18,6,24,12,24,6,11,22,3,10,11,12,24,24,4,10,12,8,6,24,1,11,1,24,22,2,17,12,12,22,11,1,6,24,24,12,24,6,22,12,4,22,12,15,3,24,22,6,22,2,24,22,11,1,22,11,24,12,12,11,6,24,11,12,17,1,3,12,0,23,6,24,1,6,11,3,24,0,1,24,6,11,24,22,16,8,12,16,12,1,18,24,17,12,22,8,12,24,2,11,0,22,8,0,24,24,11,17,24,11,12,24,24,24,6,14,1,3,24,24,11,12,12,11,18,17,4,6,24,11,12,3,1,7,12,11,17,12,24,11,14,12,23,11,2,24,8,3,14,23,11,22,24,2,8,12,11,1,24,12,1,17,6,3,12,1,24,11,1,8,24,14,2,8,7,24,6,13,24,12,12,11,6,18,17,12,22,24,24,6,1,16,11,12,3,12,12,2,8,7,16,14,22,24,12,3,12,6,4,11,24,18,1,0,2,24,3,15,12,11,23,8,4,17,1,18,6,16,7,0,22,12,12,24,22,4,11,1,12,24,6,1,6,17,12,17,18,1,0,11,15,12,22,24,6,12,11,24,6,1,6,17,1,11,4,12,22,17,23,18,3,6,24,17,6,3,12,24,17,24,7,8,12,24,12,24,4,22,10,17,2,6,16,4,24,11,3,7,1,6,12,22,12,11,17,24,22,19,11,24,8,3,2,2,3,7,24,24,11,11,12,6,3,11,13,3,24,1,6,12,23,1,24,12,22,6,24,21,8,22,11,6,17,1,12,23,6,0,3,24,22,24,19,24,4,22,4,24,12,24,22,12,2,22,12,24,10,19,12,22,2,10,10,22,12,24,22,4,11,8,2,3,4,19,10,22,22,11,17,24,10,12,4,24,24,12,12,6,1,24,11,6,7,24,12,24,1,12,6,2,8,4,7,23,11,10,24,22,12,3,6,3,24,6,12,11,14,24,2,8,7,3,7,12,24,1,23,12,10,21,2,24,8,20,24,24,3,4,22,7,12,2,10,1,22,24,15,12,18,15,17,22,12,24,11,4,16,10,24,1,12,12,22,4,10,24,7,11,22,24,12,3,23,22,11,1,12,10,18,13,7,15,17,22,3,8,24,16,6,2,12,24,8,12,22,21,6,17,12,11,24,22,12,1,14,16,24,3,1,12,6,1,23,11,6,6,16,3,12,24,2,2,15,1,3,4,23,10,16,0,6,11,24,12,17,8,18,22,11,6,24,12,22,14,12,3,2,22,16,8,24,16,22,24,22,3,1,22,6,24,23,4,12,24,10,22,2,24,22,22,4,7,1,6,15,24,12,10,3,12,11,1,24,1,24,1,7,6,13,11,4,12,22,3,24,1,8,14,24,2,3,11,12,24,16,2,1,3,3,24,7,2,8,3,23,6,24,6,24,7,8,14,3,6,8,3,13,12,17,6,24,7,3,0,17,22,12,2,12,3,24,24,24,19,12,3,24,11,0,24,24,8,14,8,12,14,3,22,22,8,6,8,2,24,0,14,1,7,3,6,6,3,1,4,11,16,12,8,24,6,22,2,3,24,11,1,24,6,12,3,1,24,14,12,10,22,24,11,6,12,1,24,11,17,11,12,1,16,17,4,24,11,1,22,4,12,24,11,12,22,4,6,12,1,1,3,2,24,8,22,6,7,12,24,3,2,7,2,3,22,24,6,8,14,23,24,0,1,6,3,1,24,11,8,3,23,6,12,1,2,7,3,17,16,6,0,24,11,23,8,14,12,22,24,11,6,12,11,11,24,3,0,1,12,16,24,17,22,11,2,16,3,4,6,24,14,11,22,0,7,12,19,10,22,2,3,24],"target":[25,26,26,27,27,28,28,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,32,33,33,33,33,33,33,34,34,35,36,36,36,36,37,38,39,39,40,40,40,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,42,42,42,42,43,44,44,45,46,47,47,47,48,48,48,48,48,48,48,49,49,49,50,51,52,53,53,54,54,54,55,55,56,56,57,58,59,59,59,60,60,61,62,62,62,62,62,62,62,62,63,64,64,64,64,64,65,65,65,65,65,65,66,66,66,67,68,68,69,69,69,69,69,69,69,69,69,69,69,70,71,71,71,71,71,72,73,73,73,74,75,76,77,77,78,78,79,80,80,80,81,81,81,81,81,82,82,82,83,83,83,83,83,83,84,84,84,84,84,84,85,85,86,86,86,87,87,88,89,89,90,90,91,91,92,92,92,93,93,94,94,95,95,95,95,95,96,97,97,97,97,97,98,98,99,100,100,101,102,102,102,102,102,103,103,103,103,104,105,106,107,108,109,109,109,109,110,110,111,112,113,113,113,113,113,113,113,113,113,114,115,115,115,116,116,117,117,117,117,117,117,117,118,118,118,118,119,119,120,121,121,122,122,122,122,122,123,124,124,124,124,125,125,125,125,125,125,125,126,127,127,127,127,127,128,129,129,129,130,131,131,131,132,133,133,133,133,134,134,134,135,135,135,136,136,136,137,137,138,139,139,140,140,141,141,141,141,142,142,143,143,143,144,144,145,145,145,145,145,145,145,145,145,145,146,146,146,147,147,147,147,148,148,148,148,148,148,148,149,149,149,149,149,149,149,149,149,149,150,151,152,153,154,154,154,155,155,156,156,156,157,158,159,160,161,161,162,163,163,163,164,164,165,165,166,167,167,167,167,167,167,167,167,167,168,169,169,169,169,170,171,171,171,172,172,172,172,172,172,172,172,172,173,174,174,174,174,174,174,174,174,174,174,175,175,175,175,175,175,175,176,176,176,176,176,176,176,176,176,176,177,177,177,177,178,178,178,179,179,179,180,181,181,181,181,181,181,181,181,181,181,181,181,181,181,181,181,182,183,183,184,185,185,186,186,187,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,189,190,191,191,191,192,192,193,194,194,194,194,194,194,194,194,194,194,194,194,195,195,195,195,195,195,195,195,196,196,196,196,197,198,198,198,198,198,198,198,198,198,198,198,198,198,198,199,199,200,200,200,200,200,200,201,201,201,201,201,201,202,202,202,202,202,202,202,203,203,204,205,205,205,205,205,205,205,205,205,205,206,206,206,206,206,206,207,208,208,208,208,208,208,209,209,209,209,209,209,210,210,210,210,210,210,210,210,210,210,210,210,210,210,210,210,210,211,211,211,211,211,211,211,211,211,212,213,214,214,215,216,216,217,217,217,217,217,217,218,218,218,219,219,219,219,220,221,221,221,222,222,222,222,223,223,223,224,224,225,226,226,227,228,228,228,228,228,229,229,229,229,229,229,230,231,232,232,233,233,234,234,235,235,236,237,237,238,238,239,240,241,241,241,242,243,243,244,244,245,246,247,247,248,248,249,250,250,251,252,253,253,253,253,253,253,253,254,254,254,254,254,254,255,255,256,257,257,257,258,258,258,258,259,260,261,261,262,262,262,263,263,263,263,263,263,264,265,266,266,267,268,268,269,269,269,269,269,269,269,270,270,270,270,270,270,270,270,270,270,270,271,271,272,272,273,273,274,274,274,274,274,275,276,276,276,277,277,278,278,279,280,281,281,281,282,283,284,284,285,285,286,286,286,286,286,286,286,286,286,286,287,288,288,288,288,289,289,289,289,290,290,290,290,290,290,290,290,290,290,290,290,290,291,291,292,292,292,292,292,293,294,294,295,295,296,296,297,298,298,299,300,300,300,300,300,300,300,300,301,301,301,301,302,302,303,303,303,304,304,304,305,306,307,307,307,308,309,309,310,310,310,311,311,311,311,311,311,311,311,312,313,313,313,313,313,313,313,313,313,313,313,314,314,314,314,314,315,315,316,317,317,318,319,320,320,320,320,320,321,321,321,321,321,321,322,322,323,323,323,323,323,324,324,324,324,324,324,324,325,326,326,327,328,329,330,330,330,330,330,331,332,332,332,333,334,334,335,335,336,336,336,337,337,337,338,338,339,339,339,339,340,341,341,342,343,343,343,343,343,344,344,345,345,345,346,347,347,347,347,347,347,347,348,349,349,349,350,351,352,352,353,353,353,354,354,354,354,355,356,356,356,356,356,356,356,356,356,357,358,359,360,360,360,360,360,360,360,361,362,362,363,363,363,364,365,366,367,367,367,368,368,368,368,368,369,369,369,370,370,370,370,370,370,370,371,371,371,371,371,371,372,373,374,374,374,374,374,375,375,375,375,375,375,376,376,376,376,376,376,377,377,377,378,378,379,379,380,380,380,380,380,380,380,380,380,380,380,380,381,382,382,383,384,384,384,385,386,386,386,386,386,386,387,388,388,389,389,389,389,389,389,389,390,391,391,391,391,391,391,391,391,391,391,392,392,392,392,393,394,394,394,395,396,396,397,397,397,398,399,399,399,399,399,400,400,401,401,401,401,402,402,403,403,403,403,404,404,404,404,404,405,405,406,406,406,406,406,406,406,406,406,406,406,406,407,407,407,408,408,408,408,408,408,408,408,408,408,408,408,408,409,410,410,410,410,410,411,412,413,414,414,415,415,415,416,417,417,417,417,417,417,417,417,417,417,418,418,418,419,419,420,421,421,422,422,423,424,424,425,425,425,426,427,427,428,429,429,429,429,429,429,430,430,430,430,430,431,432,433,433,433,433,434,435,435,435,435,435,435,435,435,435,436,437,438,439,439,439,440,440,440,440,440,440,440,440,441,441,441,442,442,443,443,444,445,446,447,447,447,447,447,447,447,447,447,448,449,450,451,452,452,453,453,453,454,454,454,454,455,456,456,457,457,458,459,460,460,461,461,461,461,461,462,463,464,464,465,466,466,466,467,468,468,468,469,469,469,469,469,469,470,471,471,471,472,472,472,472,472,472,472,473,473,473,473,473,473,473,473,474,474,475,475,476,477,477,478,478,478,479,479,479,479,479,480,480,480,480,480,480,481,481,481,481,481,482,483,484,484,484,484,484,484,484,484,485,485,485,485,485,485,485,485,485,486,486,486,487,487,487,487,487,488,488,488,488,488,488,488,488,488,489,489,489,489,489,489,490,490,490,491,491,492,492,492,492,492,493,493,493,494,495,496,496,496,496,496,496,497,498,498,498,498,498,499,499,499,499,499,500,501,502,502,502,503,503,503,504,504,504,504,504,505,505,505,505,505,505,506,506,506,506,506,506,506,506,506,506,506,507,507,507,507,507,507,507,507,507,508,509,510,510,510,510,510,510,511,512,512,513,513,513,513,514,514,514,514,514,515,516,516,516,516,516,516,517,518,519,520,520,520,520,520,520,520,520,520,520,520,520,521,521,521,521,521,521,521,521,521,521,521,521,521,521,522,522,522,522,522,522,523,523,524,525,525,525,526,526,526,526,526,526,526,527,527,527,527,527,527,527,527,527,527,527,527,527,528,528,529,529,530,530,530,531,531,531,531,531,531,531,531,532,533,534,535,535,536,537,538,538,538,538,538,538,538,538,539,539,539,539,539,539,539,539,540,540,540,540,541,541,542,542,543,543,544,545,546,547,548,548,549,549,549,549,549,549,550,551,552,552,553,554,554,555,555,555,555,556,556,557,557,558,558,558,558,558,558,558,558,559,559,559,559,559,559,559,559,559,559,559,559,560,560,560,560,560,560,560,561,561,562,562,562,562,562,563,564,564,564,564,564,565,566,566,567,567,568,569,570,571,572,572,572,572,572,572,572,572,572,573,573,573,574,574,574,574,574,574,575,575,575,576,576,576,576,577,577,578,578,578,579,579,579,579,579,579,580,581,581,582,582,583,583,584,585,585,585,585,585,586,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,588,589,589,589,589,589,589,589,589,589,589,589,589,590,591,592,593,593,593,593,593,593,593,593,593,594,594,594,594,594,594,595,595,596,596,596,597,597,597,598,598,598,598,599,599,600,600,600,600,600,600,600,600,600,600,600,601,602,603,603,603,603,604,604,604,604,604,605,606,607,607,607,608,608,608,609,609,609,610,610,610,610,610,611,611,611,612,612,612,612,612,612,612,613,614,614,615,616,616,617,618,619,619,620,621,622,622,623,623,623,623,623,623,624,625,625,625,626,626,627,627,627,627,628,628,628,628,629,629,629,630,631,631,631,631,631,631,631,632,632,632,632,632,632,633,634,635,635,635,635,635,635,636,637,637,637,638,638,638,639,640,640,640,640,640,641,641,641,642,642,643,644,644,644,645,645,645,646,647,647,647,647,647,648,649,650,650,651,651,651,652,652,652,652,652,652,652,652,652,653,653,654,655,655,656,657,657,657,657,657,657,657,657,658,658,658,658,658,658,658,658,659,660,660,661,662,663,663,663,663,663,663,663,664,665,665,666,666,666,666,666,666,666,667,667,668,668,669,669,669,669,669,670,671,671,671,671,671,671,671,672,673,674,674,674,674,674,674,674,674,675,675,675,675,675,675,675,675,675,676,676,676,676,676,676,676,676,676,676,676,676,676,676,676,676,676,677,678,678,678,678,678,679,679,679,679,680,680,680,680,681,681,681,681,681,681,681,681,681,681,682,682,682,682,682,683,683,684,684,684,684,684,684,684,684,684,684,684,685,685,685,685,685,686,686,687,687,687,687,688,688,688,688,688,688,688,688,688,689,689,689,689,689,689,689,689,690,691,691,691,692,693,693,694,694,695,695,695,696,697,697,697,698,698,699,699,700,700,700,700,701,702,702,702,702,703,703,703,704,704,704,705,706,706,707,708,709,709,709,709,710,710,711,712,713,713,714,715,716,717,718,718,718,718,719,719,719,720,720,721,721,722,723,724,724,724,724,725,725,726,726,726,726,726,727,727,727,727,727,727,727,728,728,728,728,728,728,728,729,730,730,731,731,731,731,731,732,732,732,732,733,733,733,733,734,734,734,734,734,734,734,734,734,734,734,734,735,735,735,735,736,737,738,738,738,738,738,739,740,741,741,741,741,741,742,742,742,742,742,743,744,744,744,744,744,744,744,745,745,745,745,745,745,746,746,746,746,746,746,746,746,746,746,747,748,748,749,749,749,749,749,750,751,752,752,752,753,754,755,756,756,756,756,756,756,756,756,756,756,756,756,756,756,756,757,757,757,757,758,758,758,758,759,759,759,759,759,760,760,760,760,760,761,761,761,762,762,763,764,764,765,765,765,765,765,766,767,767,767,767,767,767,767,767,767,767,767,767,767,767,767,767,767,768,768,768,768,769,769,769,769,769,770,770,770,770,771,771,772,772,772,772,773,773,773,773,773,773,774,775,775,775,776,776,777,777,777,777,777,777,777,777,777,778,779,779,779,780,780,781,781,781,782,782,782,782,782,782,782,782,782,783,783,783,783,784,784,784,784,785,786,787,787,788,788,788,789,789,789,789,790,790,791,791,792,792,792,792,792,793,793,793,794,795,796,797,797,797,797,798,799,799,799,800,800,801,802,803,803,804,804,804,804,804,805,806,806,806,807,807,807,807,808,809,809,810,810,811,811,811,811,811,811,811,811,812,813,813,813,813,813,813,813,813,813,813,814,815,815,816,816,816,816,817,817,817,817,818,819,819,819,819,820,821,821,821,821,821,822,823,823,823,823,823,823,823,824,825,825,825,825,825,826,826,826,826,827,827,827,828,829,829,829,829,829,829,829,830,831,832,833,833,834,834,834,834,834,834,834,834,835,835,835,836,836,837,837,837,837,837,837,837,837,838,838,838,838,838,838,838,838,838,838,838,838,838,838,839,840,841,842,842,842,843,843,844,844,845,845,845,845,845,846,846,846,846,847,847,847,847,847,847,847,847,847,847,848,849,849,849,850,850],"value":[3,5,2,2,1,5,5,1,1,1,2,3,2,1,1,1,10,1,2,14,1,1,1,1,8,1,11,2,1,2,4,1,4,1,1,1,2,4,1,2,1,1,3,1,1,1,12,5,7,1,8,6,2,4,21,1,3,1,1,6,27,31,9,1,1,2,9,1,4,3,2,1,1,1,3,1,1,6,1,11,1,3,10,3,19,2,1,2,1,3,10,1,2,1,1,1,5,1,1,8,1,2,1,2,1,2,1,13,1,34,6,7,1,1,8,1,2,4,1,4,2,1,2,14,2,3,1,2,1,1,1,4,3,1,2,8,5,1,2,3,1,18,1,1,2,1,16,1,1,4,2,2,1,1,1,1,3,1,1,2,1,1,2,1,3,1,1,6,14,4,3,1,2,2,4,4,1,1,1,2,1,1,4,1,2,1,2,1,2,1,3,1,1,2,3,2,1,5,1,1,1,1,1,1,9,1,1,1,1,1,11,3,1,2,3,1,1,1,1,1,1,1,2,1,2,6,1,1,2,1,1,3,1,1,3,1,1,1,2,1,3,1,2,3,1,1,1,1,1,2,1,1,2,8,1,4,2,3,1,1,1,10,6,1,10,1,2,1,2,2,3,1,1,3,4,1,3,5,1,1,2,2,1,5,2,1,3,1,4,3,2,3,4,3,1,1,2,1,3,3,2,1,2,2,1,1,2,1,1,8,1,13,1,1,2,2,1,6,22,3,1,1,1,1,1,1,2,2,2,2,1,1,1,15,2,4,2,1,7,1,3,3,7,1,14,4,1,3,1,2,2,1,1,3,1,1,3,2,7,1,7,4,1,9,1,1,3,1,1,6,4,2,1,4,5,1,2,2,1,1,1,2,1,1,2,3,3,1,3,4,4,2,2,1,1,1,1,1,4,4,9,3,1,1,2,2,20,3,1,3,1,3,1,3,4,18,45,23,54,2,4,3,1,1,18,1,34,2,14,2,4,1,1,1,46,10,3,1,3,1,6,2,1,1,1,7,1,2,3,2,2,3,3,4,2,3,1,1,6,1,3,1,3,14,1,5,1,18,1,6,3,2,2,10,1,1,5,1,2,37,1,1,1,1,2,1,7,1,1,104,89,4,47,1,15,4,2,4,10,1,2,16,1,37,3,8,88,7,1,1,1,1,4,1,2,1,22,1,1,1,1,1,19,1,1,9,2,1,1,3,1,1,1,4,20,1,2,1,1,2,1,6,7,4,4,12,20,3,1,2,2,1,22,1,2,1,1,1,8,1,2,1,1,1,2,2,4,2,1,3,3,3,2,1,12,10,1,4,2,5,2,1,1,1,1,3,7,66,10,2,10,18,1,1,7,2,1,1,1,1,7,2,1,1,1,8,2,4,1,13,9,2,2,11,15,75,6,11,28,80,5,1,3,7,5,1,10,8,1,2,5,1,1,1,1,1,1,7,1,1,1,2,1,1,13,1,1,1,3,1,1,3,4,1,1,6,4,9,1,1,1,1,1,2,5,1,1,1,1,2,1,1,7,1,5,1,1,2,1,2,1,1,1,2,1,3,1,1,1,11,1,2,3,1,1,3,1,1,1,1,1,7,1,3,1,1,2,1,1,2,1,1,1,3,1,1,1,1,2,1,2,6,5,7,3,3,4,11,1,2,3,1,1,1,5,3,3,2,5,11,1,1,1,1,5,1,1,1,1,1,1,2,20,1,3,1,3,1,2,1,1,7,1,5,4,5,13,6,9,3,1,3,2,3,20,2,10,1,1,1,1,1,4,3,2,1,1,2,1,1,1,3,1,1,1,1,1,1,1,2,1,6,4,1,2,5,1,3,1,4,3,60,131,12,1,2,2,7,2,1,3,2,30,1,3,2,1,24,3,6,8,20,129,1,4,3,8,132,101,6,1,1,1,1,1,1,2,3,1,1,1,1,1,2,1,4,1,2,1,2,1,1,2,1,1,2,1,5,10,2,4,1,4,1,4,1,12,1,1,1,1,11,15,1,1,1,14,1,1,1,17,1,1,15,1,6,1,7,1,1,1,14,4,4,2,2,8,1,1,16,7,3,1,1,1,1,1,1,2,1,1,2,2,4,3,1,1,2,1,1,12,1,1,1,2,7,5,2,1,7,1,5,2,2,1,2,109,6,1,4,1,3,1,1,1,1,3,1,1,1,4,5,1,1,1,3,2,1,1,2,3,4,1,4,7,1,4,1,5,1,6,8,1,1,4,3,3,1,2,3,1,3,2,1,4,11,2,6,10,15,17,1,2,3,1,4,1,1,1,3,1,2,2,2,1,2,1,1,2,1,11,1,26,3,5,7,1,2,1,5,2,3,4,1,1,14,3,1,1,1,4,13,1,1,4,1,1,1,2,2,3,1,1,1,1,7,9,4,4,4,2,1,1,14,3,1,11,21,8,2,1,1,1,1,2,2,1,1,1,2,1,3,1,2,1,4,2,3,5,3,1,1,1,3,2,25,5,12,1,48,41,2,1,1,2,3,1,2,4,10,1,1,3,8,1,1,1,8,1,6,11,1,2,3,8,1,1,15,3,2,6,1,3,2,2,4,12,1,1,3,1,2,1,6,1,2,1,2,1,6,2,1,4,4,1,1,1,1,1,2,1,1,1,1,2,1,2,2,1,1,1,18,2,12,1,1,1,1,7,1,1,4,2,31,1,1,37,1,3,4,19,1,3,7,2,1,8,2,33,3,3,1,2,7,1,55,1,12,3,1,4,1,1,2,1,1,1,1,2,1,1,2,1,1,2,43,1,4,1,4,8,4,1,8,3,2,4,1,3,1,1,3,5,2,1,3,1,3,11,4,1,1,1,1,5,3,2,2,1,7,3,2,3,1,1,1,2,1,4,1,1,1,6,1,1,3,32,7,3,34,6,2,2,6,4,2,4,16,20,3,3,3,10,2,5,2,1,2,1,5,1,1,1,3,1,11,16,5,2,2,1,1,1,3,1,1,1,1,1,2,1,1,3,1,1,2,1,1,2,4,3,2,1,1,1,1,1,1,1,1,7,1,1,1,3,1,1,1,1,1,1,1,1,3,6,3,1,2,1,3,11,1,1,26,2,45,1,1,3,2,1,2,2,3,1,1,16,1,3,1,5,2,6,6,6,1,2,5,2,1,11,7,1,1,1,1,1,7,3,5,10,2,1,2,1,2,11,12,5,1,1,1,1,2,1,1,15,1,1,1,1,10,1,3,1,1,2,4,16,11,7,3,1,5,2,2,1,3,10,6,9,4,2,14,4,29,2,1,1,1,1,1,1,1,1,7,28,1,1,1,1,1,1,1,1,5,1,1,1,5,1,2,5,2,1,1,3,1,1,1,6,1,1,1,2,1,6,1,4,1,1,1,1,3,2,1,2,6,2,5,1,13,1,2,17,2,1,3,3,1,2,3,1,40,20,1,6,1,1,9,73,1,1,1,5,1,1,1,2,1,1,1,3,7,1,1,1,1,1,2,1,6,2,1,1,1,4,1,2,1,2,1,1,1,2,1,3,2,3,1,21,2,7,2,1,2,3,12,8,2,5,15,9,4,2,3,11,1,13,1,1,2,1,1,2,4,1,1,2,1,1,1,2,2,2,1,1,14,3,3,2,3,1,1,9,1,1,5,1,4,1,4,1,6,1,10,1,6,1,1,1,1,1,2,1,1,1,1,1,12,5,9,7,4,3,7,1,1,1,2,1,2,2,5,3,13,2,2,2,9,1,3,1,1,1,1,3,1,7,3,2,1,3,1,2,1,1,1,1,2,3,1,8,6,4,4,2,1,1,1,1,1,1,1,4,1,1,1,1,2,8,1,5,1,8,2,1,12,1,4,6,1,11,1,2,5,2,2,1,1,1,1,1,2,1,1,1,1,5,8,1,3,1,2,7,2,2,1,1,6,1,6,13,8,2,2,4,1,6,2,1,2,2,2,1,4,4,1,3,2,4,2,3,1,1,2,1,1,2,3,2,1,2,1,4,1,1,1,5,1,3,1,1,2,3,1,1,1,4,20,43,9,1,5,2,13,55,38,1,1,61,1,5,2,1,9,3,1,2,10,3,3,1,23,9,4,21,1,1,13,1,2,1,3,3,4,9,5,9,2,5,2,13,3,6,3,9,4,1,1,2,1,5,2,5,1,1,4,4,1,2,1,23,1,2,64,1,1,14,2,8,8,1,1,1,1,2,4,1,4,6,6,2,1,1,1,2,3,2,1,1,1,1,1,6,1,1,1,2,1,4,3,1,9,2,17,5,1,1,8,1,1,1,1,1,1,1,1,2,1,2,1,1,2,4,1,1,10,21,1,3,1,1,6,1,1,1,5,1,6,5,9,1,1,2,1,1,1,36,10,7,1,20,24,6,4,1,14,5,5,1,1,1,28,6,6,1,1,8,1,1,1,2,2,1,1,1,1,1,4,2,1,1,1,1,3,1,1,2,1,1,1,2,3,1,5,1,1,1,2,1,1,1,1,14,1,1,9,3,3,3,5,12,1,3,1,2,3,1,1,1,2,1,4,5,3,7,5,1,1,1,2,16,11,12,11,6,5,1,4,1,1,1,1,4,1,2,2,1,2,1,1,1,4,2,2,1,2,4,1,1,1,2,1,1,1,1,6,1,1,6,1,2,1,2,9,1,1,1,8,4,2,4,1,1,2,10,1,26,1,1,5,8,2,5,1,4,66,6,1,80,14,2,1,1,12,41,3,9,3,8,1,1,2,12,5,2,1,5,3,5,3,1,1,1,3,6,9,4,6,1,3,2,53,1,9,10,11,11,22,15,8,2,7,27,15,3,69,2,17,1,2,2,9,20,3,1,1,7,2,1,5,2,1,1,2,2,9,2,33,7,1,3,3,1,2,4,1,4,1,1,20,2,1,4,2,1,1,1,1,3,5,1,1,4,1,3,1,3,1,1,2,3,3,1,1,2,2,2,3,1,5,6,2,9,1,1,1,1,3,1,2,1,1,20,1,3,1,1,1,2,2,3,2,1,1,3,3,1,3,1,1,1,1,1,3,2,1,1,1,1,6,1,1,2,3,1,2,1,2,4,2,6,1,3,5,5,19,8,1,1,1,4,3,8,1,1,1,9,5,1,10,3,1,1,3,2,3,2,3,1,12,1,1,1,2,2,7,11,22,3,1,4,1,1,1,6,1,1,1,3,2,1,3,1,1,2,1,2,3,1,1,2,3,1,1,1,24,4,1,5,2,7,1,1,1,14,14,1,4,1,1,4,22,5,14,2,4,1,7,5,2,1,3,11,5,1,5,1,1,3,1,1,2,1,3,1,4,19,3,2,1,3,4,5,91,3,3,61,1,11,1,3,4,1,3,2,1,1,2,9,2,8,15,1,1,1,1,1,2,1,2,7,1,1,4,10,4,1,1,3,4,1,6,1,19,2,4,5,1,3,2,23,9,17,101,1,1,1,7,1,1,7,10,6,1,1,1,1,2,3,1,1,1,2,7,2,1,1,56,1,19,1,2,1,1,1,5,1,2,1,18,1,3,2,1,1,19,3,1,2,2,4,5,2,1,9,1,1,1,1,2,1,7,1,2,15,1,3,2,1,1,1,1,1,4,2,3,1,1,5,17,2,3,1,2,1,1,1,4,4,4,1,7,2,4,2,4,1,2,3,1,5,3,2,1,5,1,1,3,1,1,2,5,1,1,1,2,1,2,1,1,1,1,1,1,1,2,1,1,3,1,1,1,1,94,19,1,2,4,92,3,2,16,16,5,4,1,32,1,26,10,6,1,5,1,1,2,2,4,1,6,1,3,1,5,1,5,1,1,16,2,2,3,16,1,17,18,6,1,5,1,7,1,1,3,2,14,1,1,2,1,2,6,7,3,1,1,2,2,1,3,1,3,1,1,1,1,1,1,4,1,1,2,1,2,3,5,3,2,3,1,1,2,1,2,14,1,8,14,16,4,5,41,1,4,57,10,55,1,30,2,13,45,2,1,2,1,1,1,2,1,1,1,1,2,1,1,1,3,1,1,1,6,3,1,4,1,6,2,3,3,1,1,1,2,1,2,3],"colour":["#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666"]},"nodes":{"name":["Bombus appositus","Bombus caliginosus","Bombus centralis","Bombus fervidus","Bombus flavidus","Bombus flavidus ","Bombus flavifrons","Bombus griseocollis","Bombus huntii","Bombus impatiens","Bombus insularis","Bombus melanopygus","Bombus mixtus","Bombus morrisoni","Bombus nevadensis","Bombus occidentalis","Bombus rufocinctus","Bombus sitkensis","Bombus sitkensis ","Bombus sylvicola","Bombus sylvicola ","Bombus vagans","Bombus vancouverensis","Bombus vandykei","Bombus vosnesenskii","Abelia Ã— grandiflora","Abies grandis Ã— concolor","Abronia latifolia","Acer circinatum","Acer macrophyllum","Achillea millefolium","Acmispon americanus","Acmispon decumbens","Aconitum columbianum","Aconitum columbianum howellii","Actaea elata alpestris","Adelinia grandis","Aegopodium podagraria","Aesculus hippocastanum","Agastache \nurticifolia","Agastache foeniculum","Agastache urticifolia","Ageratina occidentalis","Agoseris aurantiaca","Agoseris glauca","Ajuga reptans","Alcea biennis","Alcea rosea","Allium acuminatum","Allium amplectens","Allium cernuum","Allium crenulatum","Allium nevii","Allium platycaule","Allium schoenoprasum","Allium triquetrum","Allium validum","Allotropa virgata","Amelanchier alnifolia","Amorpha fruticosa","Amsinckia menziesii","Amsinckia tessellata","Anaphalis margaritacea","Anchusa officinalis","Angelica arguta","Angelica capitellata","Angelica lucida","Antennaria media","Apocynum Ã— floribundum","Apocynum androsaemifolium","Apocynum cannabinum","Aquilegia formosa","Aquilegia vulgaris","Arbutus menziesii","Arctium minus","Arctostaphylos Ã— media","Arctostaphylos bakeri","Arctostaphylos canescens","Arctostaphylos columbiana","Arctostaphylos densiflora","Arctostaphylos manzanita","Arctostaphylos nevadensis","Arctostaphylos patula","Arctostaphylos uva-ursi","Arctostaphylos viscida","Argentina anserina","Argentina pacifica","Arnica chamissonis","Arnica cordifolia","Arnica lanceolata","Arnica latifolia","Arnica longifolia","Arnica mollis","Artemisia tridentata","Aruncus dioicus","Asclepias fascicularis","Asclepias incarnata","Asclepias speciosa","Asparagus officinalis","Astragalus accidens","Astragalus curvicarpus","Astragalus cusickii","Astragalus filipes","Astragalus hoodianus","Astragalus iodanthus","Astragalus lentiginosus","Astragalus racemosus","Astragalus sheldonii","Astragalus whitneyi","Balsamorhiza careyana","Balsamorhiza deltoidea","Balsamorhiza hookeri","Balsamorhiza incana","Balsamorhiza sagittata","Barbarea orthoceras","Bellardia viscosa","Bellis perennis","Berberis aquifolium","Berberis darwinii","Berberis piperiana","Berberis repens","Bidens cernua","Bistorta bistortoides","Blepharipappus scaber","Borago officinalis","Boykinia major","Brassica oleracea","Brassica rapa","Brodiaea elegans","Buddleja davidii","Cakile edentula","Cakile maritima","Calendula officinalis","Calluna vulgaris","Calochortus eurycarpus","Calochortus macrocarpus","Calochortus subalpinus","Calochortus tolmiei","Caltha leptosepala","Calyptridium monospermum","Calyptridium umbellatum","Calystegia soldanella","Camassia cusickii","Camassia leichtlinii","Camassia leichtlinii suksdorfii","Camassia quamash","Campanula scouleri","Canadanthus modestus","Caragana arborescens","Carduus nutans","Carduus pycnocephalus","Castilleja ambigua","Castilleja applegatei","Castilleja applegatei pinetorum","Castilleja campestris","Castilleja collegiorum","Castilleja exserta","Castilleja hispida","Castilleja hispida hispida","Castilleja miniata","Castilleja pilosa","Castilleja septentrionalis","Castilleja tenuis","Ceanothus cordulatus","Ceanothus cuneatus","Ceanothus gloriosus","Ceanothus impressus","Ceanothus integerrimus","Ceanothus papillosus","Ceanothus prostratus","Ceanothus prostratus prostratus","Ceanothus pumilus","Ceanothus thyrsiflorus","Ceanothus thyrsiflorus thyrsiflorus","Ceanothus velutinus","Centaurea Ã— moncktonii","Centaurea cyanus","Centaurea diffusa","Centaurea jacea","Centaurea montana","Centaurea solstitialis","Centaurea stoebe","Centaurium erythraea","Centromadia fitchii","Cercis occidentalis","Chaenactis douglasii","Chaenactis douglasii douglasii","Chamaebatiaria millefolium","Chamaenerion angustifolium","Chimaphila umbellata","Chondrilla juncea","Chrysolepis chrysophylla","Chrysolepis sempervirens","Chrysopsis mariana","Chrysothamnus viscidiflorus","Cichorium intybus","Cicuta douglasii","Cirsium andersonii","Cirsium arvense","Cirsium brevistylum","Cirsium cymosum","Cirsium cymosum canovirens","Cirsium edule","Cirsium inamoenum","Cirsium inamoenum inamoenum","Cirsium peckii","Cirsium remotifolium","Cirsium remotifolium odontolepis","Cirsium scariosum","Cirsium undulatum","Cirsium vulgare","Clarkia amoena","Clarkia amoena caurina","Clarkia amoena lindleyi","Clarkia pulchella","Clarkia purpurea","Clarkia rhomboidea","Claytonia sibirica","Cleomella lutea","Cleomella serrulata","Clinopodium vulgare","Collinsia grandiflora","Collinsia linearis","Collinsia parviflora","Collinsia sparsiflora","Collinsia torreyi","Collomia grandiflora","Collomia mazama","Columbiadoria hallii","Convolvulus arvensis","Cordylanthus tenuis","Coreopsis verticillata","Cornus sericea","Cornus unalaschkensis","Cosmos bipinnatus","Cotinus coggygria","Cotoneaster coriaceus","Cotoneaster franchetii","Cotoneaster horizontalis","Crassula tetragona","Crataegus douglasii","Crataegus monogyna","Crepis acuminata","Crepis setosa","Croton setiger","Cryptantha intermedia","Cucumis sativus","Cucurbita maxima","Cucurbita moschata","Cucurbita pepo","Cuscuta pacifica","Cynara cardunculus","Cynara cardunculus flavescens","Cynoglossum officinale","Cytisus scoparius","Dalea ornata","Damasonium californicum","Dasiphora fruticosa","Daucus carota","Delosperma cooperi","Delphinium leucophaeum","Delphinium menziesii","Delphinium nuttallianum","Delphinium nuttallii","Delphinium trolliifolium","Descurainia sophia","Dicentra formosa","Dicentra formosa formosa","Dieteria canescens","Digitalis purpurea","Dipsacus fullonum","Doellingeria breweri","Doellingeria ledophylla","Doellingeria ledophylla ledophylla","Drymocallis glandulosa","Drymocallis pseudorupestris","Echinacea purpurea","Elaeagnus umbellata","Epilobium brachycarpum","Epilobium ciliatum","Epilobium densiflorum","Eremogone congesta","Eremogone kingii","Erica Ã— darleyensis","Erica carnea","Erica cinerea","Ericameria bloomeri","Ericameria discoidea","Ericameria greenei","Ericameria linearifolia","Ericameria nauseosa","Ericameria nauseosa glabrata","Erigeron aliceae","Erigeron bloomeri","Erigeron divergens","Erigeron foliosus","Erigeron glacialis","Erigeron inornatus","Erigeron peregrinus","Erigeron pumilus","Erigeron speciosus","Eriodictyon californicum","Eriogonum compositum","Eriogonum elatum","Eriogonum heracleoides","Eriogonum inflatum","Eriogonum niveum","Eriogonum nudum","Eriogonum ovalifolium","Eriogonum sphaerocephalum","Eriogonum strictum","Eriogonum umbellatum","Eriophyllum confertiflorum","Eriophyllum lanatum","Eriophyllum lanatum integrifolium","Erodium cicutarium","Eryngium planum","Erysimum cheiranthoides","Erythranthe decora","Erythranthe grandis","Erythranthe guttata","Erythranthe lewisii","Erythranthe microphylla","Escallonia rubra","Eschscholzia californica","Eucryphia cordifolia","Euonymus occidentalis","Euphorbia esula","Euphorbia lathyris","Eurybia integrifolia","Eurybia radulina","Euthamia occidentalis","Fagopyrum esculentum","Ficaria verna","Fragaria cascadensis","Fragaria chiloensis","Fragaria vesca","Frangula californica","Frangula purshiana","Frasera albicaulis","Frasera albicaulis nitida","Frasera speciosa","Fuchsia magellanica","Gaillardia aristata","Gaillardia pinnatifida","Gaillardia pulchella","Galanthus nivalis","Gaultheria shallon","Gentiana affinis","Gentiana andrewsii","Gentiana calycosa","Gentiana newberryi","Gentiana sceptrum","Geranium lucidum","Geranium oreganum","Geranium robertianum","Geranium viscosissimum","Geum coccineum","Geum macrophyllum","Geum triflorum","Gilia capitata","Gilia capitata capitata","Glandora prostrata","Glebionis segetum","Glechoma hederacea","Glycyrrhiza lepidota","Gratiola ebracteata","Grindelia hirsutula","Grindelia integrifolia","Grindelia nana","Grindelia squarrosa","Grindelia stricta","Gutierrezia sarothrae","Gypsophila vaccaria","Hackelia californica","Hackelia micrantha","Helenium autumnale","Helenium bigelovii","Helenium bolanderi","Helianthella uniflora","Helianthus annuus","Helianthus cusickii","Helianthus exilis","Heliopsis helianthoides","Heracleum maximum","Heracleum sphondylium","Heuchera cylindrica","Heuchera micrantha","Hirschfeldia incana","Holodiscus discolor","Holodiscus discolor microphyllus","Horkelia fusca","Horkelia hendersonii","Horkelia howellii","Hosackia crassifolia","Hosackia gracilis","Hosackia oblongifolia","Hosackia rosea","Hyacinthoides hispanica","Hydrophyllum capitatum","Hydrophyllum capitatum thompsonii","Hydrophyllum fendleri","Hydrophyllum occidentale","Hydrophyllum tenuipes","Hymenoxys hoopesii","Hypericum calycinum","Hypericum perforatum","Hypericum scouleri","Hypochaeris radicata","Hyssopus officinalis","Iliamna rivularis","Ipomopsis aggregata","Iris douglasiana","Iris innominata","Iris missouriensis","Iris tenax","Ivesia gordonii","Jacobaea vulgaris","Jaumea carnosa","Kalmia microphylla","Kalmia polifolia","Kickxia elatine","Kniphofia uvaria","Kolkwitzia amabilis","Kopsiopsis strobilacea","Kyhosia bolanderi","Lactuca serriola","Ladeania lanceolata","Lagerstroemia subcostata","Lamium purpureum","Lapsana communis","Lasthenia californica","Lathyrus hirsutus","Lathyrus japonicus","Lathyrus lanszwertii","Lathyrus latifolius","Lathyrus nevadensis","Lathyrus palustris","Lathyrus polyphyllus","Lathyrus sylvestris","Lavandula angustifolia","Lavandula dentata","Lavandula pedunculata","Lavandula stoechas","Leontodon saxatilis","Lepidium appelianum","Leucanthemum maximum","Leucanthemum vulgare","Leucophysalis nana","Lewisia columbiana wallowensis","Leycesteria formosa","Ligusticum grayi","Lilium columbianum","Limnanthes douglasii","Linaria dalmatica","Linaria dalmatica dalmatica","Linaria maroccana","Linaria purpurea","Linaria vulgaris","Linnaea borealis","Linum lewisii","Lithospermum ruderale","Lobelia erinus","Lomatium californicum","Lomatium columbianum","Lomatium dissectum","Lomatium hallii","Lomatium triternatum","Lonicera caerulea","Lonicera conjugialis","Lonicera hispidula","Lonicera involucrata","Lotus corniculatus","Lotus pedunculatus","Lotus pedunculatus pedunculatus","Luetkea pectinata","Lupinus albicaulis","Lupinus albifrons","Lupinus arboreus","Lupinus arbustus","Lupinus argenteus","Lupinus bicolor","Lupinus breweri","Lupinus burkei","Lupinus latifolius","Lupinus lepidus","Lupinus leucophyllus","Lupinus littoralis","Lupinus polyphyllus","Lupinus rivularis","Lupinus sericeus","Lupinus sulphureus","Lythrum salicaria","Madia elegans","Madia gracilis","Madia sativa","Mahonia aquifolium","Maianthemum stellatum","Malus domestica","Malus fusca","Malus sylvestris","Malva arborea","Malva neglecta","Marah oregana","Marrubium vulgare","Medicago sativa","Melilotus albus","Melilotus officinalis","Mentha Ã— piperita","Mentha canadensis","Mentha pulegium","Mentha spicata","Mentzelia albicaulis","Mentzelia laevicaulis","Mertensia ciliata","Mertensia longiflora","Mertensia paniculata","Microseris nutans","Monarda citriodora","Monarda didyma","Monarda fistulosa","Monardella odoratissima","Monardella villosa","Muscari armeniacum","Myosotis discolor","Nemophila menziesii","Nepeta Ã— faassenii","Nepeta cataria","Nepeta faassenii","Nepeta grandiflora","Nepeta racemosa","Nothochelone nemorosa","Oemleria cerasiformis","Oenanthe sarmentosa","Oenothera biennis","Oenothera lindheimeri","Oenothera pallida","Olsynium douglasii","Onopordum acanthium","Oreostemma alpigenum","Origanum vulgare","Orthocarpus bracteosus","Orthocarpus cuspidatus","Orthocarpus imbricatus","Packera hesperia","Packera macounii","Papaver somniferum","Pedicularis attollens","Pedicularis groenlandica","Pedicularis racemosa","Pediomelum tenuiflorum","Pelargonium amaryllidis","Penstemon acuminatus","Penstemon anguineus","Penstemon attenuatus","Penstemon cardwellii","Penstemon cinicola","Penstemon confertus","Penstemon davidsonii","Penstemon deustus","Penstemon euglaucus","Penstemon fruticosus","Penstemon glaucinus","Penstemon globosus","Penstemon hesperius","Penstemon heterophyllus","Penstemon humilis","Penstemon laetus","Penstemon ovatus","Penstemon parvulus","Penstemon peckii","Penstemon pinifolius","Penstemon procerus","Penstemon richardsonii","Penstemon rydbergii","Penstemon serrulatus","Penstemon speciosus","Penstemon spectabilis","Penstemon subserratus","Penstemon venustus","Penstemon wilcoxii","Pentaglottis sempervirens","Perideridia gairdneri","Perideridia oregana","Petasites frigidus palmatus","Phacelia argentea","Phacelia corymbosa","Phacelia hastata","Phacelia hastata alpina","Phacelia heterophylla","Phacelia heterophylla virgata","Phacelia imbricata","Phacelia linearis","Phacelia mutabilis","Phacelia nemoralis","Phacelia nemoralis oregonensis","Phacelia procera","Phacelia ramosissima","Phacelia sericea","Phacelia sericea ciliosa","Phacelia tanacetifolia","Philadelphus coronarius","Philadelphus lewisii","Phyllodoce empetriformis","Physocarpus capitatus","Picea pungens","Picea sitchensis","Pieris japonica","Pilosella caespitosa","Plagiobothrys figuratus","Plagiobothrys nothofulvus","Plantago lanceolata","Plectritis congesta","Plectritis congesta congesta","Polemonium californicum","Polemonium carneum","Polemonium occidentale","Polygonum douglasii","Polygonum paronychia","Polygonum phytolaccifolium","Populus tremuloides","Potentilla breweri","Potentilla flabellifolia","Potentilla gracilis","Potentilla norvegica","Potentilla recta","Primula hendersonii","Primula jeffreyi","Primula jeffreyi jeffreyi","Primula pauciflora","Prosartes smithii","Prunella vulgaris","Prunella vulgaris lanceolata","Prunus avium","Prunus domestica","Prunus emarginata","Prunus laurocerasus","Prunus persica","Prunus serrulata","Prunus subcordata rubicunda","Prunus virginiana","Purshia tridentata","Pyrrocoma carthamoides","Pyrrocoma hirta","Ranunculus occidentalis","Ranunculus repens","Raphanus raphanistrum","Raphanus raphanistrum sativus","Raphanus sativus","Reynoutria japonica","Rhododendron catawbiense","Rhododendron columbianum","Rhododendron macrophyllum","Rhododendron maximum","Rhododendron menziesii","Rhododendron occidentale","Rhododendron ponticum","Ribes aureum","Ribes cereum","Ribes inerme","Ribes nigrum","Ribes oxyacanthoides","Ribes rubrum","Ribes sanguineum","Ribes uva-crispa","Ribes velutinum","Robinia pseudoacacia","Rorippa indica","Rosa canina","Rosa gymnocarpa","Rosa multiflora","Rosa nutkana","Rosa rubiginosa","Rosa rugosa","Rosa woodsii","Rubus armeniacus","Rubus bifrons","Rubus fruticosus","Rubus idaeus","Rubus idaeus strigosus","Rubus laciniatus","Rubus parviflorus","Rubus rolfei","Rubus spectabilis","Rubus ursinus","Rubus vestitus","Rudbeckia glaucescens","Rudbeckia hirta","Rudbeckia occidentalis","Rupertia physodes","Salix boothii","Salix hookeriana","Salix lucida","Salix planifolia","Salix sitchensis","Salvia dorrii","Salvia dorrii dorrii","Salvia greggii","Salvia leucantha","Salvia nemorosa","Salvia officinalis","Salvia pratensis","Salvia rosmarinus","Salvia yangii","Sanguisorba officinalis","Santolina chamaecyparissus","Satureja montana","Saussurea americana","Scorzoneroides autumnalis","Scrophularia californica","Scrophularia lanceolata","Scutellaria angustifolia","Scutellaria integrifolia","Securigera varia","Sedum album","Sedum lanceolatum","Sedum obtusatum","Sedum oreganum","Sedum oregonense","Sedum spathulifolium","Sedum stenopetalum","Sedum stenopetalum ciliosum","Senecio crassulus","Senecio fremontii","Senecio hydrophiloides","Senecio hydrophilus","Senecio integerrimus","Senecio serra","Senecio triangularis","Senecio vulgaris","Sericocarpus oregonensis","Sidalcea campestris","Sidalcea malviflora","Sidalcea nelsoniana","Sidalcea oregana","Sidalcea virgata","Silphium perfoliatum","Sinapis alba","Sisymbrium altissimum","Sisymbrium irio","Sisyrinchium bellum","Smithiastrum prenanthoides","Solanum dulcamara","Solanum lycopersicum","Solidago canadensis","Solidago elongata","Solidago lepida","Solidago spathulata","Solidago spathulata spathulata","Solidago velutina","Solidago virgaurea","Sorbus aucuparia","Sorbus sitchensis","Spergularia macrotheca","Sphaeralcea munroana","Spiraea betulifolia","Spiraea douglasii","Spiraea japonica","Spiraea lucida","Spiraea splendens","Stachys byzantina","Stachys chamissonis","Stachys mexicana","Stachys rigida","Styrax americanus","Styrax japonicus","Swainsona formosa","Symphoricarpos albus","Symphoricarpos mollis","Symphoricarpos rotundifolius","Symphyotrichum bracteolatum","Symphyotrichum campestre","Symphyotrichum chilense","Symphyotrichum foliaceum","Symphyotrichum novae-angliae","Symphyotrichum patens","Symphyotrichum spathulatum","Symphyotrichum subspicatum","Symphytum Ã— uplandicum","Syringa vulgaris","Tagetes erecta","Tanacetum vulgare","Taraxacum officinale","Taraxia tanacetifolia","Tellima grandiflora","Tephroseris helenitis","Tetradymia canescens","Teucrium Ã— lucidrys","Teucrium chamaedrys","Thelypodium laciniatum","Thermopsis californica","Thermopsis gracilis","Thermopsis montana","Thermopsis rhombifolia","Thymus vulgaris","Tiarella trifoliata","Tiarella trifoliata unifoliata","Tithonia rotundifolia","Tolmiea menziesii","Tonella floribunda","Toxicoscordion venenosum","Triantha occidentalis","Trichostema lanceolatum","Trifolium arvense","Trifolium eriocephalum","Trifolium hirtum","Trifolium hybridum","Trifolium incarnatum","Trifolium latifolium","Trifolium longipes","Trifolium macrocephalum","Trifolium pratense","Trifolium productum","Trifolium repens","Trifolium variegatum","Trifolium vesiculosum","Trifolium willdenovii","Trifolium wormskioldii","Triteleia grandiflora","Triteleia hyacinthina","Vaccinium angustifolium","Vaccinium corymbosum","Vaccinium ovalifolium","Vaccinium ovatum","Vaccinium parvifolium","Vaccinium uliginosum","Valeriana sitchensis","Vancouveria hexandra","Verbascum densiflorum","Verbascum thapsus","Veronica odora","Veronica scutellata","Viburnum davidii","Viburnum opulus","Vicia americana","Vicia cracca","Vicia gigantea","Vicia sativa","Vicia villosa","Vicia villosa villosa","Viola Ã— wittrockiana","Viola adunca","Viola glabella","Viola praemorsa","Viola wittrockiana","Whipplea modesta","Wyethia amplexicaulis","Wyethia angustifolia","Wyethia helianthoides","Wyethia mollis","Zinnia elegans"],"group":[6,1,10,6,4,5,3,2,2,12,4,1,1,2,2,4,4,9,1,8,11,7,4,3,5,13,3,6,5,1,1,14,15,3,3,16,3,17,18,2,5,1,4,19,4,20,21,10,1,1,22,23,24,4,1,1,4,25,26,2,1,27,5,28,5,5,5,29,2,5,30,5,31,1,32,33,34,1,1,35,5,1,1,1,1,1,5,4,36,9,3,10,4,2,9,2,37,5,1,38,6,39,2,5,40,41,42,43,44,5,1,45,46,5,47,5,1,1,1,1,48,5,1,49,5,1,50,1,51,5,52,5,53,1,4,5,1,1,54,1,4,1,4,5,1,1,5,3,5,5,55,56,57,58,5,3,5,59,60,61,62,4,63,1,1,1,64,1,65,1,66,1,1,67,1,5,5,5,5,3,5,1,68,3,69,10,10,70,1,71,72,5,4,73,5,1,5,74,5,1,4,2,3,6,75,3,5,76,5,5,5,5,77,78,10,79,1,1,2,2,80,5,1,5,3,81,6,82,5,5,83,84,2,4,1,1,85,1,1,86,87,1,88,2,2,89,90,5,6,91,1,92,93,3,1,2,94,1,5,95,96,3,3,5,97,98,3,99,4,5,5,4,4,4,1,100,5,9,10,101,102,8,103,104,1,5,1,105,5,5,5,10,4,106,4,4,5,107,4,108,4,1,5,5,4,109,110,5,111,2,5,1,112,5,5,2,113,3,114,115,5,1,1,5,1,116,5,117,118,119,5,120,5,121,4,5,5,1,1,4,122,11,123,5,4,5,124,1,125,3,126,127,1,1,1,128,4,129,130,131,5,132,1,5,133,134,135,5,5,4,5,1,136,137,1,5,1,4,1,4,5,138,5,139,3,140,5,141,1,5,142,1,5,143,5,144,5,1,145,3,3,5,3,3,4,3,1,5,1,146,4,147,148,149,1,1,150,1,5,1,151,6,3,152,1,5,153,2,154,5,5,155,156,1,157,1,158,159,160,5,5,5,1,1,161,162,163,1,164,165,166,167,3,5,2,168,6,5,169,170,2,5,171,172,2,173,1,174,5,1,175,1,1,5,5,4,176,5,5,5,5,1,177,178,5,5,3,1,1,1,4,2,5,5,179,180,5,181,5,1,182,183,4,3,5,1,5,5,184,185,5,186,2,2,1,187,1,188,189,190,5,1,5,9,191,5,5,1,1,3,5,1,192,193,194,1,195,196,5,1,5,6,4,4,197,198,199,200,9,5,201,202,2,203,4,5,4,7,1,1,5,5,5,204,1,205,3,5,206,207,208,209,1,3,5,5,4,4,1,3,210,1,4,5,211,1,212,1,213,5,214,215,216,5,5,1,5,5,8,4,1,217,218,8,1,219,220,1,4,1,5,5,1,221,1,222,3,223,224,3,225,226,4,5,227,5,1,1,1,1,228,5,1,229,230,1,231,1,5,232,1,4,6,233,1,1,234,5,235,236,1,1,1,1,237,1,238,1,1,239,1,240,241,1,242,2,5,1,1,3,243,1,244,245,5,1,1,246,1,5,3,1,1,9,1,5,5,5,5,1,247,1,248,8,1,10,249,5,1,1,1,250,5,5,3,251,7,252,253,9,3,254,255,4,256,257,258,259,5,5,4,1,260,261,4,4,1,4,1,262,1,1,5,5,1,5,263,264,5,265,266,5,5,267,5,5,1,268,1,5,269,270,5,271,272,273,1,5,3,1,5,1,3,274,3,5,275,1,1,4,4,4,5,5,276,4,5,5,277,1,1,5,1,2,1,278,279,6,5,10,3,3,2,2,280,281,282,5,283,4,6,284,285,8,1,286,2,2,287,4,2,5,288,1,289,6,1,5,290,5,291,1,292,1,293,5,1,3,294,5,295,296,297,10,5,5,3,1,1,298,299,300,1,1,6,5,1,1,301,4,6]},"options":{"NodeID":"name","Group":"group","colourScale":"d3.scaleOrdinal(d3.schemeCategory20);","fontSize":7,"fontFamily":"serif","clickTextSize":17.5,"linkDistance":50,"linkWidth":"function(d) { return Math.sqrt(d.value); }","charge":-30,"opacity":0.8,"zoom":true,"legend":false,"arrows":false,"nodesize":false,"radiusCalculation":" Math.sqrt(d.nodesize)+6","bounded":false,"opacityNoHover":0.9,"clickAction":null}},"evals":[],"jsHooks":[]}</script>
```

We can also use a flow-like visualization plot. 


```{=html}
<div id="htmlwidget-d2eaf498c879c2a7a224" style="width:672px;height:5000px;" class="sankeyNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-d2eaf498c879c2a7a224">{"x":{"links":{"source":[24,23,22,3,1,24,12,24,17,12,11,3,21,23,7,4,22,11,1,24,12,6,14,24,24,21,6,22,12,23,0,22,6,24,23,1,12,6,24,1,22,14,24,3,23,20,24,23,3,15,0,10,21,12,22,4,7,13,11,14,2,6,8,12,10,4,22,22,22,2,3,23,0,7,2,11,12,2,0,22,24,3,24,11,12,12,4,24,24,22,11,12,24,24,11,4,22,1,24,7,24,11,1,24,2,6,1,24,5,22,12,4,16,16,22,6,24,4,12,10,24,2,3,22,19,24,6,12,19,7,22,0,14,3,16,7,24,2,12,8,23,22,7,24,6,3,12,23,12,11,12,24,12,17,24,24,11,1,12,24,24,6,12,6,24,4,22,11,11,24,22,4,1,22,11,24,12,1,6,12,17,11,24,11,24,18,24,12,22,24,22,4,17,6,4,2,12,22,19,15,3,8,17,4,7,14,22,4,6,24,7,24,14,12,8,24,1,11,8,0,2,7,14,8,3,2,6,8,24,14,2,11,2,2,8,23,7,14,24,12,4,8,14,2,23,3,14,7,22,24,12,15,11,3,0,24,18,24,7,17,3,24,11,6,12,12,1,4,11,24,11,11,12,24,24,10,11,22,4,24,24,6,8,12,17,22,11,6,4,24,12,12,23,24,16,11,12,3,24,12,1,24,12,24,3,12,11,3,12,24,7,22,3,24,2,3,11,24,22,12,24,24,12,11,22,24,12,3,11,24,16,22,3,12,24,12,24,8,24,23,3,6,11,17,12,22,14,24,22,12,6,12,23,22,12,3,14,8,7,22,24,24,15,3,7,0,6,8,23,10,2,24,3,3,3,8,24,22,6,22,12,24,22,6,3,6,3,4,10,3,24,11,12,24,12,12,24,11,23,11,24,10,22,1,6,3,12,11,2,22,24,11,12,12,24,11,12,24,11,17,18,6,23,16,1,11,24,2,12,6,15,8,23,1,22,11,22,3,4,7,24,12,6,12,4,24,6,3,8,16,2,7,23,24,8,7,2,12,24,4,12,22,6,24,13,6,15,24,12,23,3,7,14,8,16,11,2,1,4,22,3,23,24,11,2,24,2,8,22,24,22,18,6,19,23,3,8,11,1,5,7,2,0,4,15,17,12,10,6,24,22,12,24,24,22,22,8,10,23,0,19,3,24,15,1,22,2,6,22,16,11,6,2,3,24,1,12,1,22,24,0,8,4,2,7,22,24,3,1,16,6,15,12,19,0,18,6,10,3,1,2,22,13,14,2,0,3,8,7,17,22,6,12,3,1,4,2,3,3,6,22,20,12,8,19,0,14,3,2,23,4,6,0,12,24,24,6,10,24,0,2,3,14,13,24,3,2,7,5,8,23,21,13,2,1,3,4,22,6,24,0,17,10,12,7,0,7,24,1,3,12,6,17,14,1,24,0,2,24,1,24,24,11,1,12,18,17,8,7,12,8,7,13,24,17,12,24,6,11,23,22,24,10,24,12,6,24,22,24,3,6,18,22,4,24,6,7,16,3,8,19,24,24,24,24,8,12,15,11,24,11,1,12,24,11,12,11,1,12,24,12,11,4,24,14,24,7,24,24,24,7,3,7,24,1,12,3,24,3,8,12,6,22,2,7,11,24,12,3,1,17,13,14,24,22,24,11,12,3,24,4,24,3,0,6,6,3,8,3,24,23,12,6,0,3,8,6,24,3,12,22,24,4,3,17,1,6,12,24,12,14,1,7,8,3,2,6,16,0,22,10,24,22,22,24,11,22,24,12,4,22,24,3,7,17,24,2,24,24,24,2,22,19,22,24,24,11,24,12,23,10,24,22,15,5,8,11,4,12,19,24,12,22,6,24,15,8,22,14,10,13,7,8,0,16,3,2,22,24,15,19,8,2,17,23,4,10,22,10,24,15,12,22,24,22,22,10,22,8,24,16,10,19,12,3,22,4,11,24,1,12,3,24,22,24,12,22,10,2,22,24,24,22,12,24,11,8,4,23,24,24,23,10,22,2,8,6,11,6,18,6,24,12,10,7,0,4,8,3,22,22,4,24,12,10,24,7,24,6,22,12,24,2,24,12,22,0,6,8,3,22,11,24,12,24,24,12,17,4,1,11,3,17,7,1,12,24,24,12,24,22,23,24,10,12,24,22,6,10,6,12,24,24,22,24,24,12,17,24,12,12,24,11,11,12,3,12,2,22,4,20,22,1,12,24,22,7,2,22,10,8,24,10,24,17,12,4,24,6,1,11,0,22,3,6,22,6,1,22,24,11,12,24,11,1,12,6,11,16,8,20,4,22,12,6,2,12,22,22,12,4,3,22,16,6,24,24,6,11,16,12,24,6,7,24,24,1,23,3,24,1,0,12,16,8,22,22,8,16,24,4,10,19,24,16,11,3,12,1,22,3,24,4,10,12,11,2,24,12,6,4,22,11,3,12,24,16,7,22,10,4,11,12,22,2,3,13,24,23,7,8,22,16,10,14,2,4,2,22,24,24,17,6,12,6,11,8,10,24,22,2,1,8,12,22,13,2,24,6,17,12,15,24,4,6,10,22,2,11,20,3,12,24,22,10,4,24,24,4,6,1,24,4,1,12,17,6,23,6,22,3,2,12,23,4,24,12,22,6,4,17,12,1,6,12,15,19,10,22,6,12,3,21,22,18,0,24,23,1,6,12,7,11,22,24,17,1,6,12,11,10,7,17,4,22,24,9,3,16,6,2,12,22,16,15,24,6,24,11,6,6,24,11,22,11,24,22,7,0,17,12,4,16,1,24,1,12,22,12,11,24,3,12,6,8,12,24,24,22,10,8,8,7,24,24,6,17,1,4,12,12,23,24,6,3,3,3,24,1,3,11,24,7,11,8,14,3,6,0,24,1,6,1,6,6,24,3,24,23,2,6,12,1,7,3,24,14,8,24,11,24,12,24,22,24,4,24,12,3,1,6,15,11,7,10,2,24,22,6,4,24,12,6,7,2,14,3,3,1,3,24,12,3,24,22,8,24,3,7,23,2,12,24,14,24,24,12,11,24,12,24,2,3,10,4,22,23,11,24,6,12,11,3,22,3,24,6,17,16,11,1,4,22,6,7,12,24,18,24,12,22,24,24,24,22,17,3,24,6,12,24,22,13,8,2,6,12,24,22,12,24,23,1,11,22,22,24,12,22,3,17,18,1,6,8,7,22,12,23,6,14,24,17,22,2,6,3,11,24,1,12,14,6,12,23,3,16,11,24,22,11,6,3,24,1,12,22,2,23,14,2,12,1,8,7,24,24,2,0,24,24,8,12,15,23,24,2,24,4,1,6,12,24,12,4,24,11,22,22,24,16,8,24,18,6,12,8,24,3,22,13,8,7,3,14,24,11,8,2,22,16,7,3,21,24,12,23,4,16,14,7,24,3,8,22,4,2,24,10,7,24,3,0,22,12,24,8,13,24,14,19,8,12,6,17,22,11,12,22,17,24,12,11,6,10,6,6,7,22,2,23,24,13,15,14,3,6,8,21,19,24,6,10,16,14,23,0,11,2,4,12,22,3,12,4,6,24,5,23,17,12,12,24,12,3,24,23,7,8,12,6,1,6,13,11,0,12,24,7,3,14,2,23,16,8,1,24,6,24,6,7,24,0,22,23,6,17,24,11,12,24,12,1,24,1,3,24,24,0,8,2,3,7,22,14,22,4,17,12,24,10,23,11,12,6,24,3,3,22,22,24,22,6,24,24,24,22,11,17,17,12,6,24,18,22,2,2,3,14,24,22,6,6,12,22,24,22,6,6,21,12,2,16,24,22,3,11,19,21,22,3,23,14,16,6,11,10,2,24,0,6,3,24,17,23,22,12,24,22,3,2,22,23,24,0,3,24,11,6,12,6,23,2,3,24,6,22,11,22,6,23,11,22,12,10,4,2,24,23,8,3,8,23,6,4,24,22,22,6,24,3,2,22,8,12,22,11,12,24,22,16,0,2,8,6,6,11,12,22,24,24,22,24,11,1,24,18,17,12,12,24,8,13,11,16,6,2,23,19,1,22,20,7,3,17,4,10,22,7,23,8,22,16,24,1,6,2,10,3,12,2,24,24,2,12,1,24,22,6,4,17,23,12,23,24,22,6,1,12,1,12,10,24,2,24,23,20,22,19,10,22,10,7,11,3,24,16,1,12,13,6,8,17,24,24,12,19,22,24,24,12,11,18,6,24,12,24,6,11,22,3,10,11,12,24,24,4,10,12,8,6,24,1,11,1,24,22,2,17,12,12,22,11,1,6,24,24,12,24,6,22,12,4,22,12,15,3,24,22,6,22,2,24,22,11,1,22,11,24,12,12,11,6,24,11,12,17,1,3,12,0,23,6,24,1,6,11,3,24,0,1,24,6,11,24,22,16,8,12,16,12,1,18,24,17,12,22,8,12,24,2,11,0,22,8,0,24,24,11,17,24,11,12,24,24,24,6,14,1,3,24,24,11,12,12,11,18,17,4,6,24,11,12,3,1,7,12,11,17,12,24,11,14,12,23,11,2,24,8,3,14,23,11,22,24,2,8,12,11,1,24,12,1,17,6,3,12,1,24,11,1,8,24,14,2,8,7,24,6,13,24,12,12,11,6,18,17,12,22,24,24,6,1,16,11,12,3,12,12,2,8,7,16,14,22,24,12,3,12,6,4,11,24,18,1,0,2,24,3,15,12,11,23,8,4,17,1,18,6,16,7,0,22,12,12,24,22,4,11,1,12,24,6,1,6,17,12,17,18,1,0,11,15,12,22,24,6,12,11,24,6,1,6,17,1,11,4,12,22,17,23,18,3,6,24,17,6,3,12,24,17,24,7,8,12,24,12,24,4,22,10,17,2,6,16,4,24,11,3,7,1,6,12,22,12,11,17,24,22,19,11,24,8,3,2,2,3,7,24,24,11,11,12,6,3,11,13,3,24,1,6,12,23,1,24,12,22,6,24,21,8,22,11,6,17,1,12,23,6,0,3,24,22,24,19,24,4,22,4,24,12,24,22,12,2,22,12,24,10,19,12,22,2,10,10,22,12,24,22,4,11,8,2,3,4,19,10,22,22,11,17,24,10,12,4,24,24,12,12,6,1,24,11,6,7,24,12,24,1,12,6,2,8,4,7,23,11,10,24,22,12,3,6,3,24,6,12,11,14,24,2,8,7,3,7,12,24,1,23,12,10,21,2,24,8,20,24,24,3,4,22,7,12,2,10,1,22,24,15,12,18,15,17,22,12,24,11,4,16,10,24,1,12,12,22,4,10,24,7,11,22,24,12,3,23,22,11,1,12,10,18,13,7,15,17,22,3,8,24,16,6,2,12,24,8,12,22,21,6,17,12,11,24,22,12,1,14,16,24,3,1,12,6,1,23,11,6,6,16,3,12,24,2,2,15,1,3,4,23,10,16,0,6,11,24,12,17,8,18,22,11,6,24,12,22,14,12,3,2,22,16,8,24,16,22,24,22,3,1,22,6,24,23,4,12,24,10,22,2,24,22,22,4,7,1,6,15,24,12,10,3,12,11,1,24,1,24,1,7,6,13,11,4,12,22,3,24,1,8,14,24,2,3,11,12,24,16,2,1,3,3,24,7,2,8,3,23,6,24,6,24,7,8,14,3,6,8,3,13,12,17,6,24,7,3,0,17,22,12,2,12,3,24,24,24,19,12,3,24,11,0,24,24,8,14,8,12,14,3,22,22,8,6,8,2,24,0,14,1,7,3,6,6,3,1,4,11,16,12,8,24,6,22,2,3,24,11,1,24,6,12,3,1,24,14,12,10,22,24,11,6,12,1,24,11,17,11,12,1,16,17,4,24,11,1,22,4,12,24,11,12,22,4,6,12,1,1,3,2,24,8,22,6,7,12,24,3,2,7,2,3,22,24,6,8,14,23,24,0,1,6,3,1,24,11,8,3,23,6,12,1,2,7,3,17,16,6,0,24,11,23,8,14,12,22,24,11,6,12,11,11,24,3,0,1,12,16,24,17,22,11,2,16,3,4,6,24,14,11,22,0,7,12,19,10,22,2,3,24],"target":[25,26,26,27,27,28,28,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,30,31,32,33,33,33,33,33,33,34,34,35,36,36,36,36,37,38,39,39,40,40,40,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,41,42,42,42,42,43,44,44,45,46,47,47,47,48,48,48,48,48,48,48,49,49,49,50,51,52,53,53,54,54,54,55,55,56,56,57,58,59,59,59,60,60,61,62,62,62,62,62,62,62,62,63,64,64,64,64,64,65,65,65,65,65,65,66,66,66,67,68,68,69,69,69,69,69,69,69,69,69,69,69,70,71,71,71,71,71,72,73,73,73,74,75,76,77,77,78,78,79,80,80,80,81,81,81,81,81,82,82,82,83,83,83,83,83,83,84,84,84,84,84,84,85,85,86,86,86,87,87,88,89,89,90,90,91,91,92,92,92,93,93,94,94,95,95,95,95,95,96,97,97,97,97,97,98,98,99,100,100,101,102,102,102,102,102,103,103,103,103,104,105,106,107,108,109,109,109,109,110,110,111,112,113,113,113,113,113,113,113,113,113,114,115,115,115,116,116,117,117,117,117,117,117,117,118,118,118,118,119,119,120,121,121,122,122,122,122,122,123,124,124,124,124,125,125,125,125,125,125,125,126,127,127,127,127,127,128,129,129,129,130,131,131,131,132,133,133,133,133,134,134,134,135,135,135,136,136,136,137,137,138,139,139,140,140,141,141,141,141,142,142,143,143,143,144,144,145,145,145,145,145,145,145,145,145,145,146,146,146,147,147,147,147,148,148,148,148,148,148,148,149,149,149,149,149,149,149,149,149,149,150,151,152,153,154,154,154,155,155,156,156,156,157,158,159,160,161,161,162,163,163,163,164,164,165,165,166,167,167,167,167,167,167,167,167,167,168,169,169,169,169,170,171,171,171,172,172,172,172,172,172,172,172,172,173,174,174,174,174,174,174,174,174,174,174,175,175,175,175,175,175,175,176,176,176,176,176,176,176,176,176,176,177,177,177,177,178,178,178,179,179,179,180,181,181,181,181,181,181,181,181,181,181,181,181,181,181,181,181,182,183,183,184,185,185,186,186,187,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,189,190,191,191,191,192,192,193,194,194,194,194,194,194,194,194,194,194,194,194,195,195,195,195,195,195,195,195,196,196,196,196,197,198,198,198,198,198,198,198,198,198,198,198,198,198,198,199,199,200,200,200,200,200,200,201,201,201,201,201,201,202,202,202,202,202,202,202,203,203,204,205,205,205,205,205,205,205,205,205,205,206,206,206,206,206,206,207,208,208,208,208,208,208,209,209,209,209,209,209,210,210,210,210,210,210,210,210,210,210,210,210,210,210,210,210,210,211,211,211,211,211,211,211,211,211,212,213,214,214,215,216,216,217,217,217,217,217,217,218,218,218,219,219,219,219,220,221,221,221,222,222,222,222,223,223,223,224,224,225,226,226,227,228,228,228,228,228,229,229,229,229,229,229,230,231,232,232,233,233,234,234,235,235,236,237,237,238,238,239,240,241,241,241,242,243,243,244,244,245,246,247,247,248,248,249,250,250,251,252,253,253,253,253,253,253,253,254,254,254,254,254,254,255,255,256,257,257,257,258,258,258,258,259,260,261,261,262,262,262,263,263,263,263,263,263,264,265,266,266,267,268,268,269,269,269,269,269,269,269,270,270,270,270,270,270,270,270,270,270,270,271,271,272,272,273,273,274,274,274,274,274,275,276,276,276,277,277,278,278,279,280,281,281,281,282,283,284,284,285,285,286,286,286,286,286,286,286,286,286,286,287,288,288,288,288,289,289,289,289,290,290,290,290,290,290,290,290,290,290,290,290,290,291,291,292,292,292,292,292,293,294,294,295,295,296,296,297,298,298,299,300,300,300,300,300,300,300,300,301,301,301,301,302,302,303,303,303,304,304,304,305,306,307,307,307,308,309,309,310,310,310,311,311,311,311,311,311,311,311,312,313,313,313,313,313,313,313,313,313,313,313,314,314,314,314,314,315,315,316,317,317,318,319,320,320,320,320,320,321,321,321,321,321,321,322,322,323,323,323,323,323,324,324,324,324,324,324,324,325,326,326,327,328,329,330,330,330,330,330,331,332,332,332,333,334,334,335,335,336,336,336,337,337,337,338,338,339,339,339,339,340,341,341,342,343,343,343,343,343,344,344,345,345,345,346,347,347,347,347,347,347,347,348,349,349,349,350,351,352,352,353,353,353,354,354,354,354,355,356,356,356,356,356,356,356,356,356,357,358,359,360,360,360,360,360,360,360,361,362,362,363,363,363,364,365,366,367,367,367,368,368,368,368,368,369,369,369,370,370,370,370,370,370,370,371,371,371,371,371,371,372,373,374,374,374,374,374,375,375,375,375,375,375,376,376,376,376,376,376,377,377,377,378,378,379,379,380,380,380,380,380,380,380,380,380,380,380,380,381,382,382,383,384,384,384,385,386,386,386,386,386,386,387,388,388,389,389,389,389,389,389,389,390,391,391,391,391,391,391,391,391,391,391,392,392,392,392,393,394,394,394,395,396,396,397,397,397,398,399,399,399,399,399,400,400,401,401,401,401,402,402,403,403,403,403,404,404,404,404,404,405,405,406,406,406,406,406,406,406,406,406,406,406,406,407,407,407,408,408,408,408,408,408,408,408,408,408,408,408,408,409,410,410,410,410,410,411,412,413,414,414,415,415,415,416,417,417,417,417,417,417,417,417,417,417,418,418,418,419,419,420,421,421,422,422,423,424,424,425,425,425,426,427,427,428,429,429,429,429,429,429,430,430,430,430,430,431,432,433,433,433,433,434,435,435,435,435,435,435,435,435,435,436,437,438,439,439,439,440,440,440,440,440,440,440,440,441,441,441,442,442,443,443,444,445,446,447,447,447,447,447,447,447,447,447,448,449,450,451,452,452,453,453,453,454,454,454,454,455,456,456,457,457,458,459,460,460,461,461,461,461,461,462,463,464,464,465,466,466,466,467,468,468,468,469,469,469,469,469,469,470,471,471,471,472,472,472,472,472,472,472,473,473,473,473,473,473,473,473,474,474,475,475,476,477,477,478,478,478,479,479,479,479,479,480,480,480,480,480,480,481,481,481,481,481,482,483,484,484,484,484,484,484,484,484,485,485,485,485,485,485,485,485,485,486,486,486,487,487,487,487,487,488,488,488,488,488,488,488,488,488,489,489,489,489,489,489,490,490,490,491,491,492,492,492,492,492,493,493,493,494,495,496,496,496,496,496,496,497,498,498,498,498,498,499,499,499,499,499,500,501,502,502,502,503,503,503,504,504,504,504,504,505,505,505,505,505,505,506,506,506,506,506,506,506,506,506,506,506,507,507,507,507,507,507,507,507,507,508,509,510,510,510,510,510,510,511,512,512,513,513,513,513,514,514,514,514,514,515,516,516,516,516,516,516,517,518,519,520,520,520,520,520,520,520,520,520,520,520,520,521,521,521,521,521,521,521,521,521,521,521,521,521,521,522,522,522,522,522,522,523,523,524,525,525,525,526,526,526,526,526,526,526,527,527,527,527,527,527,527,527,527,527,527,527,527,528,528,529,529,530,530,530,531,531,531,531,531,531,531,531,532,533,534,535,535,536,537,538,538,538,538,538,538,538,538,539,539,539,539,539,539,539,539,540,540,540,540,541,541,542,542,543,543,544,545,546,547,548,548,549,549,549,549,549,549,550,551,552,552,553,554,554,555,555,555,555,556,556,557,557,558,558,558,558,558,558,558,558,559,559,559,559,559,559,559,559,559,559,559,559,560,560,560,560,560,560,560,561,561,562,562,562,562,562,563,564,564,564,564,564,565,566,566,567,567,568,569,570,571,572,572,572,572,572,572,572,572,572,573,573,573,574,574,574,574,574,574,575,575,575,576,576,576,576,577,577,578,578,578,579,579,579,579,579,579,580,581,581,582,582,583,583,584,585,585,585,585,585,586,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,587,588,589,589,589,589,589,589,589,589,589,589,589,589,590,591,592,593,593,593,593,593,593,593,593,593,594,594,594,594,594,594,595,595,596,596,596,597,597,597,598,598,598,598,599,599,600,600,600,600,600,600,600,600,600,600,600,601,602,603,603,603,603,604,604,604,604,604,605,606,607,607,607,608,608,608,609,609,609,610,610,610,610,610,611,611,611,612,612,612,612,612,612,612,613,614,614,615,616,616,617,618,619,619,620,621,622,622,623,623,623,623,623,623,624,625,625,625,626,626,627,627,627,627,628,628,628,628,629,629,629,630,631,631,631,631,631,631,631,632,632,632,632,632,632,633,634,635,635,635,635,635,635,636,637,637,637,638,638,638,639,640,640,640,640,640,641,641,641,642,642,643,644,644,644,645,645,645,646,647,647,647,647,647,648,649,650,650,651,651,651,652,652,652,652,652,652,652,652,652,653,653,654,655,655,656,657,657,657,657,657,657,657,657,658,658,658,658,658,658,658,658,659,660,660,661,662,663,663,663,663,663,663,663,664,665,665,666,666,666,666,666,666,666,667,667,668,668,669,669,669,669,669,670,671,671,671,671,671,671,671,672,673,674,674,674,674,674,674,674,674,675,675,675,675,675,675,675,675,675,676,676,676,676,676,676,676,676,676,676,676,676,676,676,676,676,676,677,678,678,678,678,678,679,679,679,679,680,680,680,680,681,681,681,681,681,681,681,681,681,681,682,682,682,682,682,683,683,684,684,684,684,684,684,684,684,684,684,684,685,685,685,685,685,686,686,687,687,687,687,688,688,688,688,688,688,688,688,688,689,689,689,689,689,689,689,689,690,691,691,691,692,693,693,694,694,695,695,695,696,697,697,697,698,698,699,699,700,700,700,700,701,702,702,702,702,703,703,703,704,704,704,705,706,706,707,708,709,709,709,709,710,710,711,712,713,713,714,715,716,717,718,718,718,718,719,719,719,720,720,721,721,722,723,724,724,724,724,725,725,726,726,726,726,726,727,727,727,727,727,727,727,728,728,728,728,728,728,728,729,730,730,731,731,731,731,731,732,732,732,732,733,733,733,733,734,734,734,734,734,734,734,734,734,734,734,734,735,735,735,735,736,737,738,738,738,738,738,739,740,741,741,741,741,741,742,742,742,742,742,743,744,744,744,744,744,744,744,745,745,745,745,745,745,746,746,746,746,746,746,746,746,746,746,747,748,748,749,749,749,749,749,750,751,752,752,752,753,754,755,756,756,756,756,756,756,756,756,756,756,756,756,756,756,756,757,757,757,757,758,758,758,758,759,759,759,759,759,760,760,760,760,760,761,761,761,762,762,763,764,764,765,765,765,765,765,766,767,767,767,767,767,767,767,767,767,767,767,767,767,767,767,767,767,768,768,768,768,769,769,769,769,769,770,770,770,770,771,771,772,772,772,772,773,773,773,773,773,773,774,775,775,775,776,776,777,777,777,777,777,777,777,777,777,778,779,779,779,780,780,781,781,781,782,782,782,782,782,782,782,782,782,783,783,783,783,784,784,784,784,785,786,787,787,788,788,788,789,789,789,789,790,790,791,791,792,792,792,792,792,793,793,793,794,795,796,797,797,797,797,798,799,799,799,800,800,801,802,803,803,804,804,804,804,804,805,806,806,806,807,807,807,807,808,809,809,810,810,811,811,811,811,811,811,811,811,812,813,813,813,813,813,813,813,813,813,813,814,815,815,816,816,816,816,817,817,817,817,818,819,819,819,819,820,821,821,821,821,821,822,823,823,823,823,823,823,823,824,825,825,825,825,825,826,826,826,826,827,827,827,828,829,829,829,829,829,829,829,830,831,832,833,833,834,834,834,834,834,834,834,834,835,835,835,836,836,837,837,837,837,837,837,837,837,838,838,838,838,838,838,838,838,838,838,838,838,838,838,839,840,841,842,842,842,843,843,844,844,845,845,845,845,845,846,846,846,846,847,847,847,847,847,847,847,847,847,847,848,849,849,849,850,850],"value":[3,5,2,2,1,5,5,1,1,1,2,3,2,1,1,1,10,1,2,14,1,1,1,1,8,1,11,2,1,2,4,1,4,1,1,1,2,4,1,2,1,1,3,1,1,1,12,5,7,1,8,6,2,4,21,1,3,1,1,6,27,31,9,1,1,2,9,1,4,3,2,1,1,1,3,1,1,6,1,11,1,3,10,3,19,2,1,2,1,3,10,1,2,1,1,1,5,1,1,8,1,2,1,2,1,2,1,13,1,34,6,7,1,1,8,1,2,4,1,4,2,1,2,14,2,3,1,2,1,1,1,4,3,1,2,8,5,1,2,3,1,18,1,1,2,1,16,1,1,4,2,2,1,1,1,1,3,1,1,2,1,1,2,1,3,1,1,6,14,4,3,1,2,2,4,4,1,1,1,2,1,1,4,1,2,1,2,1,2,1,3,1,1,2,3,2,1,5,1,1,1,1,1,1,9,1,1,1,1,1,11,3,1,2,3,1,1,1,1,1,1,1,2,1,2,6,1,1,2,1,1,3,1,1,3,1,1,1,2,1,3,1,2,3,1,1,1,1,1,2,1,1,2,8,1,4,2,3,1,1,1,10,6,1,10,1,2,1,2,2,3,1,1,3,4,1,3,5,1,1,2,2,1,5,2,1,3,1,4,3,2,3,4,3,1,1,2,1,3,3,2,1,2,2,1,1,2,1,1,8,1,13,1,1,2,2,1,6,22,3,1,1,1,1,1,1,2,2,2,2,1,1,1,15,2,4,2,1,7,1,3,3,7,1,14,4,1,3,1,2,2,1,1,3,1,1,3,2,7,1,7,4,1,9,1,1,3,1,1,6,4,2,1,4,5,1,2,2,1,1,1,2,1,1,2,3,3,1,3,4,4,2,2,1,1,1,1,1,4,4,9,3,1,1,2,2,20,3,1,3,1,3,1,3,4,18,45,23,54,2,4,3,1,1,18,1,34,2,14,2,4,1,1,1,46,10,3,1,3,1,6,2,1,1,1,7,1,2,3,2,2,3,3,4,2,3,1,1,6,1,3,1,3,14,1,5,1,18,1,6,3,2,2,10,1,1,5,1,2,37,1,1,1,1,2,1,7,1,1,104,89,4,47,1,15,4,2,4,10,1,2,16,1,37,3,8,88,7,1,1,1,1,4,1,2,1,22,1,1,1,1,1,19,1,1,9,2,1,1,3,1,1,1,4,20,1,2,1,1,2,1,6,7,4,4,12,20,3,1,2,2,1,22,1,2,1,1,1,8,1,2,1,1,1,2,2,4,2,1,3,3,3,2,1,12,10,1,4,2,5,2,1,1,1,1,3,7,66,10,2,10,18,1,1,7,2,1,1,1,1,7,2,1,1,1,8,2,4,1,13,9,2,2,11,15,75,6,11,28,80,5,1,3,7,5,1,10,8,1,2,5,1,1,1,1,1,1,7,1,1,1,2,1,1,13,1,1,1,3,1,1,3,4,1,1,6,4,9,1,1,1,1,1,2,5,1,1,1,1,2,1,1,7,1,5,1,1,2,1,2,1,1,1,2,1,3,1,1,1,11,1,2,3,1,1,3,1,1,1,1,1,7,1,3,1,1,2,1,1,2,1,1,1,3,1,1,1,1,2,1,2,6,5,7,3,3,4,11,1,2,3,1,1,1,5,3,3,2,5,11,1,1,1,1,5,1,1,1,1,1,1,2,20,1,3,1,3,1,2,1,1,7,1,5,4,5,13,6,9,3,1,3,2,3,20,2,10,1,1,1,1,1,4,3,2,1,1,2,1,1,1,3,1,1,1,1,1,1,1,2,1,6,4,1,2,5,1,3,1,4,3,60,131,12,1,2,2,7,2,1,3,2,30,1,3,2,1,24,3,6,8,20,129,1,4,3,8,132,101,6,1,1,1,1,1,1,2,3,1,1,1,1,1,2,1,4,1,2,1,2,1,1,2,1,1,2,1,5,10,2,4,1,4,1,4,1,12,1,1,1,1,11,15,1,1,1,14,1,1,1,17,1,1,15,1,6,1,7,1,1,1,14,4,4,2,2,8,1,1,16,7,3,1,1,1,1,1,1,2,1,1,2,2,4,3,1,1,2,1,1,12,1,1,1,2,7,5,2,1,7,1,5,2,2,1,2,109,6,1,4,1,3,1,1,1,1,3,1,1,1,4,5,1,1,1,3,2,1,1,2,3,4,1,4,7,1,4,1,5,1,6,8,1,1,4,3,3,1,2,3,1,3,2,1,4,11,2,6,10,15,17,1,2,3,1,4,1,1,1,3,1,2,2,2,1,2,1,1,2,1,11,1,26,3,5,7,1,2,1,5,2,3,4,1,1,14,3,1,1,1,4,13,1,1,4,1,1,1,2,2,3,1,1,1,1,7,9,4,4,4,2,1,1,14,3,1,11,21,8,2,1,1,1,1,2,2,1,1,1,2,1,3,1,2,1,4,2,3,5,3,1,1,1,3,2,25,5,12,1,48,41,2,1,1,2,3,1,2,4,10,1,1,3,8,1,1,1,8,1,6,11,1,2,3,8,1,1,15,3,2,6,1,3,2,2,4,12,1,1,3,1,2,1,6,1,2,1,2,1,6,2,1,4,4,1,1,1,1,1,2,1,1,1,1,2,1,2,2,1,1,1,18,2,12,1,1,1,1,7,1,1,4,2,31,1,1,37,1,3,4,19,1,3,7,2,1,8,2,33,3,3,1,2,7,1,55,1,12,3,1,4,1,1,2,1,1,1,1,2,1,1,2,1,1,2,43,1,4,1,4,8,4,1,8,3,2,4,1,3,1,1,3,5,2,1,3,1,3,11,4,1,1,1,1,5,3,2,2,1,7,3,2,3,1,1,1,2,1,4,1,1,1,6,1,1,3,32,7,3,34,6,2,2,6,4,2,4,16,20,3,3,3,10,2,5,2,1,2,1,5,1,1,1,3,1,11,16,5,2,2,1,1,1,3,1,1,1,1,1,2,1,1,3,1,1,2,1,1,2,4,3,2,1,1,1,1,1,1,1,1,7,1,1,1,3,1,1,1,1,1,1,1,1,3,6,3,1,2,1,3,11,1,1,26,2,45,1,1,3,2,1,2,2,3,1,1,16,1,3,1,5,2,6,6,6,1,2,5,2,1,11,7,1,1,1,1,1,7,3,5,10,2,1,2,1,2,11,12,5,1,1,1,1,2,1,1,15,1,1,1,1,10,1,3,1,1,2,4,16,11,7,3,1,5,2,2,1,3,10,6,9,4,2,14,4,29,2,1,1,1,1,1,1,1,1,7,28,1,1,1,1,1,1,1,1,5,1,1,1,5,1,2,5,2,1,1,3,1,1,1,6,1,1,1,2,1,6,1,4,1,1,1,1,3,2,1,2,6,2,5,1,13,1,2,17,2,1,3,3,1,2,3,1,40,20,1,6,1,1,9,73,1,1,1,5,1,1,1,2,1,1,1,3,7,1,1,1,1,1,2,1,6,2,1,1,1,4,1,2,1,2,1,1,1,2,1,3,2,3,1,21,2,7,2,1,2,3,12,8,2,5,15,9,4,2,3,11,1,13,1,1,2,1,1,2,4,1,1,2,1,1,1,2,2,2,1,1,14,3,3,2,3,1,1,9,1,1,5,1,4,1,4,1,6,1,10,1,6,1,1,1,1,1,2,1,1,1,1,1,12,5,9,7,4,3,7,1,1,1,2,1,2,2,5,3,13,2,2,2,9,1,3,1,1,1,1,3,1,7,3,2,1,3,1,2,1,1,1,1,2,3,1,8,6,4,4,2,1,1,1,1,1,1,1,4,1,1,1,1,2,8,1,5,1,8,2,1,12,1,4,6,1,11,1,2,5,2,2,1,1,1,1,1,2,1,1,1,1,5,8,1,3,1,2,7,2,2,1,1,6,1,6,13,8,2,2,4,1,6,2,1,2,2,2,1,4,4,1,3,2,4,2,3,1,1,2,1,1,2,3,2,1,2,1,4,1,1,1,5,1,3,1,1,2,3,1,1,1,4,20,43,9,1,5,2,13,55,38,1,1,61,1,5,2,1,9,3,1,2,10,3,3,1,23,9,4,21,1,1,13,1,2,1,3,3,4,9,5,9,2,5,2,13,3,6,3,9,4,1,1,2,1,5,2,5,1,1,4,4,1,2,1,23,1,2,64,1,1,14,2,8,8,1,1,1,1,2,4,1,4,6,6,2,1,1,1,2,3,2,1,1,1,1,1,6,1,1,1,2,1,4,3,1,9,2,17,5,1,1,8,1,1,1,1,1,1,1,1,2,1,2,1,1,2,4,1,1,10,21,1,3,1,1,6,1,1,1,5,1,6,5,9,1,1,2,1,1,1,36,10,7,1,20,24,6,4,1,14,5,5,1,1,1,28,6,6,1,1,8,1,1,1,2,2,1,1,1,1,1,4,2,1,1,1,1,3,1,1,2,1,1,1,2,3,1,5,1,1,1,2,1,1,1,1,14,1,1,9,3,3,3,5,12,1,3,1,2,3,1,1,1,2,1,4,5,3,7,5,1,1,1,2,16,11,12,11,6,5,1,4,1,1,1,1,4,1,2,2,1,2,1,1,1,4,2,2,1,2,4,1,1,1,2,1,1,1,1,6,1,1,6,1,2,1,2,9,1,1,1,8,4,2,4,1,1,2,10,1,26,1,1,5,8,2,5,1,4,66,6,1,80,14,2,1,1,12,41,3,9,3,8,1,1,2,12,5,2,1,5,3,5,3,1,1,1,3,6,9,4,6,1,3,2,53,1,9,10,11,11,22,15,8,2,7,27,15,3,69,2,17,1,2,2,9,20,3,1,1,7,2,1,5,2,1,1,2,2,9,2,33,7,1,3,3,1,2,4,1,4,1,1,20,2,1,4,2,1,1,1,1,3,5,1,1,4,1,3,1,3,1,1,2,3,3,1,1,2,2,2,3,1,5,6,2,9,1,1,1,1,3,1,2,1,1,20,1,3,1,1,1,2,2,3,2,1,1,3,3,1,3,1,1,1,1,1,3,2,1,1,1,1,6,1,1,2,3,1,2,1,2,4,2,6,1,3,5,5,19,8,1,1,1,4,3,8,1,1,1,9,5,1,10,3,1,1,3,2,3,2,3,1,12,1,1,1,2,2,7,11,22,3,1,4,1,1,1,6,1,1,1,3,2,1,3,1,1,2,1,2,3,1,1,2,3,1,1,1,24,4,1,5,2,7,1,1,1,14,14,1,4,1,1,4,22,5,14,2,4,1,7,5,2,1,3,11,5,1,5,1,1,3,1,1,2,1,3,1,4,19,3,2,1,3,4,5,91,3,3,61,1,11,1,3,4,1,3,2,1,1,2,9,2,8,15,1,1,1,1,1,2,1,2,7,1,1,4,10,4,1,1,3,4,1,6,1,19,2,4,5,1,3,2,23,9,17,101,1,1,1,7,1,1,7,10,6,1,1,1,1,2,3,1,1,1,2,7,2,1,1,56,1,19,1,2,1,1,1,5,1,2,1,18,1,3,2,1,1,19,3,1,2,2,4,5,2,1,9,1,1,1,1,2,1,7,1,2,15,1,3,2,1,1,1,1,1,4,2,3,1,1,5,17,2,3,1,2,1,1,1,4,4,4,1,7,2,4,2,4,1,2,3,1,5,3,2,1,5,1,1,3,1,1,2,5,1,1,1,2,1,2,1,1,1,1,1,1,1,2,1,1,3,1,1,1,1,94,19,1,2,4,92,3,2,16,16,5,4,1,32,1,26,10,6,1,5,1,1,2,2,4,1,6,1,3,1,5,1,5,1,1,16,2,2,3,16,1,17,18,6,1,5,1,7,1,1,3,2,14,1,1,2,1,2,6,7,3,1,1,2,2,1,3,1,3,1,1,1,1,1,1,4,1,1,2,1,2,3,5,3,2,3,1,1,2,1,2,14,1,8,14,16,4,5,41,1,4,57,10,55,1,30,2,13,45,2,1,2,1,1,1,2,1,1,1,1,2,1,1,1,3,1,1,1,6,3,1,4,1,6,2,3,3,1,1,1,2,1,2,3]},"nodes":{"name":["Bombus appositus","Bombus caliginosus","Bombus centralis","Bombus fervidus","Bombus flavidus","Bombus flavidus ","Bombus flavifrons","Bombus griseocollis","Bombus huntii","Bombus impatiens","Bombus insularis","Bombus melanopygus","Bombus mixtus","Bombus morrisoni","Bombus nevadensis","Bombus occidentalis","Bombus rufocinctus","Bombus sitkensis","Bombus sitkensis ","Bombus sylvicola","Bombus sylvicola ","Bombus vagans","Bombus vancouverensis","Bombus vandykei","Bombus vosnesenskii","Abelia Ã— grandiflora","Abies grandis Ã— concolor","Abronia latifolia","Acer circinatum","Acer macrophyllum","Achillea millefolium","Acmispon americanus","Acmispon decumbens","Aconitum columbianum","Aconitum columbianum howellii","Actaea elata alpestris","Adelinia grandis","Aegopodium podagraria","Aesculus hippocastanum","Agastache \nurticifolia","Agastache foeniculum","Agastache urticifolia","Ageratina occidentalis","Agoseris aurantiaca","Agoseris glauca","Ajuga reptans","Alcea biennis","Alcea rosea","Allium acuminatum","Allium amplectens","Allium cernuum","Allium crenulatum","Allium nevii","Allium platycaule","Allium schoenoprasum","Allium triquetrum","Allium validum","Allotropa virgata","Amelanchier alnifolia","Amorpha fruticosa","Amsinckia menziesii","Amsinckia tessellata","Anaphalis margaritacea","Anchusa officinalis","Angelica arguta","Angelica capitellata","Angelica lucida","Antennaria media","Apocynum Ã— floribundum","Apocynum androsaemifolium","Apocynum cannabinum","Aquilegia formosa","Aquilegia vulgaris","Arbutus menziesii","Arctium minus","Arctostaphylos Ã— media","Arctostaphylos bakeri","Arctostaphylos canescens","Arctostaphylos columbiana","Arctostaphylos densiflora","Arctostaphylos manzanita","Arctostaphylos nevadensis","Arctostaphylos patula","Arctostaphylos uva-ursi","Arctostaphylos viscida","Argentina anserina","Argentina pacifica","Arnica chamissonis","Arnica cordifolia","Arnica lanceolata","Arnica latifolia","Arnica longifolia","Arnica mollis","Artemisia tridentata","Aruncus dioicus","Asclepias fascicularis","Asclepias incarnata","Asclepias speciosa","Asparagus officinalis","Astragalus accidens","Astragalus curvicarpus","Astragalus cusickii","Astragalus filipes","Astragalus hoodianus","Astragalus iodanthus","Astragalus lentiginosus","Astragalus racemosus","Astragalus sheldonii","Astragalus whitneyi","Balsamorhiza careyana","Balsamorhiza deltoidea","Balsamorhiza hookeri","Balsamorhiza incana","Balsamorhiza sagittata","Barbarea orthoceras","Bellardia viscosa","Bellis perennis","Berberis aquifolium","Berberis darwinii","Berberis piperiana","Berberis repens","Bidens cernua","Bistorta bistortoides","Blepharipappus scaber","Borago officinalis","Boykinia major","Brassica oleracea","Brassica rapa","Brodiaea elegans","Buddleja davidii","Cakile edentula","Cakile maritima","Calendula officinalis","Calluna vulgaris","Calochortus eurycarpus","Calochortus macrocarpus","Calochortus subalpinus","Calochortus tolmiei","Caltha leptosepala","Calyptridium monospermum","Calyptridium umbellatum","Calystegia soldanella","Camassia cusickii","Camassia leichtlinii","Camassia leichtlinii suksdorfii","Camassia quamash","Campanula scouleri","Canadanthus modestus","Caragana arborescens","Carduus nutans","Carduus pycnocephalus","Castilleja ambigua","Castilleja applegatei","Castilleja applegatei pinetorum","Castilleja campestris","Castilleja collegiorum","Castilleja exserta","Castilleja hispida","Castilleja hispida hispida","Castilleja miniata","Castilleja pilosa","Castilleja septentrionalis","Castilleja tenuis","Ceanothus cordulatus","Ceanothus cuneatus","Ceanothus gloriosus","Ceanothus impressus","Ceanothus integerrimus","Ceanothus papillosus","Ceanothus prostratus","Ceanothus prostratus prostratus","Ceanothus pumilus","Ceanothus thyrsiflorus","Ceanothus thyrsiflorus thyrsiflorus","Ceanothus velutinus","Centaurea Ã— moncktonii","Centaurea cyanus","Centaurea diffusa","Centaurea jacea","Centaurea montana","Centaurea solstitialis","Centaurea stoebe","Centaurium erythraea","Centromadia fitchii","Cercis occidentalis","Chaenactis douglasii","Chaenactis douglasii douglasii","Chamaebatiaria millefolium","Chamaenerion angustifolium","Chimaphila umbellata","Chondrilla juncea","Chrysolepis chrysophylla","Chrysolepis sempervirens","Chrysopsis mariana","Chrysothamnus viscidiflorus","Cichorium intybus","Cicuta douglasii","Cirsium andersonii","Cirsium arvense","Cirsium brevistylum","Cirsium cymosum","Cirsium cymosum canovirens","Cirsium edule","Cirsium inamoenum","Cirsium inamoenum inamoenum","Cirsium peckii","Cirsium remotifolium","Cirsium remotifolium odontolepis","Cirsium scariosum","Cirsium undulatum","Cirsium vulgare","Clarkia amoena","Clarkia amoena caurina","Clarkia amoena lindleyi","Clarkia pulchella","Clarkia purpurea","Clarkia rhomboidea","Claytonia sibirica","Cleomella lutea","Cleomella serrulata","Clinopodium vulgare","Collinsia grandiflora","Collinsia linearis","Collinsia parviflora","Collinsia sparsiflora","Collinsia torreyi","Collomia grandiflora","Collomia mazama","Columbiadoria hallii","Convolvulus arvensis","Cordylanthus tenuis","Coreopsis verticillata","Cornus sericea","Cornus unalaschkensis","Cosmos bipinnatus","Cotinus coggygria","Cotoneaster coriaceus","Cotoneaster franchetii","Cotoneaster horizontalis","Crassula tetragona","Crataegus douglasii","Crataegus monogyna","Crepis acuminata","Crepis setosa","Croton setiger","Cryptantha intermedia","Cucumis sativus","Cucurbita maxima","Cucurbita moschata","Cucurbita pepo","Cuscuta pacifica","Cynara cardunculus","Cynara cardunculus flavescens","Cynoglossum officinale","Cytisus scoparius","Dalea ornata","Damasonium californicum","Dasiphora fruticosa","Daucus carota","Delosperma cooperi","Delphinium leucophaeum","Delphinium menziesii","Delphinium nuttallianum","Delphinium nuttallii","Delphinium trolliifolium","Descurainia sophia","Dicentra formosa","Dicentra formosa formosa","Dieteria canescens","Digitalis purpurea","Dipsacus fullonum","Doellingeria breweri","Doellingeria ledophylla","Doellingeria ledophylla ledophylla","Drymocallis glandulosa","Drymocallis pseudorupestris","Echinacea purpurea","Elaeagnus umbellata","Epilobium brachycarpum","Epilobium ciliatum","Epilobium densiflorum","Eremogone congesta","Eremogone kingii","Erica Ã— darleyensis","Erica carnea","Erica cinerea","Ericameria bloomeri","Ericameria discoidea","Ericameria greenei","Ericameria linearifolia","Ericameria nauseosa","Ericameria nauseosa glabrata","Erigeron aliceae","Erigeron bloomeri","Erigeron divergens","Erigeron foliosus","Erigeron glacialis","Erigeron inornatus","Erigeron peregrinus","Erigeron pumilus","Erigeron speciosus","Eriodictyon californicum","Eriogonum compositum","Eriogonum elatum","Eriogonum heracleoides","Eriogonum inflatum","Eriogonum niveum","Eriogonum nudum","Eriogonum ovalifolium","Eriogonum sphaerocephalum","Eriogonum strictum","Eriogonum umbellatum","Eriophyllum confertiflorum","Eriophyllum lanatum","Eriophyllum lanatum integrifolium","Erodium cicutarium","Eryngium planum","Erysimum cheiranthoides","Erythranthe decora","Erythranthe grandis","Erythranthe guttata","Erythranthe lewisii","Erythranthe microphylla","Escallonia rubra","Eschscholzia californica","Eucryphia cordifolia","Euonymus occidentalis","Euphorbia esula","Euphorbia lathyris","Eurybia integrifolia","Eurybia radulina","Euthamia occidentalis","Fagopyrum esculentum","Ficaria verna","Fragaria cascadensis","Fragaria chiloensis","Fragaria vesca","Frangula californica","Frangula purshiana","Frasera albicaulis","Frasera albicaulis nitida","Frasera speciosa","Fuchsia magellanica","Gaillardia aristata","Gaillardia pinnatifida","Gaillardia pulchella","Galanthus nivalis","Gaultheria shallon","Gentiana affinis","Gentiana andrewsii","Gentiana calycosa","Gentiana newberryi","Gentiana sceptrum","Geranium lucidum","Geranium oreganum","Geranium robertianum","Geranium viscosissimum","Geum coccineum","Geum macrophyllum","Geum triflorum","Gilia capitata","Gilia capitata capitata","Glandora prostrata","Glebionis segetum","Glechoma hederacea","Glycyrrhiza lepidota","Gratiola ebracteata","Grindelia hirsutula","Grindelia integrifolia","Grindelia nana","Grindelia squarrosa","Grindelia stricta","Gutierrezia sarothrae","Gypsophila vaccaria","Hackelia californica","Hackelia micrantha","Helenium autumnale","Helenium bigelovii","Helenium bolanderi","Helianthella uniflora","Helianthus annuus","Helianthus cusickii","Helianthus exilis","Heliopsis helianthoides","Heracleum maximum","Heracleum sphondylium","Heuchera cylindrica","Heuchera micrantha","Hirschfeldia incana","Holodiscus discolor","Holodiscus discolor microphyllus","Horkelia fusca","Horkelia hendersonii","Horkelia howellii","Hosackia crassifolia","Hosackia gracilis","Hosackia oblongifolia","Hosackia rosea","Hyacinthoides hispanica","Hydrophyllum capitatum","Hydrophyllum capitatum thompsonii","Hydrophyllum fendleri","Hydrophyllum occidentale","Hydrophyllum tenuipes","Hymenoxys hoopesii","Hypericum calycinum","Hypericum perforatum","Hypericum scouleri","Hypochaeris radicata","Hyssopus officinalis","Iliamna rivularis","Ipomopsis aggregata","Iris douglasiana","Iris innominata","Iris missouriensis","Iris tenax","Ivesia gordonii","Jacobaea vulgaris","Jaumea carnosa","Kalmia microphylla","Kalmia polifolia","Kickxia elatine","Kniphofia uvaria","Kolkwitzia amabilis","Kopsiopsis strobilacea","Kyhosia bolanderi","Lactuca serriola","Ladeania lanceolata","Lagerstroemia subcostata","Lamium purpureum","Lapsana communis","Lasthenia californica","Lathyrus hirsutus","Lathyrus japonicus","Lathyrus lanszwertii","Lathyrus latifolius","Lathyrus nevadensis","Lathyrus palustris","Lathyrus polyphyllus","Lathyrus sylvestris","Lavandula angustifolia","Lavandula dentata","Lavandula pedunculata","Lavandula stoechas","Leontodon saxatilis","Lepidium appelianum","Leucanthemum maximum","Leucanthemum vulgare","Leucophysalis nana","Lewisia columbiana wallowensis","Leycesteria formosa","Ligusticum grayi","Lilium columbianum","Limnanthes douglasii","Linaria dalmatica","Linaria dalmatica dalmatica","Linaria maroccana","Linaria purpurea","Linaria vulgaris","Linnaea borealis","Linum lewisii","Lithospermum ruderale","Lobelia erinus","Lomatium californicum","Lomatium columbianum","Lomatium dissectum","Lomatium hallii","Lomatium triternatum","Lonicera caerulea","Lonicera conjugialis","Lonicera hispidula","Lonicera involucrata","Lotus corniculatus","Lotus pedunculatus","Lotus pedunculatus pedunculatus","Luetkea pectinata","Lupinus albicaulis","Lupinus albifrons","Lupinus arboreus","Lupinus arbustus","Lupinus argenteus","Lupinus bicolor","Lupinus breweri","Lupinus burkei","Lupinus latifolius","Lupinus lepidus","Lupinus leucophyllus","Lupinus littoralis","Lupinus polyphyllus","Lupinus rivularis","Lupinus sericeus","Lupinus sulphureus","Lythrum salicaria","Madia elegans","Madia gracilis","Madia sativa","Mahonia aquifolium","Maianthemum stellatum","Malus domestica","Malus fusca","Malus sylvestris","Malva arborea","Malva neglecta","Marah oregana","Marrubium vulgare","Medicago sativa","Melilotus albus","Melilotus officinalis","Mentha Ã— piperita","Mentha canadensis","Mentha pulegium","Mentha spicata","Mentzelia albicaulis","Mentzelia laevicaulis","Mertensia ciliata","Mertensia longiflora","Mertensia paniculata","Microseris nutans","Monarda citriodora","Monarda didyma","Monarda fistulosa","Monardella odoratissima","Monardella villosa","Muscari armeniacum","Myosotis discolor","Nemophila menziesii","Nepeta Ã— faassenii","Nepeta cataria","Nepeta faassenii","Nepeta grandiflora","Nepeta racemosa","Nothochelone nemorosa","Oemleria cerasiformis","Oenanthe sarmentosa","Oenothera biennis","Oenothera lindheimeri","Oenothera pallida","Olsynium douglasii","Onopordum acanthium","Oreostemma alpigenum","Origanum vulgare","Orthocarpus bracteosus","Orthocarpus cuspidatus","Orthocarpus imbricatus","Packera hesperia","Packera macounii","Papaver somniferum","Pedicularis attollens","Pedicularis groenlandica","Pedicularis racemosa","Pediomelum tenuiflorum","Pelargonium amaryllidis","Penstemon acuminatus","Penstemon anguineus","Penstemon attenuatus","Penstemon cardwellii","Penstemon cinicola","Penstemon confertus","Penstemon davidsonii","Penstemon deustus","Penstemon euglaucus","Penstemon fruticosus","Penstemon glaucinus","Penstemon globosus","Penstemon hesperius","Penstemon heterophyllus","Penstemon humilis","Penstemon laetus","Penstemon ovatus","Penstemon parvulus","Penstemon peckii","Penstemon pinifolius","Penstemon procerus","Penstemon richardsonii","Penstemon rydbergii","Penstemon serrulatus","Penstemon speciosus","Penstemon spectabilis","Penstemon subserratus","Penstemon venustus","Penstemon wilcoxii","Pentaglottis sempervirens","Perideridia gairdneri","Perideridia oregana","Petasites frigidus palmatus","Phacelia argentea","Phacelia corymbosa","Phacelia hastata","Phacelia hastata alpina","Phacelia heterophylla","Phacelia heterophylla virgata","Phacelia imbricata","Phacelia linearis","Phacelia mutabilis","Phacelia nemoralis","Phacelia nemoralis oregonensis","Phacelia procera","Phacelia ramosissima","Phacelia sericea","Phacelia sericea ciliosa","Phacelia tanacetifolia","Philadelphus coronarius","Philadelphus lewisii","Phyllodoce empetriformis","Physocarpus capitatus","Picea pungens","Picea sitchensis","Pieris japonica","Pilosella caespitosa","Plagiobothrys figuratus","Plagiobothrys nothofulvus","Plantago lanceolata","Plectritis congesta","Plectritis congesta congesta","Polemonium californicum","Polemonium carneum","Polemonium occidentale","Polygonum douglasii","Polygonum paronychia","Polygonum phytolaccifolium","Populus tremuloides","Potentilla breweri","Potentilla flabellifolia","Potentilla gracilis","Potentilla norvegica","Potentilla recta","Primula hendersonii","Primula jeffreyi","Primula jeffreyi jeffreyi","Primula pauciflora","Prosartes smithii","Prunella vulgaris","Prunella vulgaris lanceolata","Prunus avium","Prunus domestica","Prunus emarginata","Prunus laurocerasus","Prunus persica","Prunus serrulata","Prunus subcordata rubicunda","Prunus virginiana","Purshia tridentata","Pyrrocoma carthamoides","Pyrrocoma hirta","Ranunculus occidentalis","Ranunculus repens","Raphanus raphanistrum","Raphanus raphanistrum sativus","Raphanus sativus","Reynoutria japonica","Rhododendron catawbiense","Rhododendron columbianum","Rhododendron macrophyllum","Rhododendron maximum","Rhododendron menziesii","Rhododendron occidentale","Rhododendron ponticum","Ribes aureum","Ribes cereum","Ribes inerme","Ribes nigrum","Ribes oxyacanthoides","Ribes rubrum","Ribes sanguineum","Ribes uva-crispa","Ribes velutinum","Robinia pseudoacacia","Rorippa indica","Rosa canina","Rosa gymnocarpa","Rosa multiflora","Rosa nutkana","Rosa rubiginosa","Rosa rugosa","Rosa woodsii","Rubus armeniacus","Rubus bifrons","Rubus fruticosus","Rubus idaeus","Rubus idaeus strigosus","Rubus laciniatus","Rubus parviflorus","Rubus rolfei","Rubus spectabilis","Rubus ursinus","Rubus vestitus","Rudbeckia glaucescens","Rudbeckia hirta","Rudbeckia occidentalis","Rupertia physodes","Salix boothii","Salix hookeriana","Salix lucida","Salix planifolia","Salix sitchensis","Salvia dorrii","Salvia dorrii dorrii","Salvia greggii","Salvia leucantha","Salvia nemorosa","Salvia officinalis","Salvia pratensis","Salvia rosmarinus","Salvia yangii","Sanguisorba officinalis","Santolina chamaecyparissus","Satureja montana","Saussurea americana","Scorzoneroides autumnalis","Scrophularia californica","Scrophularia lanceolata","Scutellaria angustifolia","Scutellaria integrifolia","Securigera varia","Sedum album","Sedum lanceolatum","Sedum obtusatum","Sedum oreganum","Sedum oregonense","Sedum spathulifolium","Sedum stenopetalum","Sedum stenopetalum ciliosum","Senecio crassulus","Senecio fremontii","Senecio hydrophiloides","Senecio hydrophilus","Senecio integerrimus","Senecio serra","Senecio triangularis","Senecio vulgaris","Sericocarpus oregonensis","Sidalcea campestris","Sidalcea malviflora","Sidalcea nelsoniana","Sidalcea oregana","Sidalcea virgata","Silphium perfoliatum","Sinapis alba","Sisymbrium altissimum","Sisymbrium irio","Sisyrinchium bellum","Smithiastrum prenanthoides","Solanum dulcamara","Solanum lycopersicum","Solidago canadensis","Solidago elongata","Solidago lepida","Solidago spathulata","Solidago spathulata spathulata","Solidago velutina","Solidago virgaurea","Sorbus aucuparia","Sorbus sitchensis","Spergularia macrotheca","Sphaeralcea munroana","Spiraea betulifolia","Spiraea douglasii","Spiraea japonica","Spiraea lucida","Spiraea splendens","Stachys byzantina","Stachys chamissonis","Stachys mexicana","Stachys rigida","Styrax americanus","Styrax japonicus","Swainsona formosa","Symphoricarpos albus","Symphoricarpos mollis","Symphoricarpos rotundifolius","Symphyotrichum bracteolatum","Symphyotrichum campestre","Symphyotrichum chilense","Symphyotrichum foliaceum","Symphyotrichum novae-angliae","Symphyotrichum patens","Symphyotrichum spathulatum","Symphyotrichum subspicatum","Symphytum Ã— uplandicum","Syringa vulgaris","Tagetes erecta","Tanacetum vulgare","Taraxacum officinale","Taraxia tanacetifolia","Tellima grandiflora","Tephroseris helenitis","Tetradymia canescens","Teucrium Ã— lucidrys","Teucrium chamaedrys","Thelypodium laciniatum","Thermopsis californica","Thermopsis gracilis","Thermopsis montana","Thermopsis rhombifolia","Thymus vulgaris","Tiarella trifoliata","Tiarella trifoliata unifoliata","Tithonia rotundifolia","Tolmiea menziesii","Tonella floribunda","Toxicoscordion venenosum","Triantha occidentalis","Trichostema lanceolatum","Trifolium arvense","Trifolium eriocephalum","Trifolium hirtum","Trifolium hybridum","Trifolium incarnatum","Trifolium latifolium","Trifolium longipes","Trifolium macrocephalum","Trifolium pratense","Trifolium productum","Trifolium repens","Trifolium variegatum","Trifolium vesiculosum","Trifolium willdenovii","Trifolium wormskioldii","Triteleia grandiflora","Triteleia hyacinthina","Vaccinium angustifolium","Vaccinium corymbosum","Vaccinium ovalifolium","Vaccinium ovatum","Vaccinium parvifolium","Vaccinium uliginosum","Valeriana sitchensis","Vancouveria hexandra","Verbascum densiflorum","Verbascum thapsus","Veronica odora","Veronica scutellata","Viburnum davidii","Viburnum opulus","Vicia americana","Vicia cracca","Vicia gigantea","Vicia sativa","Vicia villosa","Vicia villosa villosa","Viola Ã— wittrockiana","Viola adunca","Viola glabella","Viola praemorsa","Viola wittrockiana","Whipplea modesta","Wyethia amplexicaulis","Wyethia angustifolia","Wyethia helianthoides","Wyethia mollis","Zinnia elegans"],"group":["Bombus appositus","Bombus caliginosus","Bombus centralis","Bombus fervidus","Bombus flavidus","Bombus flavidus ","Bombus flavifrons","Bombus griseocollis","Bombus huntii","Bombus impatiens","Bombus insularis","Bombus melanopygus","Bombus mixtus","Bombus morrisoni","Bombus nevadensis","Bombus occidentalis","Bombus rufocinctus","Bombus sitkensis","Bombus sitkensis ","Bombus sylvicola","Bombus sylvicola ","Bombus vagans","Bombus vancouverensis","Bombus vandykei","Bombus vosnesenskii","Abelia Ã— grandiflora","Abies grandis Ã— concolor","Abronia latifolia","Acer circinatum","Acer macrophyllum","Achillea millefolium","Acmispon americanus","Acmispon decumbens","Aconitum columbianum","Aconitum columbianum howellii","Actaea elata alpestris","Adelinia grandis","Aegopodium podagraria","Aesculus hippocastanum","Agastache \nurticifolia","Agastache foeniculum","Agastache urticifolia","Ageratina occidentalis","Agoseris aurantiaca","Agoseris glauca","Ajuga reptans","Alcea biennis","Alcea rosea","Allium acuminatum","Allium amplectens","Allium cernuum","Allium crenulatum","Allium nevii","Allium platycaule","Allium schoenoprasum","Allium triquetrum","Allium validum","Allotropa virgata","Amelanchier alnifolia","Amorpha fruticosa","Amsinckia menziesii","Amsinckia tessellata","Anaphalis margaritacea","Anchusa officinalis","Angelica arguta","Angelica capitellata","Angelica lucida","Antennaria media","Apocynum Ã— floribundum","Apocynum androsaemifolium","Apocynum cannabinum","Aquilegia formosa","Aquilegia vulgaris","Arbutus menziesii","Arctium minus","Arctostaphylos Ã— media","Arctostaphylos bakeri","Arctostaphylos canescens","Arctostaphylos columbiana","Arctostaphylos densiflora","Arctostaphylos manzanita","Arctostaphylos nevadensis","Arctostaphylos patula","Arctostaphylos uva-ursi","Arctostaphylos viscida","Argentina anserina","Argentina pacifica","Arnica chamissonis","Arnica cordifolia","Arnica lanceolata","Arnica latifolia","Arnica longifolia","Arnica mollis","Artemisia tridentata","Aruncus dioicus","Asclepias fascicularis","Asclepias incarnata","Asclepias speciosa","Asparagus officinalis","Astragalus accidens","Astragalus curvicarpus","Astragalus cusickii","Astragalus filipes","Astragalus hoodianus","Astragalus iodanthus","Astragalus lentiginosus","Astragalus racemosus","Astragalus sheldonii","Astragalus whitneyi","Balsamorhiza careyana","Balsamorhiza deltoidea","Balsamorhiza hookeri","Balsamorhiza incana","Balsamorhiza sagittata","Barbarea orthoceras","Bellardia viscosa","Bellis perennis","Berberis aquifolium","Berberis darwinii","Berberis piperiana","Berberis repens","Bidens cernua","Bistorta bistortoides","Blepharipappus scaber","Borago officinalis","Boykinia major","Brassica oleracea","Brassica rapa","Brodiaea elegans","Buddleja davidii","Cakile edentula","Cakile maritima","Calendula officinalis","Calluna vulgaris","Calochortus eurycarpus","Calochortus macrocarpus","Calochortus subalpinus","Calochortus tolmiei","Caltha leptosepala","Calyptridium monospermum","Calyptridium umbellatum","Calystegia soldanella","Camassia cusickii","Camassia leichtlinii","Camassia leichtlinii suksdorfii","Camassia quamash","Campanula scouleri","Canadanthus modestus","Caragana arborescens","Carduus nutans","Carduus pycnocephalus","Castilleja ambigua","Castilleja applegatei","Castilleja applegatei pinetorum","Castilleja campestris","Castilleja collegiorum","Castilleja exserta","Castilleja hispida","Castilleja hispida hispida","Castilleja miniata","Castilleja pilosa","Castilleja septentrionalis","Castilleja tenuis","Ceanothus cordulatus","Ceanothus cuneatus","Ceanothus gloriosus","Ceanothus impressus","Ceanothus integerrimus","Ceanothus papillosus","Ceanothus prostratus","Ceanothus prostratus prostratus","Ceanothus pumilus","Ceanothus thyrsiflorus","Ceanothus thyrsiflorus thyrsiflorus","Ceanothus velutinus","Centaurea Ã— moncktonii","Centaurea cyanus","Centaurea diffusa","Centaurea jacea","Centaurea montana","Centaurea solstitialis","Centaurea stoebe","Centaurium erythraea","Centromadia fitchii","Cercis occidentalis","Chaenactis douglasii","Chaenactis douglasii douglasii","Chamaebatiaria millefolium","Chamaenerion angustifolium","Chimaphila umbellata","Chondrilla juncea","Chrysolepis chrysophylla","Chrysolepis sempervirens","Chrysopsis mariana","Chrysothamnus viscidiflorus","Cichorium intybus","Cicuta douglasii","Cirsium andersonii","Cirsium arvense","Cirsium brevistylum","Cirsium cymosum","Cirsium cymosum canovirens","Cirsium edule","Cirsium inamoenum","Cirsium inamoenum inamoenum","Cirsium peckii","Cirsium remotifolium","Cirsium remotifolium odontolepis","Cirsium scariosum","Cirsium undulatum","Cirsium vulgare","Clarkia amoena","Clarkia amoena caurina","Clarkia amoena lindleyi","Clarkia pulchella","Clarkia purpurea","Clarkia rhomboidea","Claytonia sibirica","Cleomella lutea","Cleomella serrulata","Clinopodium vulgare","Collinsia grandiflora","Collinsia linearis","Collinsia parviflora","Collinsia sparsiflora","Collinsia torreyi","Collomia grandiflora","Collomia mazama","Columbiadoria hallii","Convolvulus arvensis","Cordylanthus tenuis","Coreopsis verticillata","Cornus sericea","Cornus unalaschkensis","Cosmos bipinnatus","Cotinus coggygria","Cotoneaster coriaceus","Cotoneaster franchetii","Cotoneaster horizontalis","Crassula tetragona","Crataegus douglasii","Crataegus monogyna","Crepis acuminata","Crepis setosa","Croton setiger","Cryptantha intermedia","Cucumis sativus","Cucurbita maxima","Cucurbita moschata","Cucurbita pepo","Cuscuta pacifica","Cynara cardunculus","Cynara cardunculus flavescens","Cynoglossum officinale","Cytisus scoparius","Dalea ornata","Damasonium californicum","Dasiphora fruticosa","Daucus carota","Delosperma cooperi","Delphinium leucophaeum","Delphinium menziesii","Delphinium nuttallianum","Delphinium nuttallii","Delphinium trolliifolium","Descurainia sophia","Dicentra formosa","Dicentra formosa formosa","Dieteria canescens","Digitalis purpurea","Dipsacus fullonum","Doellingeria breweri","Doellingeria ledophylla","Doellingeria ledophylla ledophylla","Drymocallis glandulosa","Drymocallis pseudorupestris","Echinacea purpurea","Elaeagnus umbellata","Epilobium brachycarpum","Epilobium ciliatum","Epilobium densiflorum","Eremogone congesta","Eremogone kingii","Erica Ã— darleyensis","Erica carnea","Erica cinerea","Ericameria bloomeri","Ericameria discoidea","Ericameria greenei","Ericameria linearifolia","Ericameria nauseosa","Ericameria nauseosa glabrata","Erigeron aliceae","Erigeron bloomeri","Erigeron divergens","Erigeron foliosus","Erigeron glacialis","Erigeron inornatus","Erigeron peregrinus","Erigeron pumilus","Erigeron speciosus","Eriodictyon californicum","Eriogonum compositum","Eriogonum elatum","Eriogonum heracleoides","Eriogonum inflatum","Eriogonum niveum","Eriogonum nudum","Eriogonum ovalifolium","Eriogonum sphaerocephalum","Eriogonum strictum","Eriogonum umbellatum","Eriophyllum confertiflorum","Eriophyllum lanatum","Eriophyllum lanatum integrifolium","Erodium cicutarium","Eryngium planum","Erysimum cheiranthoides","Erythranthe decora","Erythranthe grandis","Erythranthe guttata","Erythranthe lewisii","Erythranthe microphylla","Escallonia rubra","Eschscholzia californica","Eucryphia cordifolia","Euonymus occidentalis","Euphorbia esula","Euphorbia lathyris","Eurybia integrifolia","Eurybia radulina","Euthamia occidentalis","Fagopyrum esculentum","Ficaria verna","Fragaria cascadensis","Fragaria chiloensis","Fragaria vesca","Frangula californica","Frangula purshiana","Frasera albicaulis","Frasera albicaulis nitida","Frasera speciosa","Fuchsia magellanica","Gaillardia aristata","Gaillardia pinnatifida","Gaillardia pulchella","Galanthus nivalis","Gaultheria shallon","Gentiana affinis","Gentiana andrewsii","Gentiana calycosa","Gentiana newberryi","Gentiana sceptrum","Geranium lucidum","Geranium oreganum","Geranium robertianum","Geranium viscosissimum","Geum coccineum","Geum macrophyllum","Geum triflorum","Gilia capitata","Gilia capitata capitata","Glandora prostrata","Glebionis segetum","Glechoma hederacea","Glycyrrhiza lepidota","Gratiola ebracteata","Grindelia hirsutula","Grindelia integrifolia","Grindelia nana","Grindelia squarrosa","Grindelia stricta","Gutierrezia sarothrae","Gypsophila vaccaria","Hackelia californica","Hackelia micrantha","Helenium autumnale","Helenium bigelovii","Helenium bolanderi","Helianthella uniflora","Helianthus annuus","Helianthus cusickii","Helianthus exilis","Heliopsis helianthoides","Heracleum maximum","Heracleum sphondylium","Heuchera cylindrica","Heuchera micrantha","Hirschfeldia incana","Holodiscus discolor","Holodiscus discolor microphyllus","Horkelia fusca","Horkelia hendersonii","Horkelia howellii","Hosackia crassifolia","Hosackia gracilis","Hosackia oblongifolia","Hosackia rosea","Hyacinthoides hispanica","Hydrophyllum capitatum","Hydrophyllum capitatum thompsonii","Hydrophyllum fendleri","Hydrophyllum occidentale","Hydrophyllum tenuipes","Hymenoxys hoopesii","Hypericum calycinum","Hypericum perforatum","Hypericum scouleri","Hypochaeris radicata","Hyssopus officinalis","Iliamna rivularis","Ipomopsis aggregata","Iris douglasiana","Iris innominata","Iris missouriensis","Iris tenax","Ivesia gordonii","Jacobaea vulgaris","Jaumea carnosa","Kalmia microphylla","Kalmia polifolia","Kickxia elatine","Kniphofia uvaria","Kolkwitzia amabilis","Kopsiopsis strobilacea","Kyhosia bolanderi","Lactuca serriola","Ladeania lanceolata","Lagerstroemia subcostata","Lamium purpureum","Lapsana communis","Lasthenia californica","Lathyrus hirsutus","Lathyrus japonicus","Lathyrus lanszwertii","Lathyrus latifolius","Lathyrus nevadensis","Lathyrus palustris","Lathyrus polyphyllus","Lathyrus sylvestris","Lavandula angustifolia","Lavandula dentata","Lavandula pedunculata","Lavandula stoechas","Leontodon saxatilis","Lepidium appelianum","Leucanthemum maximum","Leucanthemum vulgare","Leucophysalis nana","Lewisia columbiana wallowensis","Leycesteria formosa","Ligusticum grayi","Lilium columbianum","Limnanthes douglasii","Linaria dalmatica","Linaria dalmatica dalmatica","Linaria maroccana","Linaria purpurea","Linaria vulgaris","Linnaea borealis","Linum lewisii","Lithospermum ruderale","Lobelia erinus","Lomatium californicum","Lomatium columbianum","Lomatium dissectum","Lomatium hallii","Lomatium triternatum","Lonicera caerulea","Lonicera conjugialis","Lonicera hispidula","Lonicera involucrata","Lotus corniculatus","Lotus pedunculatus","Lotus pedunculatus pedunculatus","Luetkea pectinata","Lupinus albicaulis","Lupinus albifrons","Lupinus arboreus","Lupinus arbustus","Lupinus argenteus","Lupinus bicolor","Lupinus breweri","Lupinus burkei","Lupinus latifolius","Lupinus lepidus","Lupinus leucophyllus","Lupinus littoralis","Lupinus polyphyllus","Lupinus rivularis","Lupinus sericeus","Lupinus sulphureus","Lythrum salicaria","Madia elegans","Madia gracilis","Madia sativa","Mahonia aquifolium","Maianthemum stellatum","Malus domestica","Malus fusca","Malus sylvestris","Malva arborea","Malva neglecta","Marah oregana","Marrubium vulgare","Medicago sativa","Melilotus albus","Melilotus officinalis","Mentha Ã— piperita","Mentha canadensis","Mentha pulegium","Mentha spicata","Mentzelia albicaulis","Mentzelia laevicaulis","Mertensia ciliata","Mertensia longiflora","Mertensia paniculata","Microseris nutans","Monarda citriodora","Monarda didyma","Monarda fistulosa","Monardella odoratissima","Monardella villosa","Muscari armeniacum","Myosotis discolor","Nemophila menziesii","Nepeta Ã— faassenii","Nepeta cataria","Nepeta faassenii","Nepeta grandiflora","Nepeta racemosa","Nothochelone nemorosa","Oemleria cerasiformis","Oenanthe sarmentosa","Oenothera biennis","Oenothera lindheimeri","Oenothera pallida","Olsynium douglasii","Onopordum acanthium","Oreostemma alpigenum","Origanum vulgare","Orthocarpus bracteosus","Orthocarpus cuspidatus","Orthocarpus imbricatus","Packera hesperia","Packera macounii","Papaver somniferum","Pedicularis attollens","Pedicularis groenlandica","Pedicularis racemosa","Pediomelum tenuiflorum","Pelargonium amaryllidis","Penstemon acuminatus","Penstemon anguineus","Penstemon attenuatus","Penstemon cardwellii","Penstemon cinicola","Penstemon confertus","Penstemon davidsonii","Penstemon deustus","Penstemon euglaucus","Penstemon fruticosus","Penstemon glaucinus","Penstemon globosus","Penstemon hesperius","Penstemon heterophyllus","Penstemon humilis","Penstemon laetus","Penstemon ovatus","Penstemon parvulus","Penstemon peckii","Penstemon pinifolius","Penstemon procerus","Penstemon richardsonii","Penstemon rydbergii","Penstemon serrulatus","Penstemon speciosus","Penstemon spectabilis","Penstemon subserratus","Penstemon venustus","Penstemon wilcoxii","Pentaglottis sempervirens","Perideridia gairdneri","Perideridia oregana","Petasites frigidus palmatus","Phacelia argentea","Phacelia corymbosa","Phacelia hastata","Phacelia hastata alpina","Phacelia heterophylla","Phacelia heterophylla virgata","Phacelia imbricata","Phacelia linearis","Phacelia mutabilis","Phacelia nemoralis","Phacelia nemoralis oregonensis","Phacelia procera","Phacelia ramosissima","Phacelia sericea","Phacelia sericea ciliosa","Phacelia tanacetifolia","Philadelphus coronarius","Philadelphus lewisii","Phyllodoce empetriformis","Physocarpus capitatus","Picea pungens","Picea sitchensis","Pieris japonica","Pilosella caespitosa","Plagiobothrys figuratus","Plagiobothrys nothofulvus","Plantago lanceolata","Plectritis congesta","Plectritis congesta congesta","Polemonium californicum","Polemonium carneum","Polemonium occidentale","Polygonum douglasii","Polygonum paronychia","Polygonum phytolaccifolium","Populus tremuloides","Potentilla breweri","Potentilla flabellifolia","Potentilla gracilis","Potentilla norvegica","Potentilla recta","Primula hendersonii","Primula jeffreyi","Primula jeffreyi jeffreyi","Primula pauciflora","Prosartes smithii","Prunella vulgaris","Prunella vulgaris lanceolata","Prunus avium","Prunus domestica","Prunus emarginata","Prunus laurocerasus","Prunus persica","Prunus serrulata","Prunus subcordata rubicunda","Prunus virginiana","Purshia tridentata","Pyrrocoma carthamoides","Pyrrocoma hirta","Ranunculus occidentalis","Ranunculus repens","Raphanus raphanistrum","Raphanus raphanistrum sativus","Raphanus sativus","Reynoutria japonica","Rhododendron catawbiense","Rhododendron columbianum","Rhododendron macrophyllum","Rhododendron maximum","Rhododendron menziesii","Rhododendron occidentale","Rhododendron ponticum","Ribes aureum","Ribes cereum","Ribes inerme","Ribes nigrum","Ribes oxyacanthoides","Ribes rubrum","Ribes sanguineum","Ribes uva-crispa","Ribes velutinum","Robinia pseudoacacia","Rorippa indica","Rosa canina","Rosa gymnocarpa","Rosa multiflora","Rosa nutkana","Rosa rubiginosa","Rosa rugosa","Rosa woodsii","Rubus armeniacus","Rubus bifrons","Rubus fruticosus","Rubus idaeus","Rubus idaeus strigosus","Rubus laciniatus","Rubus parviflorus","Rubus rolfei","Rubus spectabilis","Rubus ursinus","Rubus vestitus","Rudbeckia glaucescens","Rudbeckia hirta","Rudbeckia occidentalis","Rupertia physodes","Salix boothii","Salix hookeriana","Salix lucida","Salix planifolia","Salix sitchensis","Salvia dorrii","Salvia dorrii dorrii","Salvia greggii","Salvia leucantha","Salvia nemorosa","Salvia officinalis","Salvia pratensis","Salvia rosmarinus","Salvia yangii","Sanguisorba officinalis","Santolina chamaecyparissus","Satureja montana","Saussurea americana","Scorzoneroides autumnalis","Scrophularia californica","Scrophularia lanceolata","Scutellaria angustifolia","Scutellaria integrifolia","Securigera varia","Sedum album","Sedum lanceolatum","Sedum obtusatum","Sedum oreganum","Sedum oregonense","Sedum spathulifolium","Sedum stenopetalum","Sedum stenopetalum ciliosum","Senecio crassulus","Senecio fremontii","Senecio hydrophiloides","Senecio hydrophilus","Senecio integerrimus","Senecio serra","Senecio triangularis","Senecio vulgaris","Sericocarpus oregonensis","Sidalcea campestris","Sidalcea malviflora","Sidalcea nelsoniana","Sidalcea oregana","Sidalcea virgata","Silphium perfoliatum","Sinapis alba","Sisymbrium altissimum","Sisymbrium irio","Sisyrinchium bellum","Smithiastrum prenanthoides","Solanum dulcamara","Solanum lycopersicum","Solidago canadensis","Solidago elongata","Solidago lepida","Solidago spathulata","Solidago spathulata spathulata","Solidago velutina","Solidago virgaurea","Sorbus aucuparia","Sorbus sitchensis","Spergularia macrotheca","Sphaeralcea munroana","Spiraea betulifolia","Spiraea douglasii","Spiraea japonica","Spiraea lucida","Spiraea splendens","Stachys byzantina","Stachys chamissonis","Stachys mexicana","Stachys rigida","Styrax americanus","Styrax japonicus","Swainsona formosa","Symphoricarpos albus","Symphoricarpos mollis","Symphoricarpos rotundifolius","Symphyotrichum bracteolatum","Symphyotrichum campestre","Symphyotrichum chilense","Symphyotrichum foliaceum","Symphyotrichum novae-angliae","Symphyotrichum patens","Symphyotrichum spathulatum","Symphyotrichum subspicatum","Symphytum Ã— uplandicum","Syringa vulgaris","Tagetes erecta","Tanacetum vulgare","Taraxacum officinale","Taraxia tanacetifolia","Tellima grandiflora","Tephroseris helenitis","Tetradymia canescens","Teucrium Ã— lucidrys","Teucrium chamaedrys","Thelypodium laciniatum","Thermopsis californica","Thermopsis gracilis","Thermopsis montana","Thermopsis rhombifolia","Thymus vulgaris","Tiarella trifoliata","Tiarella trifoliata unifoliata","Tithonia rotundifolia","Tolmiea menziesii","Tonella floribunda","Toxicoscordion venenosum","Triantha occidentalis","Trichostema lanceolatum","Trifolium arvense","Trifolium eriocephalum","Trifolium hirtum","Trifolium hybridum","Trifolium incarnatum","Trifolium latifolium","Trifolium longipes","Trifolium macrocephalum","Trifolium pratense","Trifolium productum","Trifolium repens","Trifolium variegatum","Trifolium vesiculosum","Trifolium willdenovii","Trifolium wormskioldii","Triteleia grandiflora","Triteleia hyacinthina","Vaccinium angustifolium","Vaccinium corymbosum","Vaccinium ovalifolium","Vaccinium ovatum","Vaccinium parvifolium","Vaccinium uliginosum","Valeriana sitchensis","Vancouveria hexandra","Verbascum densiflorum","Verbascum thapsus","Veronica odora","Veronica scutellata","Viburnum davidii","Viburnum opulus","Vicia americana","Vicia cracca","Vicia gigantea","Vicia sativa","Vicia villosa","Vicia villosa villosa","Viola Ã— wittrockiana","Viola adunca","Viola glabella","Viola praemorsa","Viola wittrockiana","Whipplea modesta","Wyethia amplexicaulis","Wyethia angustifolia","Wyethia helianthoides","Wyethia mollis","Zinnia elegans"]},"options":{"NodeID":"name","NodeGroup":"name","LinkGroup":null,"colourScale":"d3.scaleOrdinal(d3.schemeCategory20);","fontSize":7,"fontFamily":null,"nodeWidth":15,"nodePadding":0,"units":"","margin":{"top":null,"right":null,"bottom":null,"left":null},"iterations":32,"sinksRight":true}},"evals":[],"jsHooks":[]}</script>
```

### In class: Visualization challange 1.

Choose a different genus of bees and repeat the steps above to make a network. 

### In class: Visualization challange 2. 
How could we use graph attributes to create informative network visualizations? Set some attributes and use them to plot your network.
Consider using static network plots instead of network3D, see this [turorial](https://yunranchen.github.io/intro-net-r/advanced-network-visualization.html#visualization-for-static-network) for examples.  




---

### Further reading & software

- **Reviews/guides**: @delmas2019; @bascompte2007; @landi2018.  
- **R packages**: *bipartite* [@dormann2009; @bipartite2025], *igraph* [@igraph2025], *vegan* for null models [@vegan2025].  
- **Data portals**: Web of Life [@weboflife], Mangal [@rmangal2019].



## Discussion & Reflection: Yeakel et al. (2014): Collapse of an ecological network in Ancient Egypt

> **How to use this section:** Read the article below (embedded) and prepare your answers to the discussion prompts. Bring notes to class.

### Article (embedded)
<div style="margin: 1rem 0;">
<embed src="readings/reading-Yeakel2014.pdf" type="application/pdf" width="100%" height="800px" />
</div>

### Reflection and in-class discussion Questions 

1. Climate and Political Change
The paper links pulses of aridification to social and political upheaval (collapse of Old Kingdom, First Intermediate Period, fall of the New Kingdom). Do you think ecological collapse drove political instability, or was it the other way around? Defend your view by drawing connections between ecology and human history.

2. Modern Parallels
Identify one modern ecosystem facing similar pressures (climate change, habitat loss, overexploitation). Compare it with Ancient Egypt: what lessons can be drawn about stability, redundancy, and persistence? What might the Yeakel framework suggest about its trajectory?



##  Lab: Food Webs & Network Measures (Student Version)



### Lesson Overview

**Computational Topics**
- Build and visualize food webs 
- Write functions to implement mathematical equations

**Conservation topics**
-  Paleofood webs
-  Species extinction

In this lab we will practice our network visualization and manipulation skills using the paleo food web data from [Yeakel et al. 2014](https://doi.org/10.1073/pnas.1408471111). 

![Paleoweb](labs/figures/paleoweb.jpg)

See the beautiful, animated version of the graphic above [here](https://infograficos.estadao.com.br/public/cidades/extincoes-egito/)

With some interaction networks we can observe the interactions, for example plant-pollinator networks, seed-disperal networks, human social networks. In food webs sometimes feeding interactions are observed directly, through camera traps, people doing timed observations, and now molecular analysis of gut contents/scat. However, often with food webs people build probabilistic models of who interacts with who based on body size (as in the Yeakel et al. 2014), especially with paleowebs. Thus the data from Yeakel et al. is 1) an occurrence matrix  (Figure 2 from the publication) and a matrix of body sizes (two columns, females then males). We will use these data to build the foodwebs for each time period. This lab is pretty challenging because it will use many of our core programming skills (for loops, writing functions, subsetting data) and our network skills. 

First we will read in the data. The matrix we are reading in has no row or column names, we will have to set them. 


```
## 'data.frame':	39 obs. of  23 variables:
##  $ V1 : int  1 1 1 1 1 1 1 1 0 1 ...
##  $ V2 : int  1 1 1 1 1 1 1 1 0 1 ...
##  $ V3 : int  1 1 1 1 0 1 1 1 0 1 ...
##  $ V4 : int  1 1 1 1 0 1 1 1 0 1 ...
##  $ V5 : int  1 1 1 1 0 1 1 1 0 1 ...
##  $ V6 : int  1 1 1 1 0 1 1 1 0 1 ...
##  $ V7 : int  1 1 1 1 0 1 1 1 0 1 ...
##  $ V8 : int  1 1 1 1 0 0 1 1 0 1 ...
##  $ V9 : int  1 1 1 1 0 0 1 1 0 0 ...
##  $ V10: int  1 1 1 1 0 0 1 1 0 0 ...
##  $ V11: int  1 1 1 1 0 0 1 1 0 0 ...
##  $ V12: int  1 1 1 1 0 0 1 1 1 0 ...
##  $ V13: int  1 1 1 1 0 0 1 1 1 0 ...
##  $ V14: int  1 1 0 1 0 0 1 1 1 0 ...
##  $ V15: int  1 1 0 1 0 0 1 1 1 0 ...
##  $ V16: int  1 1 0 1 0 0 1 1 1 0 ...
##  $ V17: int  1 1 0 1 0 0 1 1 1 0 ...
##  $ V18: int  1 1 0 1 0 0 0 1 1 0 ...
##  $ V19: int  1 1 0 1 0 0 0 1 1 0 ...
##  $ V20: int  1 1 0 1 0 0 0 1 1 0 ...
##  $ V21: int  1 1 0 1 0 0 0 1 0 0 ...
##  $ V22: int  1 1 0 1 0 0 0 1 0 0 ...
##  $ V23: int  1 1 0 1 0 0 0 0 0 0 ...
```

```
## 'data.frame':	39 obs. of  2 variables:
##  $ V1: int  6 4 18 25 40 122 122 50 35 2200 ...
##  $ V2: int  15 8 36 55 90 260 260 60 65 6300 ...
```
![Figure 2](labs/figures/figure2.jpg)

The rows are arranged in the order of Figure 2 of the manuscript. To set the rownames we can make a vector of the names then use the function `rownames`. We also have to note which species are predators (all those in the species in the Carnivora clade in figure 2). Otherwise we will create a web where giraffes are voracious predators consuming all of the other species (I made this mistake when constructing the networks originally). I have transcribed the data from figure 2 for you: 
 


###  Lab question 1: Creating our foodwebs based on body sizes.

- 1a. Use the above vector of species names to label the row names of the species occurrence and the body size matrices.  The columns of the species occurrence matrix are time points, so we can leave those as V1 etc., but we should set the column names of the mass matrix as "f", "m" (female and male). Use `head` to check each matrix to see if the names are displayed properly. 


Yeakel recommended an updated equation to estimate the probability a predator consumed a prey based on their relative body masses from [Rohr et al. 2010.](https://doi.org/10.1086/653667). The  probability of existence of a trophic link between a predator of body-size $m_i$ and a prey of body-size $m_j$ is given by:

![Probabilitic feeding equation](labs/figures/feeding_equ.png)
(P($A_{1j}$ = 1) is the probability predator i eats prey j). 

- 1b. Write a function and call it `probEat` to implement the equation above. Round the probability to two decimal places.

Below are the values of alpha, beta, and gamma for the Serengeti.  In addition, you will need a function to compute the inverse logit function because this equation is for the logit of the probability, so to calculate the 0-1 probability you will need to take the inverse logit of the other side of the equation. Also note, $log^2$ is equivalent to (log($m_i$/$m_j$))^2


```
## function (x) 
## exp(x)/(1 + exp(x))
```



- 1c. Now create networks of who eats whom. We will start with adjacency matrices. We will assume all of our species are the size of females. For this step, don`t worry about predators vs. prey yet, just calculate all of the feeding probabilities based on body sizes.  

Hint: if you start with a square matrix of all zeros (one row and one column for each species), you can use a for loop to fill in that matrix with probabilities calculated from your function above.



- 1d. Now that you have your matrix of potential feeding interactions based on body size, use the `carnivores` vector created above to set all of the feeding interactions of herbivores (0s in that vector) to zero. In foodwebs the columns are the higher trophic level and the rows are the lower.
HINT: the function `sweep` may be useful, though there are many approaches to do the needed matrix multiplication. Print the row and column sums. 



### Lab question 2: Breaking the networks into time periods

- 2a. With our matrix of feeding interaction we can create a web for each time period, including only the species that were not extinct in the period. Try first just using the second time period (the second column of `sp_occ`). 

Use the function `empty` from the bipartite package to empty the matrix of rows and columns with no interactions. The number of species in the second time period is 36 `sum(sp_occ[,2])`. Check to see that the number of rows in your network with probabilities > 0 is 36. 

HINT: You will need to zero out the rows where a species in not present in that time period and the columns. The function `sweep` may be useful again.



- 2b. Now create a network for all of the time points by creating a list where each element is a network. You will need to use a for loop, or an `lapply` if you feel like experimenting with apply functions. Print the first 5 columns and rows of the 5th time period. 

HINT: If choosing the for loop route, remember to create an empty list of a specific length use the function `vector`. To access a specific element of a list, use [[]], for example cool_list[[1]] accesses the first element of the list.



###  Lab question 3: Visualize the networks
- 3a. Convert the adjacency matrices to igraph class objects using the function `graph_from_adjacency_matrix`. You can use a for loop or an lapply. Because these are food webs, set the argument mode to "directed" and the argument diag to FALSE (this means a species cannot consumer members of its own species, i.e., no canabalism/self-loops). Also remember that these interactions are weighted.  



- 3b. Plot three networks of your choice, using different colors for the predators and prey.







### References
