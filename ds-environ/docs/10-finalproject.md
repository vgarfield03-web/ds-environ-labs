
# Final project

## Final project objective
The objective of the final project will be to complete a fully reproducible workflow that uses Oregon Bee Atlas (OBA) (undergrads) or your own data (graduate students, or undergrads doing a senior thesis) to address your chosen conservation/ecology question. The project must illustrate all of the following tasks:

- A testable hypothesis, including the null and alternative
- Some form of data access / reading into R
- Integration of multiple types of data/data skills (interaction data, spatial data, merging together multiple datasets) including OBA data to address the question. Choose 3 of the data types we will cover in class.
- Data tidying, including data joins, using regular expressions to clean entries
- Manipulate and summarize the data in relevant ways
- Initial data visualization/exploration
- A test of your hypothesis, using simulation, A/B testing or another statistical test
- Final, publication-worthy visualization answering your question
- RMarkdown writeup, with final submission as both the .Rmd file and a nicely formatted PDF document that includes code and results
- The project should be version controlled using github
- Overall clean and clear presentation of the workflow, code, and explanation

**This is a great reference on scientific writing:** Turbek, Sheela P., Taylor M. Chock, Kyle Donahue, Caroline A. Havrilla, Angela M. Oliverio, Stephanie K. Polutchko, Lauren G. Shoemaker, and Lara Vimercati. “Scientific Writing Made Easy: A Step-by-Step Guide to Undergraduate Writing in the Biological Sciences.” The Bulletin of the Ecological Society of America 97, no. 4 (October 2016): 417–26. https://doi.org/10.1002/bes2.1258.


## Final project topic selection (first final project assignment)
We will be building toward the final project throughout the class. At this stage we need enough information from you to ensure your project is do-able during the timespan of a quarter. A full project proposal, with questions and identified data sources, will be due later in the quarter. For now, please submit a knitted .Rmd file saved as "LASTNAME_ProjectTopic.pdf". Include the following:

1) General topic of interest in relation to the Oregon Bee Atlas data (e.g., patterns of diversity, bee diets, sampling bias)  
2) Potential questions within that topic area 
3) Potential additional datasets within that topic area (e.g.,specify relevant government databases, academic data repositories, etc)
4) The name of your partner (if undergrads)

**If you do have your own data (graduate students, thesis undergrads):**
1) The questions you would like to answer with your data  
2) The structure and metadata of the dataset
3) Potential additional datasets within that topic area

## Final project office hours discussion (second final project assignment)

Sign up for an office hours slot to discuss your project with LP (me). I will provide feedback on feasibility, match to the assignment, and general pointers on approach.

## Final project annotated bibliography (third final project assignment)



### Overview

An **annotated bibliography** is a curated list of sources (journal articles, books, datasets, methods papers). Each entry provides (i) a complete citation and (ii) a brief annotation **in your own words** that summarizes, evaluates, and explains the source's relevance to your project. It demonstrates that you've found high‑quality literature, understand it, and know how you’ll use it.

### Learning objectives

By completing this assignment you will be able to:

- Locate and filter **relevant** scholarly sources for your topic.
- **Summarize** methods, findings, and limitations clearly and concisely.
- **Evaluate** credibility, generalizability, and relevance to your research question.
- Track source **provenance** and manage citations reproducibly with a `.bib` file.

### Requirements

- **Number of sources:** 10+ total, peer reviewed articles.
- Focus on work **directly relevant** to your  methods or hypotheses.  
- Use a consistent citation style (e.g., **APA**, **Chicago**, or **Ecology**) via a CSL file.  
- Submit: use your **Rmd**, your **`references.bib`** to create a knitted **PDF**, upload to canvas. 

 **Academic integrity & tool policy.** You may use LLM tools (e.g., GitHub Copilot, ChatGPT) **only for discovery** (brainstorming keywords, surfacing candidate papers). You must **find, read, and summarize** the articles yourself. Annotations must be **in your own words**—do not paste or lightly paraphrase abstracts. Verify all bibliographic details (authors, year, journal, DOI).

### How to search effectively (Google Scholar tips)

- Start broad, then narrow: `"pollinator network" modularity`, `beta diversity turnover habitat`.  
- Use **quotes** for exact phrases; use **minus** to exclude terms: `trait diversity -human -medical`.  
- Filter by **Year** (left sidebar): last 5–10 years first, then “Cited by …” to trace backward.  
- Click **“Related articles”** to widen the net; **“All versions”** can reveal accessible PDFs.  
- Use the **export citation button** to copy citations.

### Recommended workflow

1. Create a project folder and add this Rmd.  
2. Manage references with **Zotero + Better BibTeX** or export **BibTeX** from publishers/Scholar.  
3. Save `references.bib` next to this Rmd and add to YAML if standalone:  
   ```yaml
   bibliography: references.bib
   csl: apa.csl
   ```
4. Cite sources in text with `[@key]` and knit—**References** appear automatically.  
5. Write each annotation using the template below (≈ 150–250 words per entry).

### What each entry should include

- **Full citation** (via your `.bib` key) and a **persistent identifier** (DOI/URL).  
- **Summary:** research question, system/data, methods/analyses, main findings (3–5 sentences).  
- **Evaluation:**  design strengths/weaknesses, limitations, potential biases (2–3 sentences).  
- **Relevance:** how it informs your hypotheses, variables, data, or analysis plan (1–2 sentences).  
- **Tags** (optional): keywords you’ll use to organize sources (e.g., `trait-diversity`, `GLM`, `restoration`).

> Aim for **clarity and specificity**: what exactly did they measure, how, and why does it matter to your project?

### Template (copy for each source)

Replace `@key` with your BibTeX citation key.

### Author Surname et al. (Year). *Title*.

**Citation:** `@key`

**Summary (what they did & found):**  
*3–5 sentences: research question; system/data; methods; main findings.*

**Evaluation (quality & limits):**  
*2–3 sentences: design strengths/weaknesses, assumptions, possible biases.*

**Relevance (how you’ll use it):**  
*1–2 sentences: informs variable/metric choice, design, or interpretation.*

**Tags:** `your, tags, here`

---

### Example of in‑text citation & references

Cite inline (e.g., @key) or parenthetically (e.g., [@key]). Multiple citations: [@key1; @key2].

> If you configure `bibliography:` and `csl:` in YAML, a **References** section will be generated when you knit.

### Rubric

- **Relevance & coverage (30%)** — appropriate breadth/depth; includes methods and data sources.  
- **Annotation quality (40%)** — accurate summaries, critical evaluation, clear relevance.  
- **Citation management (15%)** — valid `.bib` entries; consistent style; working DOIs/links.  
- **Professionalism (15%)** — organization, clarity, grammar; files named and submitted as requested.

### Submission checklist

- [ ] This Rmd knits (no errors).  
- [ ] `references.bib` included in repo and paths correct in YAML.  
- [ ] Annotations in your **own words**; no pasted abstracts.  
- [ ] Each entry has summary, evaluation, relevance, and key details.  
- [ ] Provenance log included.  
- [ ] Final commit pushed to your course repository.



## Literature review and workflow plan (fourth final project assignment)

To progress toward the final project, please prepare a literature review using your annotated bib and develop a workflow plan. A description of each is below. Include the name of your partner in the header. 

### Literature review (i.e., the introduction section of your final project)
We expect the literature review will be around 5 well cited paragraphs that do the following:

__1. Introduce the problem and explain why__  

* Set the stage for the problem  
* Put the concept and question into context  
* Lots of big-picture citations (such as reviews) in the first paragraph 
* See the [baby-werewolf-silver bullet guide to writing science](https://ecoevoevoeco.blogspot.com/2014/10/how-to-writepresent-science-baby.html})

__2. Past work and data available__

- Who has addressed this problem (perhaps with a different dataset/region), and what did they do it?  
- What are the data available to address this problem (in addition to the OBA/your dataset)?  

__3. Purpose of the study__

- Further refine your approach (e.g., what data will you combine/transorm to a new type, how will you address the question)  
- Justify why this is needed now (e.g., visualization to test a new dimension of the question or better convey an old one)

__4. Hypotheses/questions__

- List these clearly and in a logical order  
- Make hypotheses directionally using predictions (e.g. "I predict urbanization will reduce plant diversity" rather than "I predict urbanization will change plant diversity")
   
### Dataset identification
Please identify any additional datasets you will be using to address your question. 
* For data other than the OBA data provide the data source (including web url) 
* Describe sufficient metadata to convey who collected the data, how it was collected, and what each column contains. 
* If transforming the OBA data into a different data type, explain your plan for doing this.

### Workflow plan
In pros, please describe the workflow you will use tidy your raw data, manipulate and summarize it in relevant ways, test you hypothesis, and visualize it.The goal here is to develop a logic to your workflow before you code. 

- Include any needed cleaning steps (e.g., "remove non-species such as 'fly' from the species column") 
- Include any aggregation steps (e.g., "count the number of entries by region and year to calculate species richness"). 
- Include descriptions of any functions/for loops you will write.  
- Include a description the the statistical test you will use, and how you will apply it programatically (i.e., I will simulate the null hypothesis by shuffling the labels...")

### Rubric 

| Criterion | What to look for | Points |
|---|---|---:|
| **1) Problem framing & significance** | Clear statement of the problem, why it matters, big‑picture context with a few review citations. | **20%** |
| **2) Prior work & data landscape** | Brief synthesis of who has studied this (where/how), key findings or gaps, and available datasets beyond OBA (with links). | **20%** |
| **3) Purpose & hypotheses** | Specific aim/purpose and **directional** hypotheses (“increase/decrease”) that follow logically from the literature. | **20%** |
| **4) Workflow plan (data → analysis → viz)** | Plain‑language steps: cleaning/validation, aggregations/derivations, any functions/loops, the statistical test **and** how you’ll implement it (e.g., permutation), and intended figures/tables. | **30%** |
| **5) Writing, citations, professionalism** | ~5 concise paragraphs, organized and typo‑light; consistent in‑text citations with DOIs/URLs for datasets; partner named in header. | **10%** |

### Submission Checklist

**Header & format**

- [ ] Partner’s name(s) in the document header.  
- [ ] Clear, descriptive title & system context.  
- [ ] ~5 paragraphs, each with appropriate citations.

**Literature review**

- [ ] Opens with big‑picture motivation and review citations (see *baby‑werewolf–silver bullet* guide).  
- [ ] Synthesizes prior work (who/where/how) and main findings/gaps.  
- [ ] States the **purpose** and why it’s timely.  
- [ ] Lists clear, **directional** hypotheses with brief rationale.

**Dataset identification**

- [ ] Each non‑OBA dataset: name, URL/DOI, collector, methods, columns/units.  
- [ ] OBA transformation plan: what becomes what, with justification.

**Workflow plan**

- [ ] Cleaning/validation steps (e.g., remove non‑species; standardize units; handle missing data).  
- [ ] Aggregations/derivations (e.g., richness by region × year; diversity metrics; trait construction).  
- [ ] Functions/loops or `purrr`/`dplyr` maps planned; inputs/outputs noted.  
- [ ] Statistical test(s) specified **and** how implemented programmatically (e.g., simulate null by shuffling labels; number of permutations; summary statistic).  
- [ ] Planned visualizations/tables and their purpose.  
- [ ] Risks & mitigations (e.g., incomplete metadata, unbalanced sampling, expected limitations).

**Citations & integrity**

- [ ] Consistent citation style; inline citations throughout.  
- [ ] DOIs/URLs included for datasets and key papers.  
- [ ] Summaries and paraphrases are in **your own words** (no abstracts copied).  
- [ ] LLMs (Copilot/ChatGPT) used **only for discovery**; you verified and summarized all sources yourself.

**Professionalism**

- [ ] File compiles/exports cleanly (Rmd → HTML/PDF, if applicable).  
- [ ] Clear headings/subheadings; figures/tables (if any) captioned and referenced.  
- [ ] Final commit pushed to your course repository in the correct folder.

---

### Optional scaffold (copy into your working doc)

```markdown
# Title of project (system/region)

**Partner(s):** Name Surname

## Literature review (~5 paragraphs)

### Paragraph 1 — Problem & significance (big‑picture reviews)
…

### Paragraph 2–3 — Past work & data landscape (who/where/how; gaps)
…

### Paragraph 4 — Purpose & why now
…

### Paragraph 5 — Hypotheses (directional) & brief rationale
- H1: … (I predict … because …)
- H2: …

## Dataset identification
- Dataset A (URL/DOI): collector, methods, columns/units …
- OBA → transformed to … (plan and rationale) …

## Workflow plan (prose)
1) Cleaning & validation: …  
2) Aggregations/derivations: …  
3) Functions/loops (inputs → outputs): …  
4) Statistical test + programmatic implementation: …  
5) Planned visualizations/tables: …  
6) Risks & mitigations: …
```

## Final Project Rubric (10 pts total + 1 pt extra credit)

> Use this to score the written analysis deliverable (Rmd + PDF).

| Criterion | Details | Points |
|---|---|---:|
| **Introduction** | Background & literature foreshadow the importance of each question; **clear statement of 2+ questions** addressing a new dimension of bee conservation, ecology, or management using OBA or student’s data. Graduate students write as a thesis‑style intro with comprehensive background literature. Citations use a standardized style. ~1 page. | **1** |
| **Data** | (1) List **2+ datasets** and **3+ distinct data skills** (e.g., table manipulation, interaction data, raster, vector). Provide general metadata (as in workflow). (2) Read and tidy **2018–2024 OBA** (plant taxonomy cleaned via regex if using plant data). If using own data, it is complete and cleaned. | **1** |
| **Data wrangling, summarizing, exploring** | Relevant manipulation & summaries; exploratory tables and plots (scatter, hist, bar, etc.); multiple **relevant** visualizations and data checks. | **1** |
| **Hypothesis test** | Use a **simulation or statistical test** to make an inference; grad students use the **best available** statistical approach. | **2** |
| **Visualization** | Final, publication‑quality figures that answer the questions; clear labels, legends, and units. | **2** |
| **Additional tool/analysis** | *Extra credit:* grads must incorporate a tool not addressed in class in analysis/visualization/workflow; undergrads may earn EC. | **+1 EC** |
| **Conclusion** | Clearly answers the original questions and connects to relevant comparative literature. | **1** |
| **Overall workflow** | (1) Version control on GitHub; (2) clear, complete Rmd and PDF; (3) organized, readable workflow, code, and explanations. | **2** |

**Total:** 10 pts (plus up to **+1** extra credit)

---

## Poster Presentation Rubric (10 pts total)

> Use this to score the conference‑style poster deliverable.

| Section | Details | Points |
|---|---|---:|
| **Intro part 1 — Context** | Introduce main ideas; explain significance; include most relevant citations; short paragraph or bullets. | **1** |
| **Intro part 2 — Scientific/management gap** | Present the gap that motivates a compelling question (**bold the question**). | **1** |
| **Research question(s)** | Bullet the specific question(s) clearly tied to the gap. | **1** |
| **Methods — Data & tidying** | Introduce data sources (e.g., land cover, elevation, fire). If using own data, describe collection. Summarize OBA tidying/manipulation. Use a flow diagram and/or bullets. | **2** |
| **Methods — Analysis workflow** | Flow diagram of each analysis step; explain statistical or simulation test. | **2** |
| **Results** | Summaries with at least one visualization per result. | **1** |
| **Conclusion** | Answer the question(s) and interpret meaning. | **1** |
| **Overall display** | Layout, readability, and visual design quality. | **1** |

**Total:** 10 pts

---


