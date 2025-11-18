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

### Linear‑algebra essentials for ecological networks

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

**Matrix multiplication in R**

``` r
A <- matrix(c(1,2,0,
              3,-1,4), nrow = 2, byrow = TRUE)
B <- matrix(c(2,1,
              0,-1,
              5,2), nrow = 3, byrow = TRUE)
A %*% B
```

```
##      [,1] [,2]
## [1,]    2   -1
## [2,]   26   12
```

**Using `sweep()` for fast row/column operations**

`sweep(x, MARGIN, STATS, FUN)` applies a vector (`STATS`) across **rows** (`MARGIN = 1`) or **columns** (`MARGIN = 2`) of a matrix/data frame using a function (`FUN`, default `"-"`).

We’ll use a mini **site × species** abundance table:


``` r
# Mini site × species abundance matrix
X <- matrix(c(
  5, 3, 2, 0,   # Site 1
  0, 4, 6, 1,   # Site 2
  2, 1, 7, 3    # Site 3
), nrow = 3, byrow = TRUE,
dimnames = list(paste0("Site", 1:3),
                c("Bee_A","Bee_B","Bee_C","Bee_D")))
X
```

```
##       Bee_A Bee_B Bee_C Bee_D
## Site1     5     3     2     0
## Site2     0     4     6     1
## Site3     2     1     7     3
```

**Column operations (species across sites)**

``` r
col_means <- colMeans(X)
col_sds   <- apply(X, 2, sd)

# Center columns: subtract each species’ mean across sites
X_col_centered <- sweep(X, MARGIN = 2, STATS = col_means, FUN = "-")

# Z-score columns: (X - mean) / sd
X_z <- sweep(X, 2, col_means, "-")
X_z <- sweep(X_z, 2, col_sds, "/")
X_z
```

```
##            Bee_A      Bee_B      Bee_C      Bee_D
## Site1  1.0596259  0.2182179 -1.1338934 -0.8728716
## Site2 -0.9271726  0.8728716  0.3779645 -0.2182179
## Site3 -0.1324532 -1.0910895  0.7559289  1.0910895
```

**Row operations (sites across species)**

``` r
row_means <- rowMeans(X)
row_sums  <- rowSums(X)

# Center rows: subtract each site’s mean abundance
X_row_centered <- sweep(X, MARGIN = 1, STATS = row_means, FUN = "-")

# Row proportions: divide each row by its row sum (compositional)
# will only with safe if no zero-sum rows)

X_prop <- sweep(X, MARGIN = 1, STATS = row_sums, FUN = "/")
X_prop
```

```
##           Bee_A      Bee_B     Bee_C      Bee_D
## Site1 0.5000000 0.30000000 0.2000000 0.00000000
## Site2 0.0000000 0.36363636 0.5454545 0.09090909
## Site3 0.1538462 0.07692308 0.5384615 0.23076923
```

**Column weights example (apply species weights to each row)**

``` r
w <- c(Bee_A = 1.0, Bee_B = 0.5, Bee_C = 1.5, Bee_D = 2.0)
X_weighted <- sweep(X, MARGIN = 2, STATS = w, FUN = "*")
row_scores <- rowSums(X_weighted)

X_weighted
```

```
##       Bee_A Bee_B Bee_C Bee_D
## Site1     5   1.5   3.0     0
## Site2     0   2.0   9.0     2
## Site3     2   0.5  10.5     6
```

``` r
row_scores
```

```
## Site1 Site2 Site3 
##   9.5  13.0  19.0
```
## In-class challenge: Matrix & vector multiplication with plant–pollinator data

We’ll use a **plant × pollinator** visitation matrix `V` (rows = plants, columns = pollinators). You’ll compute:
- a matrix–vector product (expected seeds per plant),
- row/column reweighting via diagonal matrices,
- plant–plant and pollinator–pollinator overlaps via matrix–matrix products, and
- effectiveness-weighted visits.

### In-class challenge: Matrix & vector multiplication with plant–pollinator data

We'll use a **plant × pollinator** visitation matrix `V` (rows = plants, columns = pollinators). You'll compute:

- a matrix–vector product (expected seeds per plant)
- row/column reweighting via diagonal matrices
- plant–plant and pollinator–pollinator overlaps via matrix–matrix products
- effectiveness-weighted visits.


``` r
# Data: counts of visits observed during a standardized survey period 
plants      <- c("Lupine","Sunflower","Sage")
pollinators <- c("Bombus","Apis","Halictus","Osmia")

V <- matrix(c(
  12,  7,  3,  4,   # Lupine
   5, 19,  8,  2,   # Sunflower
   9,  4, 11,  6    # Sage
), nrow = length(plants), byrow = TRUE,
dimnames = list(plants, pollinators))

# Per-visit pollination effectiveness (relative seeds per visit) for each pollinator
a <- c(Bombus = 1.8, Apis = 1.2, Halictus = 0.6, Osmia = 1.0)

# Row multipliers: change in floral display/attractiveness for each plant (next day)
row_mult <- c(Lupine = 1.10, Sunflower = 0.90, Sage = 1.00)

# Column multipliers: change in pollinator activity (next day)
col_mult <- c(Bombus = 0.80, Apis = 1.20, Halictus = 1.00, Osmia = 1.10)

V
```

```
##           Bombus Apis Halictus Osmia
## Lupine        12    7        3     4
## Sunflower      5   19        8     2
## Sage           9    4       11     6
```

**Q1. Dimensions & conformability (1 min)**

- What are the dimensions of `V`?  
- What are the dimensions of `a` (treat it as a **column** vector)?  
- Is `V %*% a` conformable? What will be the shape of the result?

*Hint:* \((S\times T)(T\times 1) \to (S\times 1)\).


``` r
dim(V)
length(a)     # number of pollinators (T)
# Conformability check: ncol(V) == length(a)
ncol(V) == length(a)
```

---

**Q2. Expected seeds per plant (matrix–vector product) (3–4 min)**

Assume **linearity** of contributions by visits:
\[\mathbf{s} \;=\; V \, \mathbf{a},\]
where \(V\) is plants×pollinators and \(\mathbf{a}\) is per-visit effectiveness (pollinators×1).


``` r
# Ensure 'a' is aligned to V's columns by name
a <- a[colnames(V)]
s <- V %*% a  # plants × 1
s

# Which pollinator contributes most to Sunflower’s expected seeds?
(V["Sunflower", ] * a)
```

**Q3. Plant co-visitation overlap (matrix–matrix product) (4 min)**

Compute **plant × plant** overlap:
\[\,
\mathbf{C}_{\text{plants}} \;=\; V\,V^\top.
\]
Entry \(c_{ij}\) is the total number of visits that plants \(i\) and \(j\) share across pollinators (diagonal = total visits per plant).


``` r
C_plants <- V %*% t(V)
C_plants
# Which plant pair shares the most pollinator effort (largest off-diagonal)?
```

---

**Other examples in networks:**

- Multiplying an **adjacency matrix** \(\mathbf{A}\) by a vector of **species abundances** \(\mathbf{N}\) yields linear combinations of partner contributions.
- \(\mathbf{A}\mathbf{1}\) (where \(\mathbf{1}\) is a vector of ones) gives **row sums** (e.g., consumer breadth “generality”), and \(\mathbf{1}^\top\mathbf{A}\) gives **column sums** (resource breadth “vulnerability”) in bipartite mutualisms [@dormann2009].
- The **two‑step reach** between nodes is encoded by \(\mathbf{A}^2\) (paths of length 2).
- In our lab we will multiple occurrence body sizes and occurrence matrices to build foodwebs for different time periods. 

---


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

### Core network properties (formulas, intuition, tools)

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

### Demo: Building networks and characterizing their structure


``` r
## Example: load a Web-of-Life matrix shipped with bipartite, "Safariland" is pollination web was published by Vázquez and Simberloff (2003).
data(Safariland)
net <- Safariland # too hard to spell... 
net
```

```
##                          Policana albopilosa Bombus dahlbomii
## Aristotelia chilensis                    673                0
## Alstroemeria aurea                         0              154
## Schinus patagonicus                        0                0
## Berberis darwinii                          0               67
## Rosa eglanteria                            0                0
## Cynanchum diemii                           0                0
## Ribes magellanicum                         0                0
## Mutisia decurrens                          0                0
## Calceolaria crenatiflora                   0                0
##                          Ruizantheda mutabilis Trichophthalma amoena
## Aristotelia chilensis                      110                     0
## Alstroemeria aurea                           0                     0
## Schinus patagonicus                          0                     0
## Berberis darwinii                            0                     0
## Rosa eglanteria                              6                     0
## Cynanchum diemii                             0                     0
## Ribes magellanicum                           0                     2
## Mutisia decurrens                            0                     0
## Calceolaria crenatiflora                     0                     0
##                          Syrphus octomaculatus Manuelia gayi
## Aristotelia chilensis                        0             0
## Alstroemeria aurea                           5             7
## Schinus patagonicus                          0             0
## Berberis darwinii                            5             0
## Rosa eglanteria                              4             0
## Cynanchum diemii                             0             0
## Ribes magellanicum                           0             0
## Mutisia decurrens                            0             0
## Calceolaria crenatiflora                     0             0
##                          Allograpta.Toxomerus Trichophthalma jaffueli Phthiria
## Aristotelia chilensis                       0                       0        0
## Alstroemeria aurea                          1                       3        8
## Schinus patagonicus                         0                       0        0
## Berberis darwinii                           0                       0        0
## Rosa eglanteria                             2                       0        0
## Cynanchum diemii                            0                       0        0
## Ribes magellanicum                          3                       0        0
## Mutisia decurrens                           0                       0        1
## Calceolaria crenatiflora                    1                       0        0
##                          Platycheirus1 Sapromyza.Minettia Formicidae3
## Aristotelia chilensis                4                  0           0
## Alstroemeria aurea                   1                  1           0
## Schinus patagonicus                  0                  0           0
## Berberis darwinii                    0                  0           0
## Rosa eglanteria                      0                  0           0
## Cynanchum diemii                     0                  0           8
## Ribes magellanicum                   0                  0           0
## Mutisia decurrens                    0                  0           0
## Calceolaria crenatiflora             0                  0           0
##                          Nitidulidae Staphilinidae Ichneumonidae4 Braconidae3
## Aristotelia chilensis              0             0              1           0
## Alstroemeria aurea                 0             4              0           0
## Schinus patagonicus                0             0             15           0
## Berberis darwinii                  0             0              0           0
## Rosa eglanteria                    0             3              0           0
## Cynanchum diemii                   1             0              0           2
## Ribes magellanicum                 0             0              0           0
## Mutisia decurrens                  0             0              0           0
## Calceolaria crenatiflora           0             0              0           0
##                          Chalepogenus caeruleus Vespula germanica Torymidae2
## Aristotelia chilensis                         0                 0          0
## Alstroemeria aurea                            0                 4          0
## Schinus patagonicus                           0                 0          0
## Berberis darwinii                             0                 0          0
## Rosa eglanteria                               0                 0          0
## Cynanchum diemii                              0                 0          9
## Ribes magellanicum                            0                 0          0
## Mutisia decurrens                             0                 0          0
## Calceolaria crenatiflora                      3                 0          0
##                          Phthiria1 Svastrides melanura Sphecidae Thomisidae
## Aristotelia chilensis            0                   0         0          0
## Alstroemeria aurea               1                   6         1          1
## Schinus patagonicus              0                   0         0          0
## Berberis darwinii                0                   0         0          0
## Rosa eglanteria                  0                   0         0          0
## Cynanchum diemii                 0                   0         0          0
## Ribes magellanicum               0                   0         0          0
## Mutisia decurrens                0                   0         0          0
## Calceolaria crenatiflora         0                   0         0          0
##                          Corynura prothysteres Ichneumonidae2
## Aristotelia chilensis                        1              0
## Alstroemeria aurea                           3              4
## Schinus patagonicus                          0              0
## Berberis darwinii                            0              0
## Rosa eglanteria                              0              0
## Cynanchum diemii                             0              0
## Ribes magellanicum                           0              0
## Mutisia decurrens                            0              0
## Calceolaria crenatiflora                     0              0
##                          Ruizantheda proxima Braconidae2
## Aristotelia chilensis                      0           1
## Alstroemeria aurea                         4           0
## Schinus patagonicus                        0           0
## Berberis darwinii                          0           0
## Rosa eglanteria                            0           0
## Cynanchum diemii                           0           0
## Ribes magellanicum                         0           0
## Mutisia decurrens                          0           0
## Calceolaria crenatiflora                   0           0
```


``` r
# Basic size and connectance
S_row <- nrow(net); S_col <- ncol(net); L <- sum(net > 0)
connectance <- L/(S_row*S_col)

# A few descriptors 
networklevel(net, index=c("connectance","H2","nestedness","modularity"))
```

```
##  connectance modularity Q   nestedness           H2 
##    0.1604938    0.4301558   19.9310086    0.8537307
```



``` r
## Some species level metrics, notice the output is a list with the higher and lower levels as elements.

specieslevel(net, index=c("species strength","d", "degree", "betweenness", "closeness"))
```

```
## $`higher level`
##                         degree species.strength betweenness
## Policana albopilosa          1      0.851898734  0.00000000
## Bombus dahlbomii             2      1.670940171  0.00000000
## Ruizantheda mutabilis        2      0.539240506  0.04807692
## Trichophthalma amoena        1      0.400000000  0.00000000
## Syrphus octomaculatus        3      0.360149573  0.02307692
## Manuelia gayi                1      0.033653846  0.00000000
## Allograpta.Toxomerus         4      0.988141026  0.41730769
## Trichophthalma jaffueli      1      0.014423077  0.00000000
## Phthiria                     2      1.038461538  0.00000000
## Platycheirus1                2      0.009870983  0.24423077
## Sapromyza.Minettia           1      0.004807692  0.00000000
## Formicidae3                  1      0.400000000  0.00000000
## Nitidulidae                  1      0.050000000  0.00000000
## Staphilinidae                2      0.219230769  0.02307692
## Ichneumonidae4               2      1.001265823  0.00000000
## Braconidae3                  1      0.100000000  0.00000000
## Chalepogenus caeruleus       1      0.750000000  0.00000000
## Vespula germanica            1      0.019230769  0.00000000
## Torymidae2                   1      0.450000000  0.00000000
## Phthiria1                    1      0.004807692  0.00000000
## Svastrides melanura          1      0.028846154  0.00000000
## Sphecidae                    1      0.004807692  0.00000000
## Thomisidae                   1      0.004807692  0.00000000
## Corynura prothysteres        2      0.015688900  0.24423077
## Ichneumonidae2               1      0.019230769  0.00000000
## Ruizantheda proxima          1      0.019230769  0.00000000
## Braconidae2                  1      0.001265823  0.00000000
##                         weighted.betweenness   closeness weighted.closeness
## Policana albopilosa               0.00000000 0.031499203        0.007653246
## Bombus dahlbomii                  0.27133479 0.045454545        0.016935668
## Ruizantheda mutabilis             0.18161926 0.035885167        0.007635430
## Trichophthalma amoena             0.00000000 0.026315789        0.002008598
## Syrphus octomaculatus             0.26805252 0.046650718        0.009803161
## Manuelia gayi                     0.00000000 0.045454545        0.007645691
## Allograpta.Toxomerus              0.17943107 0.049043062        0.004113559
## Trichophthalma jaffueli           0.00000000 0.045454545        0.004331303
## Phthiria                          0.00000000 0.045454545        0.008236576
## Platycheirus1                     0.09956236 0.050239234        0.003845416
## Sapromyza.Minettia                0.00000000 0.045454545        0.001720655
## Formicidae3                       0.00000000 0.007177033        0.000000000
## Nitidulidae                       0.00000000 0.007177033        0.000000000
## Staphilinidae                     0.00000000 0.046650718        0.006203052
## Ichneumonidae4                    0.00000000 0.031499203        0.001525954
## Braconidae3                       0.00000000 0.007177033        0.000000000
## Chalepogenus caeruleus            0.00000000 0.026315789        0.002535735
## Vespula germanica                 0.00000000 0.045454545        0.005345012
## Torymidae2                        0.00000000 0.007177033        0.000000000
## Phthiria1                         0.00000000 0.045454545        0.001720655
## Svastrides melanura               0.00000000 0.045454545        0.006978210
## Sphecidae                         0.00000000 0.045454545        0.001720655
## Thomisidae                        0.00000000 0.045454545        0.001720655
## Corynura prothysteres             0.00000000 0.050239234        0.004526406
## Ichneumonidae2                    0.00000000 0.045454545        0.005345012
## Ruizantheda proxima               0.00000000 0.045454545        0.005345012
## Braconidae2                       0.00000000 0.031499203        0.001525954
##                                 d
## Policana albopilosa     0.6905693
## Bombus dahlbomii        0.8581794
## Ruizantheda mutabilis   0.1554289
## Trichophthalma amoena   0.8474066
## Syrphus octomaculatus   0.3859789
## Manuelia gayi           0.3202602
## Allograpta.Toxomerus    0.6482363
## Trichophthalma jaffueli 0.2647268
## Phthiria                0.3916793
## Platycheirus1           0.0000000
## Sapromyza.Minettia      0.2000132
## Formicidae3             0.8115396
## Nitidulidae             0.5510016
## Staphilinidae           0.4092484
## Ichneumonidae4          0.9007713
## Braconidae3             0.6165417
## Chalepogenus caeruleus  0.9500994
## Vespula germanica       0.2834746
## Torymidae2              0.8322740
## Phthiria1               0.2000132
## Svastrides melanura     0.3083018
## Sphecidae               0.2000132
## Thomisidae              0.2000132
## Corynura prothysteres   0.1209998
## Ichneumonidae2          0.2834746
## Ruizantheda proxima     0.2834746
## Braconidae2             0.0000000
## 
## $`lower level`
##                          degree species.strength betweenness
## Aristotelia chilensis         6        4.0607759         0.3
## Alstroemeria aurea           17       13.6071500         0.5
## Schinus patagonicus           1        0.9375000         0.0
## Berberis darwinii             2        0.6603103         0.0
## Rosa eglanteria               4        1.0517241         0.2
## Cynanchum diemii              4        4.0000000         0.0
## Ribes magellanicum            2        1.4285714         0.0
## Mutisia decurrens             1        0.1111111         0.0
## Calceolaria crenatiflora      2        1.1428571         0.0
##                          weighted.betweenness  closeness weighted.closeness
## Aristotelia chilensis               0.2222222 0.12931034        0.022311369
## Alstroemeria aurea                  0.4074074 0.16810345        0.019174528
## Schinus patagonicus                 0.0000000 0.08620690        0.028303507
## Berberis darwinii                   0.0000000 0.11206897        0.018597603
## Rosa eglanteria                     0.3703704 0.15517241        0.020088268
## Cynanchum diemii                    0.0000000 0.00000000        0.000000000
## Ribes magellanicum                  0.0000000 0.12500000        0.014799036
## Mutisia decurrens                   0.0000000 0.09913793        0.005731637
## Calceolaria crenatiflora            0.0000000 0.12500000        0.006640118
##                                  d
## Aristotelia chilensis    0.9613968
## Alstroemeria aurea       0.8043229
## Schinus patagonicus      0.9846607
## Berberis darwinii        0.5619798
## Rosa eglanteria          0.5590405
## Cynanchum diemii         1.0000000
## Ribes magellanicum       0.9036839
## Mutisia decurrens        0.6625752
## Calceolaria crenatiflora 0.9106928
```
### Null models for fair comparisons

Because many metrics scale with **network size**, **fill**, and **sampling**, compare observed metrics to **null expectations** generated by randomization [@dormann2009; @ulrich2009].

#### Families of null models

1. **Equiprobable / probabilistic**: each cell has the same probability of being 1 (binary) or a probability proportional to row/column totals. Good for testing strong structure but can inflate Type I error (probability of false positives) with heterogeneous marginals [@gotelli2000].
2. **Constrained marginals**: preserve row and/or column totals to mimic sampling and abundance effects.  
   - **Fixed–Fixed (FF)**: preserve both row and column sums via **swap**, **trial‑swap**, **curveball** algorithms [@miklos2004; @strona2014].  
   - **Fixed–Equiprobable (FE)** / **Equiprobable–Fixed (EF)**: preserve one margin, randomize the other [@ulrich2007].

#### Demo: Null models


``` r
# NODF standardized with constrained nulls
obs <- networklevel(net, index="nestedness")

set.seed(1)
# vegan's oecosimu framework with quasiswap (fixed row & column sums)
null_fun <- function(x) vegan::nestedtemp(x, "NODF")$statistic
oecosimu(net>0, null_fun,
         method = "quasiswap", nsimul = 1000)  # Miklós & Podani 2004
```

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

Report **z‑scores** or **p‑values** based on the null distribution; when comparing many networks, use the same null model family for consistency [@dormann2009].


### Demo: Calculating network metrics (pollination)


``` r
data(Safariland)
net <- Safariland

# Selected metrics
networklevel(net, index=c("connectance","H2","nestedness","modularity"))
```

```
##  connectance modularity Q   nestedness           H2 
##    0.1604938    0.4301558   19.8923563    0.8537307
```

``` r
# Species roles
specieslevel(net, index=c("degree","d"))
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

``` r
# Null-model standardized nestedness

oecosimu(net, function(x) nestedtemp(x,"NODF")$statistic,
         method="quasiswap", nsimul=999)
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
## temperature    19.749 0.38594 19.103 16.422 19.173 22.271    0.799
```

Interpretation tips: high \(H_2'\) means **specialized** interactions; high NODF indicates **nested** structure; high \(Q\) implies **modules** (compartments).

### Demo: Create a graph from OBA data, visualize it
Let's load in our OBA data and make a network for all the bumble bees in Oregon. We will need to subset the data, then keep only the bee and plant species columns. 


``` r
oba <- read.csv("data/OBA_2018-2023.csv")
str(oba)
```

```
## 'data.frame':	195788 obs. of  67 variables:
##  $ Observation.No.                    : chr  "Andony_Melathopoulos:18.001.001" "Andony_Melathopoulos:18.002.001" "Andony_Melathopoulos:18.002.002" "Andony_Melathopoulos:18.002.003" ...
##  $ Voucher.No.                        : chr  "" "" "" "" ...
##  $ user_id                            : int  429964 429964 429964 429964 429964 429964 429964 429964 429964 429964 ...
##  $ user_login                         : chr  "amelathopoulos" "amelathopoulos" "amelathopoulos" "amelathopoulos" ...
##  $ Collector...First.Name             : chr  "Andony" "Andony" "Andony" "Andony" ...
##  $ Collector...First.Initial          : chr  "A." "A." "A." "A." ...
##  $ Collector...Last.Name              : chr  "Melathopoulos" "Melathopoulos" "Melathopoulos" "Melathopoulos" ...
##  $ Collectors                         : chr  "A.Melathopoulos" "A.Melathopoulos" "A.Melathopoulos" "A.Melathopoulos" ...
##  $ taxon_kingdom_name                 : chr  "" "" "" "" ...
##  $ Associated.plant...genus..species  : chr  "" "" "" "" ...
##  $ url                                : chr  "" "" "" "" ...
##  $ Sample.ID                          : chr  "" "" "" "" ...
##  $ Specimen.ID                        : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ Collection.Day.1                   : chr  "18" "20" "20" "20" ...
##  $ Month.1                            : chr  "iii" "iii" "iii" "iii" ...
##  $ MonthJul                           : chr  "March" "March" "March" "March" ...
##  $ MonthAb                            : int  3 3 3 3 9 9 9 9 3 3 ...
##  $ Year.1                             : int  2018 2018 2018 2018 2018 2018 2018 2018 2018 2018 ...
##  $ Collection.Date                    : chr  "3/18/2018" "3/20/2018" "3/20/2018" "3/20/2018" ...
##  $ Time.1                             : chr  "" "" "" "" ...
##  $ Collection.Day.2                   : chr  "" "" "" "" ...
##  $ Month.2                            : chr  "" "" "" "" ...
##  $ Year.2                             : chr  "" "" "" "" ...
##  $ Collection.Day.2.Merge             : chr  "" "" "" "" ...
##  $ Time.2                             : chr  "" "" "" "" ...
##  $ Collection.ID                      : chr  "A Melathopoulos " "A Melathopoulos" "A Melathopoulos" "A Melathopoulos" ...
##  $ Position.of.1st.digit              : chr  "" "" "" "" ...
##  $ Collection.No.                     : chr  "1" "2" "2" "2" ...
##  $ Sample.No.                         : int  1 1 2 3 4 5 6 7 1 1 ...
##  $ Country                            : chr  "USA" "USA" "USA" "USA" ...
##  $ State                              : chr  "Oregon" "Oregon" "Oregon" "Oregon" ...
##  $ County                             : chr  "Benton" "Benton" "Benton" "Benton" ...
##  $ Location                           : chr  "Corvallis, NW Orchard Ave" "Corvallis, NW Orchard Ave" "Corvallis, NW Orchard Ave" "Corvallis, NW Orchard Ave" ...
##  $ Abbreviated.Location               : chr  "Astoria Maggie Johnson Rd" "Big Crk. Mainline Knob Pt Rd" "Big Crk. Mainline Knob Pt Rd" "Big Crk. Mainline Knob Pt Rd" ...
##  $ Collection.Site.Description        : chr  "" "" "" "" ...
##  $ Team                               : chr  "Melathopoulos" "Melathopoulos" "Melathopoulos" "Melathopoulos" ...
##  $ Habitat                            : chr  "" "" "" "" ...
##  $ Elevation..m.                      : chr  "" "" "" "" ...
##  $ Dec..Lat.                          : num  44.6 44.6 44.6 44.6 46.1 ...
##  $ Dec..Long.                         : num  -123 -123 -123 -123 -124 ...
##  $ X                                  : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ Collectionmethod                   : chr  "Net" "Net" "Net" "Net" ...
##  $ Collection.method.merge.field      : chr  "" "" "" "" ...
##  $ Associated.plant...family          : chr  "" "" "" "" ...
##  $ Associated.plant...genus..species.1: chr  "" "" "" "" ...
##  $ Associated.plant...Inaturalist.URL : chr  "" "" "" "" ...
##  $ Associated.plant                   : chr  "" "" "" "" ...
##  $ Assoc.plant.merge.field            : chr  "" "" "" "" ...
##  $ Collectors.1                       : chr  "Andony Melathopoulos" "Andony Melathopoulos" "Andony Melathopoulos" "Andony Melathopoulos" ...
##  $ Collector.1.abreviation            : chr  "A Melathopoulos " "A Melathopoulos" "A Melathopoulos" "A Melathopoulos" ...
##  $ Collector.2                        : logi  NA NA NA NA NA NA ...
##  $ Collector.3                        : logi  NA NA NA NA NA NA ...
##  $ Genus                              : chr  "" "" "" "" ...
##  $ Species                            : chr  "" "" "" "" ...
##  $ sex                                : chr  "" "" "" "" ...
##  $ caste                              : chr  "" "" "" "" ...
##  $ vol.det.Genus                      : chr  "" "" "" "" ...
##  $ vol.det.Species                    : chr  "" "" "" "" ...
##  $ vol.det.sex.caste                  : chr  "" "" "" "" ...
##  $ Determined.By                      : chr  "" "" "" "" ...
##  $ Date.Determined                    : logi  NA NA NA NA NA NA ...
##  $ Verified.By                        : logi  NA NA NA NA NA NA ...
##  $ Other.Determiner.s.                : chr  "" "" "" "" ...
##  $ Other.Dets.Sci..Name.s.            : logi  NA NA NA NA NA NA ...
##  $ Other.Dets..Date.s.                : logi  NA NA NA NA NA NA ...
##  $ Additional.Notes                   : chr  "" "" "" "" ...
##  $ X.1                                : logi  NA NA NA NA NA NA ...
```

The entire network would be difficult to visualize, so let's subset the data to just bumble bees. We need to extract only the columns that are relevant for the bee-plant interactions. The column "Associated.plant" has the floral species a bee was caught visiting, if it was caught on a flower.


``` r
bumbles <- oba[oba$Genus == "Bombus", ]
bumbles$GenusSpecies <-  paste(bumbles$Genus, bumbles$Species)
bumbles <- bumbles[, c("GenusSpecies", "Associated.plant")]
colnames(bumbles) <- c("GenusSpecies", "PlantGenusSpecies")
head(bumbles)
```

```
##           GenusSpecies PlantGenusSpecies
## 30   Bombus flavifrons     Ceanothus sp.
## 33  Bombus rufocinctus     Ceanothus sp.
## 34       Bombus mixtus     Ceanothus sp.
## 35       Bombus mixtus     Ceanothus sp.
## 88     Bombus fervidus  Camassia quamash
## 102    Bombus fervidus         Vicia sp.
```

There are a lot of blank rows from associated taxa for individuals not caught on a flower. We cannot do anything with those so we will just drop them. 


``` r
bumbles <- bumbles[bumbles$PlantGenusSpecies != "",]
sort(unique(bumbles$PlantGenusSpecies))
```

```
##   [1] "Acer circinatum"                                                                                                                                                                         
##   [2] "Acer macrophyllum"                                                                                                                                                                       
##   [3] "Achillea millefolium"                                                                                                                                                                    
##   [4] "Achillea sp."                                                                                                                                                                            
##   [5] "Aesculus hippocastanum"                                                                                                                                                                  
##   [6] "Agastache sp."                                                                                                                                                                           
##   [7] "Agastache urticifolia"                                                                                                                                                                   
##   [8] "Alcea biennis"                                                                                                                                                                           
##   [9] "Alcea rosea"                                                                                                                                                                             
##  [10] "Allium amplectens"                                                                                                                                                                       
##  [11] "Amelanchier alnifolia"                                                                                                                                                                   
##  [12] "Amsinckia menziesii"                                                                                                                                                                     
##  [13] "Angelica arguta"                                                                                                                                                                         
##  [14] "Apocynum sp."                                                                                                                                                                            
##  [15] "Aquilegia formosa"                                                                                                                                                                       
##  [16] "Aquilegia sp."                                                                                                                                                                           
##  [17] "Arctostaphylos densiflora"                                                                                                                                                               
##  [18] "Arnica cordifolia"                                                                                                                                                                       
##  [19] "Artemisia tridentata (tall sagebrush)"                                                                                                                                                   
##  [20] "Asclepias or Euphorbia spp."                                                                                                                                                             
##  [21] "Asclepias speciosa"                                                                                                                                                                      
##  [22] "Asparagus officinalis"                                                                                                                                                                   
##  [23] "Aster foliaceus"                                                                                                                                                                         
##  [24] "Asteraceae"                                                                                                                                                                              
##  [25] "Astragalus filipes"                                                                                                                                                                      
##  [26] "Balsamorhiza sp."                                                                                                                                                                        
##  [27] "Bellardia viscosa"                                                                                                                                                                       
##  [28] "Bellis perennis"                                                                                                                                                                         
##  [29] "Bellis sp."                                                                                                                                                                              
##  [30] "Berberis aquifolium"                                                                                                                                                                     
##  [31] "Betula sp."                                                                                                                                                                              
##  [32] "Boraginales"                                                                                                                                                                             
##  [33] "Borago officinalis"                                                                                                                                                                      
##  [34] "Brassica oleracea italica"                                                                                                                                                               
##  [35] "Brassica rapa"                                                                                                                                                                           
##  [36] "Brassica sp."                                                                                                                                                                            
##  [37] "Calochortus mariposa"                                                                                                                                                                    
##  [38] "Calystegia soldanella"                                                                                                                                                                   
##  [39] "Camassia quamash"                                                                                                                                                                        
##  [40] "Camassia sp."                                                                                                                                                                            
##  [41] "Castanea sp."                                                                                                                                                                            
##  [42] "Catalpa sp."                                                                                                                                                                             
##  [43] "Ceanothus cuneatus"                                                                                                                                                                      
##  [44] "Ceanothus sp."                                                                                                                                                                           
##  [45] "Ceanothus thyrsiflorus"                                                                                                                                                                  
##  [46] "Ceanothus velutinus"                                                                                                                                                                     
##  [47] "Centaurea cyanus"                                                                                                                                                                        
##  [48] "Centaurea maculosa"                                                                                                                                                                      
##  [49] "Centaurea sp."                                                                                                                                                                           
##  [50] "Chamaenerion angustifolium"                                                                                                                                                              
##  [51] "Chrysolepis chrysophylla"                                                                                                                                                                
##  [52] "Chrysothamnus nauseosus"                                                                                                                                                                 
##  [53] "Cirsium (thistle), Tanacetum vulgare (common tansy)"                                                                                                                                     
##  [54] "Cirsium arvense"                                                                                                                                                                         
##  [55] "Cirsium sp."                                                                                                                                                                             
##  [56] "Cirsium vulgare"                                                                                                                                                                         
##  [57] "Clarkia amoena"                                                                                                                                                                          
##  [58] "Cleome serrulata"                                                                                                                                                                        
##  [59] "Coreopsis sp."                                                                                                                                                                           
##  [60] "Crataegus"                                                                                                                                                                               
##  [61] "Cucurbita sp."                                                                                                                                                                           
##  [62] "Cynoglossum officinale"                                                                                                                                                                  
##  [63] "Dahlia sp."                                                                                                                                                                              
##  [64] "Daucus carota (Queen Anne\x92s lace), chicory, field bindweed, field pea and dandelion"                                                                                                  
##  [65] "Delphinium leucophaeum"                                                                                                                                                                  
##  [66] "Delphinium sp."                                                                                                                                                                          
##  [67] "Delphinium trolliifolium"                                                                                                                                                                
##  [68] "Descurainia sophia (Flixweed)"                                                                                                                                                           
##  [69] "Dicentra formosa"                                                                                                                                                                        
##  [70] "Digitalis purpurea"                                                                                                                                                                      
##  [71] "Dipsacus fullonum"                                                                                                                                                                       
##  [72] "Dipsacus fullonum (common teasel), Cirsium"                                                                                                                                              
##  [73] "Echinacea sp."                                                                                                                                                                           
##  [74] "Echinops sp."                                                                                                                                                                            
##  [75] "Epilobium angustifolium"                                                                                                                                                                 
##  [76] "Epilobium sp."                                                                                                                                                                           
##  [77] "Ericaceae"                                                                                                                                                                               
##  [78] "Ericameria linearifolia"                                                                                                                                                                 
##  [79] "Ericameria nauseosa"                                                                                                                                                                     
##  [80] "Ericameria sp."                                                                                                                                                                          
##  [81] "Eriogonum glaucus"                                                                                                                                                                       
##  [82] "Eriogonum sp."                                                                                                                                                                           
##  [83] "Eriophyllum confertiflorum"                                                                                                                                                              
##  [84] "Eriophyllum lanatum"                                                                                                                                                                     
##  [85] "Eriophyllum sp."                                                                                                                                                                         
##  [86] "Eschscholzia californica"                                                                                                                                                                
##  [87] "Euonymus occidentalis"                                                                                                                                                                   
##  [88] "Euphorbia esula"                                                                                                                                                                         
##  [89] "Fagopyrum sp."                                                                                                                                                                           
##  [90] "Fragaria chiloensis"                                                                                                                                                                     
##  [91] "Gaillardia sp."                                                                                                                                                                          
##  [92] "Geranium oreganum"                                                                                                                                                                       
##  [93] "Geranium sp."                                                                                                                                                                            
##  [94] "Gilia capitata"                                                                                                                                                                          
##  [95] "Grindelia stricta stricta"                                                                                                                                                               
##  [96] "Hackelia micrantha"                                                                                                                                                                      
##  [97] "Helenium autumnale"                                                                                                                                                                      
##  [98] "Helianthus annuus"                                                                                                                                                                       
##  [99] "Helianthus sp."                                                                                                                                                                          
## [100] "Heliopsis helianthoides"                                                                                                                                                                 
## [101] "Heracleum maximum"                                                                                                                                                                       
## [102] "Heracleum sphondylium"                                                                                                                                                                   
## [103] "Heuchera sp."                                                                                                                                                                            
## [104] "Holodiscus dumosus"                                                                                                                                                                      
## [105] "Horkelia fusca"                                                                                                                                                                          
## [106] "Hydrophyllum sp."                                                                                                                                                                        
## [107] "Hypericum sp."                                                                                                                                                                           
## [108] "Iliamna rivularis"                                                                                                                                                                       
## [109] "Kalmia polifolia"                                                                                                                                                                        
## [110] "Lathyrus hirsutus"                                                                                                                                                                       
## [111] "Lathyrus japonicus var. maritimus"                                                                                                                                                       
## [112] "Lavandula angustifolia"                                                                                                                                                                  
## [113] "Leucanthemum vulgare"                                                                                                                                                                    
## [114] "Leucanthemum vulgare, Iris tenax, Prunella vulgaris, Digitalis purpurea"                                                                                                                 
## [115] "Lithospermum ruderale"                                                                                                                                                                   
## [116] "Lonicera caerulea"                                                                                                                                                                       
## [117] "Lonicera involucrata"                                                                                                                                                                    
## [118] "Lupinus argenteus argenteus"                                                                                                                                                             
## [119] "Lupinus lepidus"                                                                                                                                                                         
## [120] "Lupinus littoralis"                                                                                                                                                                      
## [121] "Lupinus rivularis"                                                                                                                                                                       
## [122] "Lupinus sericeus (silky lupine)"                                                                                                                                                         
## [123] "Lupinus sp."                                                                                                                                                                             
## [124] "Mahonia aquifolium"                                                                                                                                                                      
## [125] "Malus pumila "                                                                                                                                                                           
## [126] "Medicago sativa"                                                                                                                                                                         
## [127] "Melilotus alba (sweet clover) and thistle"                                                                                                                                               
## [128] "Melilotus albus"                                                                                                                                                                         
## [129] "Microseris nutans"                                                                                                                                                                       
## [130] "Mimulus guttatus"                                                                                                                                                                        
## [131] "Mimulus lewisii"                                                                                                                                                                         
## [132] "Mimulus sp."                                                                                                                                                                             
## [133] "Monardella odoratissima"                                                                                                                                                                 
## [134] "Nepeta cataria"                                                                                                                                                                          
## [135] "Nepeta grandiflora"                                                                                                                                                                      
## [136] "Nepeta sp."                                                                                                                                                                              
## [137] "Net"                                                                                                                                                                                     
## [138] "Oenanthe sarmentosa"                                                                                                                                                                     
## [139] "Oenothera biennis"                                                                                                                                                                       
## [140] "Origanum vulgare"                                                                                                                                                                        
## [141] "Penstemon deustus"                                                                                                                                                                       
## [142] "Penstemon ovatus"                                                                                                                                                                        
## [143] "Penstemon procerus"                                                                                                                                                                      
## [144] "Penstemon sp."                                                                                                                                                                           
## [145] "Penstemon spectabilis"                                                                                                                                                                   
## [146] "Perovskia atriplicifolia"                                                                                                                                                                
## [147] "Phacelia hastata"                                                                                                                                                                        
## [148] "Phacelia heterophylla"                                                                                                                                                                   
## [149] "Phacelia sp."                                                                                                                                                                            
## [150] "Phacelia tanacetifolia"                                                                                                                                                                  
## [151] "Physocarpus capitatus"                                                                                                                                                                   
## [152] "Physocarpus capitatus (pacific ninebark)"                                                                                                                                                
## [153] "Physocarpus sp."                                                                                                                                                                         
## [154] "Plagiobothrys figuratus"                                                                                                                                                                 
## [155] "Poison hemlock and Steens Mtn thistle"                                                                                                                                                   
## [156] "Potentilla gracilis"                                                                                                                                                                     
## [157] "Prunella vulgaris"                                                                                                                                                                       
## [158] "Prunella vulgaris (self-heal)"                                                                                                                                                           
## [159] "Prunus avium"                                                                                                                                                                            
## [160] "Prunus laurocerasus"                                                                                                                                                                     
## [161] "Purple monkey flower, wyethia, yarrow, epilobium"                                                                                                                                        
## [162] "Ranunculus occidentalis"                                                                                                                                                                 
## [163] "Raphanus sativus"                                                                                                                                                                        
## [164] "Raphanus sp."                                                                                                                                                                            
## [165] "Rhododendron macrophyllum"                                                                                                                                                               
## [166] "Rhododendron maximum"                                                                                                                                                                    
## [167] "Rhododendron sp."                                                                                                                                                                        
## [168] "Rhododendron x"                                                                                                                                                                          
## [169] "Ribes aureum"                                                                                                                                                                            
## [170] "Ribes cereum"                                                                                                                                                                            
## [171] "Ribes cereum (wax currant)"                                                                                                                                                              
## [172] "Ribes rubrum"                                                                                                                                                                            
## [173] "Ribes sanguineum"                                                                                                                                                                        
## [174] "Robinia pseudoacacia"                                                                                                                                                                    
## [175] "Rosa gymnocarpa"                                                                                                                                                                         
## [176] "Rosa nutkana"                                                                                                                                                                            
## [177] "Rosa nutkana (Nootka rose)"                                                                                                                                                              
## [178] "Rosa sp."                                                                                                                                                                                
## [179] "Rosa woodsii"                                                                                                                                                                            
## [180] "Rosaceae"                                                                                                                                                                                
## [181] "Rosmarinus officinalis"                                                                                                                                                                  
## [182] "Rubus armeniacus"                                                                                                                                                                        
## [183] "Rubus bifrons"                                                                                                                                                                           
## [184] "Rubus discolor (Himalayan blackberry)"                                                                                                                                                   
## [185] "Rubus fruticosus"                                                                                                                                                                        
## [186] "Rubus idaeus"                                                                                                                                                                            
## [187] "Rubus parviflorus"                                                                                                                                                                       
## [188] "Rubus parviflorus (Thimbleberry)"                                                                                                                                                        
## [189] "Rubus sp."                                                                                                                                                                               
## [190] "Rubus ursinus"                                                                                                                                                                           
## [191] "Salix lasiandra"                                                                                                                                                                         
## [192] "Salvia officinalis"                                                                                                                                                                      
## [193] "Salvia pratensis"                                                                                                                                                                        
## [194] "Scutellaria integrifolia"                                                                                                                                                                
## [195] "Senecio hydrophilus"                                                                                                                                                                     
## [196] "Senecio sp."                                                                                                                                                                             
## [197] "Sidalacea campestris (field checker mallow), Eschscholzia californica (California poppy), Clarkia amoena (farewell to spring), tarweed"                                                  
## [198] "Sidalcea campestris"                                                                                                                                                                     
## [199] "Sidalcea nelsoniana"                                                                                                                                                                     
## [200] "Sidalcea oregana"                                                                                                                                                                        
## [201] "Sidalcea sp."                                                                                                                                                                            
## [202] "Solanum sp."                                                                                                                                                                             
## [203] "Solidago canadensis"                                                                                                                                                                     
## [204] "Solidago elongata"                                                                                                                                                                       
## [205] "Solidago sp."                                                                                                                                                                            
## [206] "Sorbus aucuparia"                                                                                                                                                                        
## [207] "Sphenosciadium capitellatum (swamp white heads), Aster occidentalis, Ca hellebore"                                                                                                       
## [208] "Spiraea douglasii"                                                                                                                                                                       
## [209] "Spiraea japonica"                                                                                                                                                                        
## [210] "Spiraea sp."                                                                                                                                                                             
## [211] "Stachys byzantina"                                                                                                                                                                       
## [212] "Stachys chamissonis"                                                                                                                                                                     
## [213] "Styrax japonicus"                                                                                                                                                                        
## [214] "Symphoricarpos alba (snowberry)"                                                                                                                                                         
## [215] "Symphoricarpos albus"                                                                                                                                                                    
## [216] "Symphoricarpos rotundifolius"                                                                                                                                                            
## [217] "Symphoricarpos sp."                                                                                                                                                                      
## [218] "Symphytum sp."                                                                                                                                                                           
## [219] "Syringa sp."                                                                                                                                                                             
## [220] "Tanacetum vulgare (common tansy), Epilobium densiflorum (dense-flowered willowherb), Epilobium brachycarpum (tall annual willowherb), Grindelia integrifolia (Willamette valley gumweed)"
## [221] "Taraxacum officinale"                                                                                                                                                                    
## [222] "Tellima grandiflora"                                                                                                                                                                     
## [223] "Thelypodium sp."                                                                                                                                                                         
## [224] "Thermopsis rhombifolia"                                                                                                                                                                  
## [225] "Tithonia sp."                                                                                                                                                                            
## [226] "Tonella floribunda"                                                                                                                                                                      
## [227] "Tradescantia sp."                                                                                                                                                                        
## [228] "Trifolium incarnatum"                                                                                                                                                                    
## [229] "Trifolium sp."                                                                                                                                                                           
## [230] "Vaccinium ovatum"                                                                                                                                                                        
## [231] "Vaccinium sp."                                                                                                                                                                           
## [232] "Verbascum thapsus"                                                                                                                                                                       
## [233] "Veronica scutellata"                                                                                                                                                                     
## [234] "Viburnum davidii"                                                                                                                                                                        
## [235] "Vicia americana"                                                                                                                                                                         
## [236] "Vicia cracca"                                                                                                                                                                            
## [237] "Vicia cracca (tufted vetch)"                                                                                                                                                             
## [238] "Vicia sativa"                                                                                                                                                                            
## [239] "Vicia sp."                                                                                                                                                                               
## [240] "Vicia villosa"                                                                                                                                                                           
## [241] "Whipplea modesta"                                                                                                                                                                        
## [242] "Wisteria sp."                                                                                                                                                                            
## [243] "Wyethia amplexicaulis"                                                                                                                                                                   
## [244] "Wyethia angustifolia"                                                                                                                                                                    
## [245] "Wyethia mollis"                                                                                                                                                                          
## [246] "Wyethia sp."
```

Ugg, there are a lot of weird name add ones that will cause inconsistencies when we make the network because any unique name will be considered a unique node. Next week we will learn how to clean these out using regular expressions. For these week we will just drop them...


``` r
really.bad.plant.name <- "Daucus carota (Queen Anne\x92s lace), chicory, field bindweed, field pea and dandelion"
bumbles <- bumbles[bumbles$PlantGenusSpecies != really.bad.plant.name,]
bad.plant.names <- grepl("\\(|,", bumbles$PlantGenusSpecies)

bumbles <- bumbles[!bad.plant.names,]
```


We can explore the species in our network. These will be the vertices. 

``` r
table(bumbles$GenusSpecies)
```

```
## 
##               Bombus       Bombus appositus       Bombus bifarius 
##                     1                     6                    93 
##    Bombus caliginosus      Bombus centralis       Bombus fervidus 
##                    44                    80                    78 
##       Bombus flavidus     Bombus flavifrons   Bombus griseocollis 
##                     2                    47                    29 
##         Bombus huntii      Bombus insularis    Bombus melanopygus 
##                    56                     5                    47 
##         Bombus mixtus      Bombus morrisoni     Bombus nevadensis 
##                   119                    16                    15 
##   Bombus occidentalis    Bombus rufocinctus      Bombus sitkensis 
##                     4                    15                     3 
##      Bombus sylvicola         Bombus vagans Bombus vancouverensis 
##                     1                     1                     5 
##       Bombus vandykei   Bombus vosnesenskii 
##                    40                   264
```

``` r
table(bumbles$PlantGenusSpecies)
```

```
## 
##                       Acer circinatum                     Acer macrophyllum 
##                                     1                                     1 
##                  Achillea millefolium                          Achillea sp. 
##                                     6                                     2 
##                Aesculus hippocastanum                         Agastache sp. 
##                                     2                                     5 
##                 Agastache urticifolia                         Alcea biennis 
##                                     1                                     1 
##                           Alcea rosea                     Allium amplectens 
##                                     3                                     1 
##                 Amelanchier alnifolia                   Amsinckia menziesii 
##                                     1                                     2 
##                       Angelica arguta                          Apocynum sp. 
##                                     1                                     1 
##                     Aquilegia formosa                         Aquilegia sp. 
##                                     2                                     2 
##             Arctostaphylos densiflora                     Arnica cordifolia 
##                                     2                                     1 
##           Asclepias or Euphorbia spp.                    Asclepias speciosa 
##                                     1                                     6 
##                 Asparagus officinalis                       Aster foliaceus 
##                                     2                                     1 
##                            Asteraceae                    Astragalus filipes 
##                                     3                                     1 
##                      Balsamorhiza sp.                     Bellardia viscosa 
##                                     1                                     2 
##                       Bellis perennis                            Bellis sp. 
##                                     1                                     3 
##                   Berberis aquifolium                            Betula sp. 
##                                     5                                     1 
##                           Boraginales                    Borago officinalis 
##                                     1                                     1 
##             Brassica oleracea italica                         Brassica rapa 
##                                     1                                     4 
##                          Brassica sp.                  Calochortus mariposa 
##                                     2                                     1 
##                 Calystegia soldanella                      Camassia quamash 
##                                     3                                     1 
##                          Camassia sp.                          Castanea sp. 
##                                     5                                     1 
##                           Catalpa sp.                    Ceanothus cuneatus 
##                                     1                                     1 
##                         Ceanothus sp.                Ceanothus thyrsiflorus 
##                                    16                                    28 
##                   Ceanothus velutinus                      Centaurea cyanus 
##                                    10                                     2 
##                    Centaurea maculosa                         Centaurea sp. 
##                                     2                                     2 
##            Chamaenerion angustifolium              Chrysolepis chrysophylla 
##                                    15                                     2 
##               Chrysothamnus nauseosus                       Cirsium arvense 
##                                     8                                     7 
##                           Cirsium sp.                       Cirsium vulgare 
##                                     3                                     5 
##                        Clarkia amoena                      Cleome serrulata 
##                                     2                                     5 
##                         Coreopsis sp.                             Crataegus 
##                                     1                                     1 
##                         Cucurbita sp.                Cynoglossum officinale 
##                                     1                                     2 
##                            Dahlia sp.                Delphinium leucophaeum 
##                                     1                                     2 
##                        Delphinium sp.              Delphinium trolliifolium 
##                                     6                                     3 
##                      Dicentra formosa                    Digitalis purpurea 
##                                     1                                     4 
##                     Dipsacus fullonum                         Echinacea sp. 
##                                     8                                     1 
##                          Echinops sp.               Epilobium angustifolium 
##                                     3                                     3 
##                         Epilobium sp.                             Ericaceae 
##                                     1                                     1 
##               Ericameria linearifolia                   Ericameria nauseosa 
##                                    30                                    12 
##                        Ericameria sp.                     Eriogonum glaucus 
##                                     7                                     1 
##                         Eriogonum sp.            Eriophyllum confertiflorum 
##                                     1                                     1 
##                   Eriophyllum lanatum                       Eriophyllum sp. 
##                                     1                                     1 
##              Eschscholzia californica                 Euonymus occidentalis 
##                                    22                                     5 
##                       Euphorbia esula                         Fagopyrum sp. 
##                                     1                                     1 
##                   Fragaria chiloensis                        Gaillardia sp. 
##                                     3                                     7 
##                     Geranium oreganum                          Geranium sp. 
##                                     3                                     8 
##                        Gilia capitata             Grindelia stricta stricta 
##                                     1                                    17 
##                    Hackelia micrantha                    Helenium autumnale 
##                                     4                                     1 
##                     Helianthus annuus                        Helianthus sp. 
##                                     5                                     1 
##               Heliopsis helianthoides                     Heracleum maximum 
##                                     1                                     3 
##                 Heracleum sphondylium                          Heuchera sp. 
##                                     1                                     4 
##                    Holodiscus dumosus                        Horkelia fusca 
##                                     2                                     1 
##                      Hydrophyllum sp.                         Hypericum sp. 
##                                     1                                     1 
##                     Iliamna rivularis                      Kalmia polifolia 
##                                     1                                     1 
##                     Lathyrus hirsutus     Lathyrus japonicus var. maritimus 
##                                     1                                     2 
##                Lavandula angustifolia                  Leucanthemum vulgare 
##                                     6                                     1 
##                 Lithospermum ruderale                     Lonicera caerulea 
##                                     5                                     3 
##                  Lonicera involucrata           Lupinus argenteus argenteus 
##                                     3                                     1 
##                       Lupinus lepidus                    Lupinus littoralis 
##                                     9                                     6 
##                     Lupinus rivularis                           Lupinus sp. 
##                                     4                                    13 
##                    Mahonia aquifolium                         Malus pumila  
##                                     2                                     4 
##                       Medicago sativa                       Melilotus albus 
##                                     1                                     2 
##                     Microseris nutans                      Mimulus guttatus 
##                                     1                                     1 
##                       Mimulus lewisii                           Mimulus sp. 
##                                     4                                     6 
##               Monardella odoratissima                        Nepeta cataria 
##                                     4                                     9 
##                    Nepeta grandiflora                            Nepeta sp. 
##                                     6                                    12 
##                                   Net                   Oenanthe sarmentosa 
##                                     1                                     1 
##                     Oenothera biennis                      Origanum vulgare 
##                                     1                                     1 
##                     Penstemon deustus                      Penstemon ovatus 
##                                    15                                     1 
##                    Penstemon procerus                         Penstemon sp. 
##                                     9                                     3 
##                 Penstemon spectabilis              Perovskia atriplicifolia 
##                                     3                                     9 
##                      Phacelia hastata                 Phacelia heterophylla 
##                                    17                                     3 
##                          Phacelia sp.                Phacelia tanacetifolia 
##                                    20                                    15 
##                 Physocarpus capitatus                       Physocarpus sp. 
##                                     1                                     4 
##               Plagiobothrys figuratus Poison hemlock and Steens Mtn thistle 
##                                     2                                     2 
##                   Potentilla gracilis                     Prunella vulgaris 
##                                     1                                     3 
##                          Prunus avium                   Prunus laurocerasus 
##                                     1                                     1 
##               Ranunculus occidentalis                      Raphanus sativus 
##                                     2                                     1 
##                          Raphanus sp.             Rhododendron macrophyllum 
##                                    11                                     9 
##                  Rhododendron maximum                      Rhododendron sp. 
##                                     5                                     1 
##                        Rhododendron x                          Ribes aureum 
##                                     6                                     1 
##                          Ribes cereum                          Ribes rubrum 
##                                     8                                     1 
##                      Ribes sanguineum                  Robinia pseudoacacia 
##                                     1                                     9 
##                       Rosa gymnocarpa                          Rosa nutkana 
##                                     1                                     2 
##                              Rosa sp.                          Rosa woodsii 
##                                    13                                    17 
##                              Rosaceae                Rosmarinus officinalis 
##                                     2                                     1 
##                      Rubus armeniacus                         Rubus bifrons 
##                                     9                                    13 
##                      Rubus fruticosus                          Rubus idaeus 
##                                     2                                     9 
##                     Rubus parviflorus                             Rubus sp. 
##                                     7                                     5 
##                         Rubus ursinus                       Salix lasiandra 
##                                     4                                     1 
##                    Salvia officinalis                      Salvia pratensis 
##                                     1                                     2 
##              Scutellaria integrifolia                   Senecio hydrophilus 
##                                     2                                     2 
##                           Senecio sp.                   Sidalcea campestris 
##                                     4                                     3 
##                   Sidalcea nelsoniana                      Sidalcea oregana 
##                                     3                                     7 
##                          Sidalcea sp.                           Solanum sp. 
##                                     3                                     1 
##                   Solidago canadensis                     Solidago elongata 
##                                    10                                     2 
##                          Solidago sp.                      Sorbus aucuparia 
##                                     2                                     1 
##                     Spiraea douglasii                      Spiraea japonica 
##                                    15                                     2 
##                           Spiraea sp.                     Stachys byzantina 
##                                    22                                     3 
##                   Stachys chamissonis                      Styrax japonicus 
##                                     2                                    10 
##                  Symphoricarpos albus          Symphoricarpos rotundifolius 
##                                    26                                     5 
##                    Symphoricarpos sp.                         Symphytum sp. 
##                                     6                                     1 
##                           Syringa sp.                  Taraxacum officinale 
##                                     2                                     2 
##                   Tellima grandiflora                       Thelypodium sp. 
##                                     6                                     6 
##                Thermopsis rhombifolia                          Tithonia sp. 
##                                     7                                     2 
##                    Tonella floribunda                      Tradescantia sp. 
##                                     4                                     1 
##                  Trifolium incarnatum                         Trifolium sp. 
##                                     3                                     3 
##                      Vaccinium ovatum                         Vaccinium sp. 
##                                     5                                     3 
##                     Verbascum thapsus                   Veronica scutellata 
##                                     1                                     1 
##                      Viburnum davidii                       Vicia americana 
##                                     1                                     4 
##                          Vicia cracca                          Vicia sativa 
##                                     3                                     4 
##                             Vicia sp.                         Vicia villosa 
##                                    20                                     2 
##                      Whipplea modesta                          Wisteria sp. 
##                                     2                                     2 
##                 Wyethia amplexicaulis                  Wyethia angustifolia 
##                                     2                                     1 
##                        Wyethia mollis                           Wyethia sp. 
##                                     1                                     8
```
We have a variety of options for converting of data (which is basically an edge list) into a graph. One is to sum up our interactions but bee-plant combinations to make an bipartite adjacency matrix. Then convert that matrix to a igraph object. 


``` r
### 1. sum up interactions and take a look
bumbles_adj <- table(bumbles)
### write to a file
save(bumbles_adj, file="bumbles_adj_mat.Rdata")
dim(bumbles_adj)
```

```
## [1]  23 226
```

``` r
bumbles_adj[1:5, 1:5] 
```

```
##                     PlantGenusSpecies
## GenusSpecies         Acer circinatum Acer macrophyllum Achillea millefolium
##   Bombus                           0                 0                    0
##   Bombus appositus                 0                 0                    0
##   Bombus bifarius                  0                 0                    1
##   Bombus caliginosus               0                 0                    0
##   Bombus centralis                 0                 0                    0
##                     PlantGenusSpecies
## GenusSpecies         Achillea sp. Aesculus hippocastanum
##   Bombus                        0                      0
##   Bombus appositus              0                      0
##   Bombus bifarius               0                      0
##   Bombus caliginosus            0                      2
##   Bombus centralis              0                      0
```


``` r
### 2. convert to igraph bipartite adjacency matrix 
g_bumbles <- graph_from_biadjacency_matrix(bumbles_adj, 
                                           weighted =TRUE) 
g_bumbles
```

```
## IGRAPH 5fa8854 UNWB 249 481 -- 
## + attr: type (v/l), name (v/c), weight (e/n)
## + edges from 5fa8854 (vertex names):
##  [1] Bombus          --Styrax japonicus     
##  [2] Bombus appositus--Bellardia viscosa    
##  [3] Bombus appositus--Rubus armeniacus     
##  [4] Bombus appositus--Rubus parviflorus    
##  [5] Bombus appositus--Symphoricarpos albus 
##  [6] Bombus appositus--Wyethia angustifolia 
##  [7] Bombus bifarius --Achillea millefolium 
##  [8] Bombus bifarius --Agastache urticifolia
## + ... omitted several edges
```

To use the 'forceNetwork' function we did for Le Mis, we need to convert our graph into a dataframe. Luckily there is a function 'igraph_to_networkD3' to convert from graph objects to what the network3d package wants. That function also wants a each vertex assigned to a group. We have a variety of options on how to assign groups, one is to look for modules or compartments in the network. 


``` r
### find modules
mod_bumbles <- cluster_walktrap(g_bumbles)
### assign vertices to modules
groups <- membership(mod_bumbles)

### convert to a network 3d object
g_bumbles_net3d <- igraph_to_networkD3(g_bumbles, group=groups, 
                                       what = "both")
### plot the bumble-plant network
forceNetwork(Links = g_bumbles_net3d$links,
             Nodes = g_bumbles_net3d$nodes,
            Source = "source", Target = "target",
            Value = "value",  NodeID = "name",
             Group = "group", 
            opacity = 0.8, zoom=TRUE, opacityNoHover = 0.9)
```

```{=html}
<div class="forceNetwork html-widget html-fill-item" id="htmlwidget-636dd6300104ca33ae03" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-636dd6300104ca33ae03">{"x":{"links":{"source":[12,22,22,2,12,3,5,22,2,21,4,22,22,22,3,2,8,12,22,8,5,22,2,22,8,5,3,22,2,2,4,21,1,5,22,22,12,4,15,9,22,12,22,12,9,12,22,12,3,2,5,11,5,11,4,12,12,9,12,16,3,12,22,7,11,17,11,12,3,22,22,9,2,4,22,21,13,4,20,22,2,4,12,3,22,2,22,4,22,2,5,9,5,5,14,9,13,22,8,13,8,22,9,4,22,5,7,14,21,5,5,22,5,12,22,12,5,7,22,21,22,9,4,3,22,22,15,2,22,9,9,22,13,9,22,20,12,7,22,22,12,11,22,12,22,2,10,22,12,22,4,11,12,22,2,21,4,16,3,22,11,5,12,12,4,2,11,8,22,9,22,22,7,17,7,11,22,3,13,22,2,4,3,4,11,5,5,22,7,21,22,5,21,4,4,5,22,12,2,2,22,22,12,5,12,22,3,12,4,2,9,22,21,12,22,11,9,22,21,10,12,2,9,2,4,16,2,18,13,22,8,11,9,5,22,7,12,11,22,16,7,5,12,3,22,16,7,14,4,19,5,7,12,2,7,22,2,9,2,12,21,22,9,22,2,21,4,12,2,3,7,22,21,9,4,13,8,12,22,3,12,12,8,3,22,2,5,2,3,5,7,22,16,17,11,22,8,5,22,3,3,22,8,11,7,12,12,11,22,7,3,12,11,22,22,21,9,3,3,7,4,14,12,11,5,21,12,22,13,3,12,22,9,14,4,16,5,22,22,11,3,1,12,22,22,11,12,12,12,2,6,1,22,12,15,7,16,11,12,3,6,7,12,22,13,5,5,2,10,4,2,22,7,22,5,2,4,10,5,12,2,12,22,4,8,10,20,20,11,22,11,8,9,13,2,12,9,12,22,14,22,16,12,0,12,22,7,16,1,7,22,5,12,11,4,5,2,14,4,7,2,16,11,22,13,11,22,5,13,9,22,5,13,9,22,2,12,4,22,14,9,2,22,5,11,22,3,22,12,5,22,5,14,21,5,22,3,9,21,3,21,5,9,8,14,3,9,22,22,16,11,8,4,2,1,4,22,5,7,4,11],"target":[23,24,25,25,26,27,28,28,29,30,31,32,33,34,34,35,36,37,37,38,38,39,40,41,42,42,43,43,44,45,46,47,48,48,49,50,50,51,51,51,51,51,52,53,54,55,56,56,57,58,59,59,60,61,61,61,62,63,64,65,65,65,65,65,65,66,66,66,66,66,67,67,67,68,68,69,69,70,71,71,71,71,71,71,72,72,73,74,74,74,75,76,76,77,77,78,78,78,78,79,80,81,82,82,83,84,84,85,85,85,86,87,88,88,89,89,89,89,90,91,91,91,92,92,93,94,95,95,95,95,96,96,96,97,97,98,99,100,101,102,103,103,103,104,104,105,106,107,107,108,108,109,109,110,110,110,110,111,112,112,112,112,112,113,113,113,114,115,115,115,116,117,118,118,119,120,120,120,121,121,122,123,124,125,126,127,128,128,129,129,129,130,131,131,132,132,132,133,134,135,135,136,136,137,137,137,138,138,138,138,138,139,139,140,140,140,141,142,142,143,144,145,145,146,146,147,147,147,148,148,148,148,148,148,149,149,150,150,150,150,150,151,152,153,154,155,155,155,155,155,155,156,157,157,157,158,158,158,159,159,160,160,161,161,161,161,161,161,162,162,163,163,163,163,163,164,164,164,164,164,165,166,166,166,167,168,168,169,170,170,170,171,172,173,173,174,175,175,175,175,176,176,176,176,176,176,177,177,178,179,179,179,179,180,181,181,181,182,183,184,184,184,185,186,186,187,187,187,187,187,188,188,188,188,188,188,189,189,190,191,191,191,191,191,192,192,192,193,194,194,194,195,195,195,195,196,196,196,196,196,197,197,197,198,199,200,201,202,202,203,203,204,205,205,206,206,206,206,207,207,208,209,209,209,209,210,210,211,212,213,213,213,213,213,213,214,215,215,215,216,216,216,217,218,218,218,218,218,219,219,219,219,219,219,220,220,220,220,221,221,221,222,223,224,224,225,225,225,226,226,226,227,227,227,228,229,229,229,230,231,231,232,232,232,233,233,233,234,234,235,236,237,238,238,238,239,239,240,240,240,241,241,241,241,241,241,242,242,243,243,244,244,245,245,246,247,248,248,248,248,248],"value":[1,1,5,1,2,2,2,3,1,1,3,1,1,1,1,1,1,1,1,1,1,2,1,1,5,1,1,1,1,3,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,2,2,2,1,2,1,1,1,1,3,1,1,1,1,2,3,5,1,4,1,5,8,4,10,8,1,1,1,1,1,1,2,1,1,3,6,3,1,1,1,8,2,1,4,3,3,2,1,1,1,1,1,2,1,1,1,1,1,1,1,1,2,1,3,3,1,2,2,2,1,1,4,1,1,1,1,2,1,1,1,2,24,3,1,7,3,2,4,3,1,1,1,1,1,1,1,20,1,4,1,1,1,2,5,2,2,1,1,2,1,4,1,1,2,1,4,9,1,1,2,1,1,3,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,3,2,1,1,4,1,1,1,3,1,5,4,5,1,1,2,1,4,2,3,3,1,1,1,2,1,1,1,1,1,1,1,3,1,2,4,2,1,1,2,1,1,1,2,2,1,5,2,1,4,1,4,1,1,1,1,1,5,2,2,1,4,1,3,5,1,1,1,1,2,1,6,3,1,1,1,11,1,2,1,2,1,2,4,1,12,2,9,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,6,3,1,1,3,1,2,1,1,2,3,1,3,1,1,1,1,4,1,3,1,1,4,2,3,1,1,1,1,1,9,1,1,1,1,3,1,8,3,1,1,1,3,1,1,3,1,6,4,3,2,6,2,1,1,1,4,1,1,1,1,1,1,1,1,2,1,1,2,2,1,1,1,3,3,1,2,1,3,2,1,1,2,1,1,7,1,1,1,1,2,1,7,1,2,3,1,1,2,2,3,17,1,1,1,2,1,2,2,4,1,2,1,16,1,4,2,1,1,2,1,3,1,2,1,2,1,1,1,4,1,1,3,2,4,1,2,2,1,1,2,1,2,1,1,1,1,1,1,3,1,2,1,1,1,1,1,2,1,2,2,1,1,3,8,5,1,1,2,1,1,1,1,1,1,1,1,1,1,2,2,1,2,1],"colour":["#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666","#666"]},"nodes":{"name":["Bombus ","Bombus appositus","Bombus bifarius","Bombus caliginosus","Bombus centralis","Bombus fervidus","Bombus flavidus","Bombus flavifrons","Bombus griseocollis","Bombus huntii","Bombus insularis","Bombus melanopygus","Bombus mixtus","Bombus morrisoni","Bombus nevadensis","Bombus occidentalis","Bombus rufocinctus","Bombus sitkensis","Bombus sylvicola","Bombus vagans","Bombus vancouverensis","Bombus vandykei","Bombus vosnesenskii","Acer circinatum","Acer macrophyllum","Achillea millefolium","Achillea sp.","Aesculus hippocastanum","Agastache sp.","Agastache urticifolia","Alcea biennis","Alcea rosea","Allium amplectens","Amelanchier alnifolia","Amsinckia menziesii","Angelica arguta","Apocynum sp.","Aquilegia formosa","Aquilegia sp.","Arctostaphylos densiflora","Arnica cordifolia","Asclepias or Euphorbia spp.","Asclepias speciosa","Asparagus officinalis","Aster foliaceus","Asteraceae","Astragalus filipes","Balsamorhiza sp.","Bellardia viscosa","Bellis perennis","Bellis sp.","Berberis aquifolium","Betula sp.","Boraginales","Borago officinalis","Brassica oleracea italica","Brassica rapa","Brassica sp.","Calochortus mariposa","Calystegia soldanella","Camassia quamash","Camassia sp.","Castanea sp.","Catalpa sp.","Ceanothus cuneatus","Ceanothus sp.","Ceanothus thyrsiflorus","Ceanothus velutinus","Centaurea cyanus","Centaurea maculosa","Centaurea sp.","Chamaenerion angustifolium","Chrysolepis chrysophylla","Chrysothamnus nauseosus","Cirsium arvense","Cirsium sp.","Cirsium vulgare","Clarkia amoena","Cleome serrulata","Coreopsis sp.","Crataegus","Cucurbita sp.","Cynoglossum officinale","Dahlia sp.","Delphinium leucophaeum","Delphinium sp.","Delphinium trolliifolium","Dicentra formosa","Digitalis purpurea","Dipsacus fullonum","Echinacea sp.","Echinops sp.","Epilobium angustifolium","Epilobium sp.","Ericaceae","Ericameria linearifolia","Ericameria nauseosa","Ericameria sp.","Eriogonum glaucus","Eriogonum sp.","Eriophyllum confertiflorum","Eriophyllum lanatum","Eriophyllum sp.","Eschscholzia californica","Euonymus occidentalis","Euphorbia esula","Fagopyrum sp.","Fragaria chiloensis","Gaillardia sp.","Geranium oreganum","Geranium sp.","Gilia capitata","Grindelia stricta stricta","Hackelia micrantha","Helenium autumnale","Helianthus annuus","Helianthus sp.","Heliopsis helianthoides","Heracleum maximum","Heracleum sphondylium","Heuchera sp.","Holodiscus dumosus","Horkelia fusca","Hydrophyllum sp.","Hypericum sp.","Iliamna rivularis","Kalmia polifolia","Lathyrus hirsutus","Lathyrus japonicus var. maritimus","Lavandula angustifolia","Leucanthemum vulgare","Lithospermum ruderale","Lonicera caerulea","Lonicera involucrata","Lupinus argenteus argenteus","Lupinus lepidus","Lupinus littoralis","Lupinus rivularis","Lupinus sp.","Mahonia aquifolium","Malus pumila ","Medicago sativa","Melilotus albus","Microseris nutans","Mimulus guttatus","Mimulus lewisii","Mimulus sp.","Monardella odoratissima","Nepeta cataria","Nepeta grandiflora","Nepeta sp.","Net","Oenanthe sarmentosa","Oenothera biennis","Origanum vulgare","Penstemon deustus","Penstemon ovatus","Penstemon procerus","Penstemon sp.","Penstemon spectabilis","Perovskia atriplicifolia","Phacelia hastata","Phacelia heterophylla","Phacelia sp.","Phacelia tanacetifolia","Physocarpus capitatus","Physocarpus sp.","Plagiobothrys figuratus","Poison hemlock and Steens Mtn thistle","Potentilla gracilis","Prunella vulgaris","Prunus avium","Prunus laurocerasus","Ranunculus occidentalis","Raphanus sativus","Raphanus sp.","Rhododendron macrophyllum","Rhododendron maximum","Rhododendron sp.","Rhododendron x","Ribes aureum","Ribes cereum","Ribes rubrum","Ribes sanguineum","Robinia pseudoacacia","Rosa gymnocarpa","Rosa nutkana","Rosa sp.","Rosa woodsii","Rosaceae","Rosmarinus officinalis","Rubus armeniacus","Rubus bifrons","Rubus fruticosus","Rubus idaeus","Rubus parviflorus","Rubus sp.","Rubus ursinus","Salix lasiandra","Salvia officinalis","Salvia pratensis","Scutellaria integrifolia","Senecio hydrophilus","Senecio sp.","Sidalcea campestris","Sidalcea nelsoniana","Sidalcea oregana","Sidalcea sp.","Solanum sp.","Solidago canadensis","Solidago elongata","Solidago sp.","Sorbus aucuparia","Spiraea douglasii","Spiraea japonica","Spiraea sp.","Stachys byzantina","Stachys chamissonis","Styrax japonicus","Symphoricarpos albus","Symphoricarpos rotundifolius","Symphoricarpos sp.","Symphytum sp.","Syringa sp.","Taraxacum officinale","Tellima grandiflora","Thelypodium sp.","Thermopsis rhombifolia","Tithonia sp.","Tonella floribunda","Tradescantia sp.","Trifolium incarnatum","Trifolium sp.","Vaccinium ovatum","Vaccinium sp.","Verbascum thapsus","Veronica scutellata","Viburnum davidii","Vicia americana","Vicia cracca","Vicia sativa","Vicia sp.","Vicia villosa","Whipplea modesta","Wisteria sp.","Wyethia amplexicaulis","Wyethia angustifolia","Wyethia mollis","Wyethia sp."],"group":[1,4,10,11,9,7,5,1,8,3,2,5,5,3,7,10,6,1,14,1,13,3,12,5,12,12,5,11,7,10,3,9,12,12,11,10,8,5,8,12,10,12,8,11,10,10,9,3,4,12,12,10,12,5,3,5,5,11,10,7,7,5,5,3,5,5,5,12,9,3,9,9,10,12,10,7,3,7,8,3,8,12,9,12,1,7,7,12,7,1,12,3,9,12,12,10,3,3,13,5,1,12,12,12,12,10,2,5,12,5,9,6,5,10,5,12,12,12,1,1,11,3,10,9,11,9,5,7,7,3,7,9,7,5,10,10,12,5,9,3,5,3,3,2,5,10,9,6,3,1,1,7,5,11,12,1,1,10,3,10,3,3,11,9,8,5,5,12,7,10,1,12,6,1,12,7,12,5,12,1,12,3,11,11,1,5,7,12,9,7,12,5,5,5,5,5,1,5,12,3,7,7,2,10,12,1,10,5,10,12,2,13,5,12,5,12,6,5,1,12,9,9,6,5,3,12,3,7,12,9,12,7,7,11,5,7,12,7,7,11,3,7,3,6,8,9,4,9,7]},"options":{"NodeID":"name","Group":"group","colourScale":"d3.scaleOrdinal(d3.schemeCategory20);","fontSize":7,"fontFamily":"serif","clickTextSize":17.5,"linkDistance":50,"linkWidth":"function(d) { return Math.sqrt(d.value); }","charge":-30,"opacity":0.8,"zoom":true,"legend":false,"arrows":false,"nodesize":false,"radiusCalculation":" Math.sqrt(d.nodesize)+6","bounded":false,"opacityNoHover":0.9,"clickAction":null}},"evals":[],"jsHooks":[]}</script>
```

We can also use a flow-like visualization plot. 


``` r
sankeyNetwork(Links = g_bumbles_net3d$links,
             Nodes = g_bumbles_net3d$nodes,
            Source = "source", Target = "target",
            Value = "value",  NodeID = "name", 
            nodePadding = 0, height = 5000)
```

```{=html}
<div id="htmlwidget-d0364567f96453a52652" style="width:672px;height:5000px;" class="sankeyNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-d0364567f96453a52652">{"x":{"links":{"source":[12,22,22,2,12,3,5,22,2,21,4,22,22,22,3,2,8,12,22,8,5,22,2,22,8,5,3,22,2,2,4,21,1,5,22,22,12,4,15,9,22,12,22,12,9,12,22,12,3,2,5,11,5,11,4,12,12,9,12,16,3,12,22,7,11,17,11,12,3,22,22,9,2,4,22,21,13,4,20,22,2,4,12,3,22,2,22,4,22,2,5,9,5,5,14,9,13,22,8,13,8,22,9,4,22,5,7,14,21,5,5,22,5,12,22,12,5,7,22,21,22,9,4,3,22,22,15,2,22,9,9,22,13,9,22,20,12,7,22,22,12,11,22,12,22,2,10,22,12,22,4,11,12,22,2,21,4,16,3,22,11,5,12,12,4,2,11,8,22,9,22,22,7,17,7,11,22,3,13,22,2,4,3,4,11,5,5,22,7,21,22,5,21,4,4,5,22,12,2,2,22,22,12,5,12,22,3,12,4,2,9,22,21,12,22,11,9,22,21,10,12,2,9,2,4,16,2,18,13,22,8,11,9,5,22,7,12,11,22,16,7,5,12,3,22,16,7,14,4,19,5,7,12,2,7,22,2,9,2,12,21,22,9,22,2,21,4,12,2,3,7,22,21,9,4,13,8,12,22,3,12,12,8,3,22,2,5,2,3,5,7,22,16,17,11,22,8,5,22,3,3,22,8,11,7,12,12,11,22,7,3,12,11,22,22,21,9,3,3,7,4,14,12,11,5,21,12,22,13,3,12,22,9,14,4,16,5,22,22,11,3,1,12,22,22,11,12,12,12,2,6,1,22,12,15,7,16,11,12,3,6,7,12,22,13,5,5,2,10,4,2,22,7,22,5,2,4,10,5,12,2,12,22,4,8,10,20,20,11,22,11,8,9,13,2,12,9,12,22,14,22,16,12,0,12,22,7,16,1,7,22,5,12,11,4,5,2,14,4,7,2,16,11,22,13,11,22,5,13,9,22,5,13,9,22,2,12,4,22,14,9,2,22,5,11,22,3,22,12,5,22,5,14,21,5,22,3,9,21,3,21,5,9,8,14,3,9,22,22,16,11,8,4,2,1,4,22,5,7,4,11],"target":[23,24,25,25,26,27,28,28,29,30,31,32,33,34,34,35,36,37,37,38,38,39,40,41,42,42,43,43,44,45,46,47,48,48,49,50,50,51,51,51,51,51,52,53,54,55,56,56,57,58,59,59,60,61,61,61,62,63,64,65,65,65,65,65,65,66,66,66,66,66,67,67,67,68,68,69,69,70,71,71,71,71,71,71,72,72,73,74,74,74,75,76,76,77,77,78,78,78,78,79,80,81,82,82,83,84,84,85,85,85,86,87,88,88,89,89,89,89,90,91,91,91,92,92,93,94,95,95,95,95,96,96,96,97,97,98,99,100,101,102,103,103,103,104,104,105,106,107,107,108,108,109,109,110,110,110,110,111,112,112,112,112,112,113,113,113,114,115,115,115,116,117,118,118,119,120,120,120,121,121,122,123,124,125,126,127,128,128,129,129,129,130,131,131,132,132,132,133,134,135,135,136,136,137,137,137,138,138,138,138,138,139,139,140,140,140,141,142,142,143,144,145,145,146,146,147,147,147,148,148,148,148,148,148,149,149,150,150,150,150,150,151,152,153,154,155,155,155,155,155,155,156,157,157,157,158,158,158,159,159,160,160,161,161,161,161,161,161,162,162,163,163,163,163,163,164,164,164,164,164,165,166,166,166,167,168,168,169,170,170,170,171,172,173,173,174,175,175,175,175,176,176,176,176,176,176,177,177,178,179,179,179,179,180,181,181,181,182,183,184,184,184,185,186,186,187,187,187,187,187,188,188,188,188,188,188,189,189,190,191,191,191,191,191,192,192,192,193,194,194,194,195,195,195,195,196,196,196,196,196,197,197,197,198,199,200,201,202,202,203,203,204,205,205,206,206,206,206,207,207,208,209,209,209,209,210,210,211,212,213,213,213,213,213,213,214,215,215,215,216,216,216,217,218,218,218,218,218,219,219,219,219,219,219,220,220,220,220,221,221,221,222,223,224,224,225,225,225,226,226,226,227,227,227,228,229,229,229,230,231,231,232,232,232,233,233,233,234,234,235,236,237,238,238,238,239,239,240,240,240,241,241,241,241,241,241,242,242,243,243,244,244,245,245,246,247,248,248,248,248,248],"value":[1,1,5,1,2,2,2,3,1,1,3,1,1,1,1,1,1,1,1,1,1,2,1,1,5,1,1,1,1,3,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,2,2,2,1,2,1,1,1,1,3,1,1,1,1,2,3,5,1,4,1,5,8,4,10,8,1,1,1,1,1,1,2,1,1,3,6,3,1,1,1,8,2,1,4,3,3,2,1,1,1,1,1,2,1,1,1,1,1,1,1,1,2,1,3,3,1,2,2,2,1,1,4,1,1,1,1,2,1,1,1,2,24,3,1,7,3,2,4,3,1,1,1,1,1,1,1,20,1,4,1,1,1,2,5,2,2,1,1,2,1,4,1,1,2,1,4,9,1,1,2,1,1,3,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,3,2,1,1,4,1,1,1,3,1,5,4,5,1,1,2,1,4,2,3,3,1,1,1,2,1,1,1,1,1,1,1,3,1,2,4,2,1,1,2,1,1,1,2,2,1,5,2,1,4,1,4,1,1,1,1,1,5,2,2,1,4,1,3,5,1,1,1,1,2,1,6,3,1,1,1,11,1,2,1,2,1,2,4,1,12,2,9,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,6,3,1,1,3,1,2,1,1,2,3,1,3,1,1,1,1,4,1,3,1,1,4,2,3,1,1,1,1,1,9,1,1,1,1,3,1,8,3,1,1,1,3,1,1,3,1,6,4,3,2,6,2,1,1,1,4,1,1,1,1,1,1,1,1,2,1,1,2,2,1,1,1,3,3,1,2,1,3,2,1,1,2,1,1,7,1,1,1,1,2,1,7,1,2,3,1,1,2,2,3,17,1,1,1,2,1,2,2,4,1,2,1,16,1,4,2,1,1,2,1,3,1,2,1,2,1,1,1,4,1,1,3,2,4,1,2,2,1,1,2,1,2,1,1,1,1,1,1,3,1,2,1,1,1,1,1,2,1,2,2,1,1,3,8,5,1,1,2,1,1,1,1,1,1,1,1,1,1,2,2,1,2,1]},"nodes":{"name":["Bombus ","Bombus appositus","Bombus bifarius","Bombus caliginosus","Bombus centralis","Bombus fervidus","Bombus flavidus","Bombus flavifrons","Bombus griseocollis","Bombus huntii","Bombus insularis","Bombus melanopygus","Bombus mixtus","Bombus morrisoni","Bombus nevadensis","Bombus occidentalis","Bombus rufocinctus","Bombus sitkensis","Bombus sylvicola","Bombus vagans","Bombus vancouverensis","Bombus vandykei","Bombus vosnesenskii","Acer circinatum","Acer macrophyllum","Achillea millefolium","Achillea sp.","Aesculus hippocastanum","Agastache sp.","Agastache urticifolia","Alcea biennis","Alcea rosea","Allium amplectens","Amelanchier alnifolia","Amsinckia menziesii","Angelica arguta","Apocynum sp.","Aquilegia formosa","Aquilegia sp.","Arctostaphylos densiflora","Arnica cordifolia","Asclepias or Euphorbia spp.","Asclepias speciosa","Asparagus officinalis","Aster foliaceus","Asteraceae","Astragalus filipes","Balsamorhiza sp.","Bellardia viscosa","Bellis perennis","Bellis sp.","Berberis aquifolium","Betula sp.","Boraginales","Borago officinalis","Brassica oleracea italica","Brassica rapa","Brassica sp.","Calochortus mariposa","Calystegia soldanella","Camassia quamash","Camassia sp.","Castanea sp.","Catalpa sp.","Ceanothus cuneatus","Ceanothus sp.","Ceanothus thyrsiflorus","Ceanothus velutinus","Centaurea cyanus","Centaurea maculosa","Centaurea sp.","Chamaenerion angustifolium","Chrysolepis chrysophylla","Chrysothamnus nauseosus","Cirsium arvense","Cirsium sp.","Cirsium vulgare","Clarkia amoena","Cleome serrulata","Coreopsis sp.","Crataegus","Cucurbita sp.","Cynoglossum officinale","Dahlia sp.","Delphinium leucophaeum","Delphinium sp.","Delphinium trolliifolium","Dicentra formosa","Digitalis purpurea","Dipsacus fullonum","Echinacea sp.","Echinops sp.","Epilobium angustifolium","Epilobium sp.","Ericaceae","Ericameria linearifolia","Ericameria nauseosa","Ericameria sp.","Eriogonum glaucus","Eriogonum sp.","Eriophyllum confertiflorum","Eriophyllum lanatum","Eriophyllum sp.","Eschscholzia californica","Euonymus occidentalis","Euphorbia esula","Fagopyrum sp.","Fragaria chiloensis","Gaillardia sp.","Geranium oreganum","Geranium sp.","Gilia capitata","Grindelia stricta stricta","Hackelia micrantha","Helenium autumnale","Helianthus annuus","Helianthus sp.","Heliopsis helianthoides","Heracleum maximum","Heracleum sphondylium","Heuchera sp.","Holodiscus dumosus","Horkelia fusca","Hydrophyllum sp.","Hypericum sp.","Iliamna rivularis","Kalmia polifolia","Lathyrus hirsutus","Lathyrus japonicus var. maritimus","Lavandula angustifolia","Leucanthemum vulgare","Lithospermum ruderale","Lonicera caerulea","Lonicera involucrata","Lupinus argenteus argenteus","Lupinus lepidus","Lupinus littoralis","Lupinus rivularis","Lupinus sp.","Mahonia aquifolium","Malus pumila ","Medicago sativa","Melilotus albus","Microseris nutans","Mimulus guttatus","Mimulus lewisii","Mimulus sp.","Monardella odoratissima","Nepeta cataria","Nepeta grandiflora","Nepeta sp.","Net","Oenanthe sarmentosa","Oenothera biennis","Origanum vulgare","Penstemon deustus","Penstemon ovatus","Penstemon procerus","Penstemon sp.","Penstemon spectabilis","Perovskia atriplicifolia","Phacelia hastata","Phacelia heterophylla","Phacelia sp.","Phacelia tanacetifolia","Physocarpus capitatus","Physocarpus sp.","Plagiobothrys figuratus","Poison hemlock and Steens Mtn thistle","Potentilla gracilis","Prunella vulgaris","Prunus avium","Prunus laurocerasus","Ranunculus occidentalis","Raphanus sativus","Raphanus sp.","Rhododendron macrophyllum","Rhododendron maximum","Rhododendron sp.","Rhododendron x","Ribes aureum","Ribes cereum","Ribes rubrum","Ribes sanguineum","Robinia pseudoacacia","Rosa gymnocarpa","Rosa nutkana","Rosa sp.","Rosa woodsii","Rosaceae","Rosmarinus officinalis","Rubus armeniacus","Rubus bifrons","Rubus fruticosus","Rubus idaeus","Rubus parviflorus","Rubus sp.","Rubus ursinus","Salix lasiandra","Salvia officinalis","Salvia pratensis","Scutellaria integrifolia","Senecio hydrophilus","Senecio sp.","Sidalcea campestris","Sidalcea nelsoniana","Sidalcea oregana","Sidalcea sp.","Solanum sp.","Solidago canadensis","Solidago elongata","Solidago sp.","Sorbus aucuparia","Spiraea douglasii","Spiraea japonica","Spiraea sp.","Stachys byzantina","Stachys chamissonis","Styrax japonicus","Symphoricarpos albus","Symphoricarpos rotundifolius","Symphoricarpos sp.","Symphytum sp.","Syringa sp.","Taraxacum officinale","Tellima grandiflora","Thelypodium sp.","Thermopsis rhombifolia","Tithonia sp.","Tonella floribunda","Tradescantia sp.","Trifolium incarnatum","Trifolium sp.","Vaccinium ovatum","Vaccinium sp.","Verbascum thapsus","Veronica scutellata","Viburnum davidii","Vicia americana","Vicia cracca","Vicia sativa","Vicia sp.","Vicia villosa","Whipplea modesta","Wisteria sp.","Wyethia amplexicaulis","Wyethia angustifolia","Wyethia mollis","Wyethia sp."],"group":["Bombus ","Bombus appositus","Bombus bifarius","Bombus caliginosus","Bombus centralis","Bombus fervidus","Bombus flavidus","Bombus flavifrons","Bombus griseocollis","Bombus huntii","Bombus insularis","Bombus melanopygus","Bombus mixtus","Bombus morrisoni","Bombus nevadensis","Bombus occidentalis","Bombus rufocinctus","Bombus sitkensis","Bombus sylvicola","Bombus vagans","Bombus vancouverensis","Bombus vandykei","Bombus vosnesenskii","Acer circinatum","Acer macrophyllum","Achillea millefolium","Achillea sp.","Aesculus hippocastanum","Agastache sp.","Agastache urticifolia","Alcea biennis","Alcea rosea","Allium amplectens","Amelanchier alnifolia","Amsinckia menziesii","Angelica arguta","Apocynum sp.","Aquilegia formosa","Aquilegia sp.","Arctostaphylos densiflora","Arnica cordifolia","Asclepias or Euphorbia spp.","Asclepias speciosa","Asparagus officinalis","Aster foliaceus","Asteraceae","Astragalus filipes","Balsamorhiza sp.","Bellardia viscosa","Bellis perennis","Bellis sp.","Berberis aquifolium","Betula sp.","Boraginales","Borago officinalis","Brassica oleracea italica","Brassica rapa","Brassica sp.","Calochortus mariposa","Calystegia soldanella","Camassia quamash","Camassia sp.","Castanea sp.","Catalpa sp.","Ceanothus cuneatus","Ceanothus sp.","Ceanothus thyrsiflorus","Ceanothus velutinus","Centaurea cyanus","Centaurea maculosa","Centaurea sp.","Chamaenerion angustifolium","Chrysolepis chrysophylla","Chrysothamnus nauseosus","Cirsium arvense","Cirsium sp.","Cirsium vulgare","Clarkia amoena","Cleome serrulata","Coreopsis sp.","Crataegus","Cucurbita sp.","Cynoglossum officinale","Dahlia sp.","Delphinium leucophaeum","Delphinium sp.","Delphinium trolliifolium","Dicentra formosa","Digitalis purpurea","Dipsacus fullonum","Echinacea sp.","Echinops sp.","Epilobium angustifolium","Epilobium sp.","Ericaceae","Ericameria linearifolia","Ericameria nauseosa","Ericameria sp.","Eriogonum glaucus","Eriogonum sp.","Eriophyllum confertiflorum","Eriophyllum lanatum","Eriophyllum sp.","Eschscholzia californica","Euonymus occidentalis","Euphorbia esula","Fagopyrum sp.","Fragaria chiloensis","Gaillardia sp.","Geranium oreganum","Geranium sp.","Gilia capitata","Grindelia stricta stricta","Hackelia micrantha","Helenium autumnale","Helianthus annuus","Helianthus sp.","Heliopsis helianthoides","Heracleum maximum","Heracleum sphondylium","Heuchera sp.","Holodiscus dumosus","Horkelia fusca","Hydrophyllum sp.","Hypericum sp.","Iliamna rivularis","Kalmia polifolia","Lathyrus hirsutus","Lathyrus japonicus var. maritimus","Lavandula angustifolia","Leucanthemum vulgare","Lithospermum ruderale","Lonicera caerulea","Lonicera involucrata","Lupinus argenteus argenteus","Lupinus lepidus","Lupinus littoralis","Lupinus rivularis","Lupinus sp.","Mahonia aquifolium","Malus pumila ","Medicago sativa","Melilotus albus","Microseris nutans","Mimulus guttatus","Mimulus lewisii","Mimulus sp.","Monardella odoratissima","Nepeta cataria","Nepeta grandiflora","Nepeta sp.","Net","Oenanthe sarmentosa","Oenothera biennis","Origanum vulgare","Penstemon deustus","Penstemon ovatus","Penstemon procerus","Penstemon sp.","Penstemon spectabilis","Perovskia atriplicifolia","Phacelia hastata","Phacelia heterophylla","Phacelia sp.","Phacelia tanacetifolia","Physocarpus capitatus","Physocarpus sp.","Plagiobothrys figuratus","Poison hemlock and Steens Mtn thistle","Potentilla gracilis","Prunella vulgaris","Prunus avium","Prunus laurocerasus","Ranunculus occidentalis","Raphanus sativus","Raphanus sp.","Rhododendron macrophyllum","Rhododendron maximum","Rhododendron sp.","Rhododendron x","Ribes aureum","Ribes cereum","Ribes rubrum","Ribes sanguineum","Robinia pseudoacacia","Rosa gymnocarpa","Rosa nutkana","Rosa sp.","Rosa woodsii","Rosaceae","Rosmarinus officinalis","Rubus armeniacus","Rubus bifrons","Rubus fruticosus","Rubus idaeus","Rubus parviflorus","Rubus sp.","Rubus ursinus","Salix lasiandra","Salvia officinalis","Salvia pratensis","Scutellaria integrifolia","Senecio hydrophilus","Senecio sp.","Sidalcea campestris","Sidalcea nelsoniana","Sidalcea oregana","Sidalcea sp.","Solanum sp.","Solidago canadensis","Solidago elongata","Solidago sp.","Sorbus aucuparia","Spiraea douglasii","Spiraea japonica","Spiraea sp.","Stachys byzantina","Stachys chamissonis","Styrax japonicus","Symphoricarpos albus","Symphoricarpos rotundifolius","Symphoricarpos sp.","Symphytum sp.","Syringa sp.","Taraxacum officinale","Tellima grandiflora","Thelypodium sp.","Thermopsis rhombifolia","Tithonia sp.","Tonella floribunda","Tradescantia sp.","Trifolium incarnatum","Trifolium sp.","Vaccinium ovatum","Vaccinium sp.","Verbascum thapsus","Veronica scutellata","Viburnum davidii","Vicia americana","Vicia cracca","Vicia sativa","Vicia sp.","Vicia villosa","Whipplea modesta","Wisteria sp.","Wyethia amplexicaulis","Wyethia angustifolia","Wyethia mollis","Wyethia sp."]},"options":{"NodeID":"name","NodeGroup":"name","LinkGroup":null,"colourScale":"d3.scaleOrdinal(d3.schemeCategory20);","fontSize":7,"fontFamily":null,"nodeWidth":15,"nodePadding":0,"units":"","margin":{"top":null,"right":null,"bottom":null,"left":null},"iterations":32,"sinksRight":true}},"evals":[],"jsHooks":[]}</script>
```

### In class: Visualization challange 1.

Choose a different genus of bees and repeat the steps above to make a network. 

### In class: Visualization challange 2. 
How could we use graph attributes to create informative network visualizations? Set some attributes and use them to plot your network.
Consider using static network plots instead of network3D, see this [turorial](https://yunranchen.github.io/intro-net-r/advanced-network-visualization.html#visualization-for-static-network) for examples.  






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
