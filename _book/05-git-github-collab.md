# Version control and collaboration with git and github

Before we begin, make sure to install git and create an account on github (free), [instructions](https://swcarpentry.github.io/git-novice/)

[Setup your ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

That step is painful, but you only have to do it once ever. Don't set your key to expire quickly... or ever? ;) 

[Set up your username](https://swcarpentry.github.io/git-novice/02-setup.html)

## Lecture summary 

In this lecture, we will cover a basic workflow using git and github. This chapter is based on a lesson by Software Carpentery. For our dicussion, we will further examine best practices in science, mainly, Trisos et al. 2021 Decoloniality and anti-oppressive practices for a more ethical ecology.

### Learning objectives

- Understand the benefits of an automated version control system.
- Understand the basics of how automated version control systems work using git and github.

We'll start by exploring how version control can be used
to keep track of what one person did and when.
Even if you aren't collaborating with other people,
automated version control is much better than this situation:

!["notFinal.doc" by Jorge Cham, <https://www.phdcomics.com>](fig/git/phd101212s.png){alt='Comic: a PhD student sends "FINAL.doc" to their supervisor, but after several increasingly intense and frustrating rounds of comments and revisions they end up with a file named "FINAL_rev.22.comments49.corrections.10.#@$%WHYDIDCOMETOGRADSCHOOL????.doc"'}

We've all been in this situation before: it seems unnecessary to have
multiple nearly-identical versions of the same document. Some word
processors let us deal with this a little better, such as Microsoft
Word's
[Track Changes](https://support.office.com/en-us/article/Track-changes-in-Word-197ba630-0f5f-4a8e-9a77-3712475e806a),
Google Docs' [version history](https://support.google.com/docs/answer/190843?hl=en), or
LibreOffice's [Recording and Displaying Changes](https://help.libreoffice.org/Common/Recording_and_Displaying_Changes).

Version control systems start with a base version of the document and
then record changes you make each step of the way. You can
think of it as a recording of your progress: you can rewind to start at the base
document and play back each change you made, eventually arriving at your
more recent version.

![](fig/git/play-changes.svg){alt='Changes Are Saved Sequentially'}

Once you think of changes as separate from the document itself, you
can then think about "playing back" different sets of changes on the base document, ultimately
resulting in different versions of that document. For example, two users can make independent
sets of changes on the same document.

![](fig/git/versions.svg){alt='Different Versions Can be Saved'}

Unless multiple users make changes to the same section of the document - a 
conflict - you can
incorporate two sets of changes into the same base document.

![](fig/git/merge.svg){alt='Multiple Versions Can be Merged'}

A version control system is a tool that keeps track of these changes for us, effectively creating different versions of our files. It allows us to decide which changes will be made to the next version (each record of these changes is called a [commit](../learners/reference.md#commit)), and keeps useful metadata about them. The complete history of commits for a particular project and their metadata make up a [repository](../learners/reference.md#repository).
Repositories can be kept in sync across different computers, facilitating
collaboration among different people.

### Hypothetical: Paper Writing

- Imagine you drafted an excellent paragraph for a paper you are writing, but later ruin
  it. How would you retrieve the *excellent* version of your conclusion? Is it even possible?

- Imagine you have 5 co-authors. How would you manage the changes and comments
  they make to your paper?  If you use LibreOffice Writer or Microsoft Word, what happens if
  you accept changes made using the `Track Changes` option? Do you have a
  history of those changes?


### Solution

- Recovering the excellent version is only possible if you created a copy
  of the old version of the paper. The danger of losing good versions
  often leads to the problematic workflow illustrated in the PhD Comics
  cartoon at the top of this page.

- Collaborative writing with traditional word processors is cumbersome.
  Either every collaborator has to work on a document sequentially
  (slowing down the process of writing), or you have to send out a
  version to all collaborators and manually merge their comments into
  your document. The 'track changes' or 'record changes' option can
  highlight changes for you and simplifies merging, but as soon as you
  accept changes you will lose their history. You will then no longer
  know who suggested that change, why it was suggested, or when it was
  merged into the rest of the document. Even online word processors like
  Google Docs or Microsoft Office Online do not fully resolve these
  problems.
  
  
- Version control is like an unlimited 'undo'.
- Version control also allows many people to work in parallel.

### Why Use Git and GitHub?

**Git** is a version control system — a “time machine” for code and text. It helps you:

- Track who changed what and when.
- Roll back to earlier versions if something breaks.
- Work safely on features/experiments without touching the main project.

**GitHub** is a cloud host for Git repositories. It makes teamwork easier by offering:

- Shared remote repos (backup + collaboration).
- Pull requests & code review.
- Issues, wiki, and automation.

---

### A Simple Two-Person Workflow

Suppose **Lauren** and **Rebecca** collaborate on the same project.

1. **Setup**
   - Lauren creates a repository (on GitHub, or locally for this demo) and pushes an initial commit.
   - Rebecca *clones* it to his computer.

2. **Daily Cycle (repeat)**
   - `git pull` to get the latest work.
   - Edit files.
   - `git add` to stage changes.
   - `git commit -m "message"` to record changes locally.
   - `git push` to share with collaborators.

**Mnemonic:** *pull → edit → add → commit → push*.

---

### Five Essential Git Commands

### 1) `git status`
Shows what changed and whether those changes are staged (ready to commit).
```bash
git status
```

**Use it:** Frequently — before/after edits, and before committing.

### 2) `git add`
Stages file(s) so they’re included in the next commit.
```bash
git add README.md
# or stage everything new/modified:
git add .
```
**Use it:** After editing/creating files you want to include in the next commit.

### 3) `git commit -m "message"`
Records a snapshot of the staged changes in the local repo.
```bash
git commit -m "feat: Created a new function that cleans the species. names and summarizes the number of times each occurs."
```

**Use it:** After staging with `git add` to save a meaningful unit of work. Use complete sentences and enough detail where you and your partner will understand exactly what you did.

Good/conventional commit messages: Commit messages should start with a "tag" of what type of commit is it (see below), than a brief (\<50 characters) statement about the changes made in the commit. Generally, the message should complete the sentence "If applied, this commit will" <commit message here>.

If you want to go into more detail, add a blank line between the summary line and your additional notes. Use this additional space to explain why you made changes and/or what their impact will be.

Feat– feature
Fix– bug fixes
Docs– changes to the documentation like README
Style– style or formatting change 
Perf – improves code performance
Test– test a feature

Best practices: [Conventional commits](https://gist.github.com/Zekfad/f51cb06ac76e2457f11c80ed705c95a3)

### 4) `git push`
Uploads your local commits to the remote (e.g., GitHub).
```bash
git push
```
**Use it:** After committing, to share your changes with collaborators.

### 5) `git pull`
Downloads and integrates changes from the remote into your local branch.
```bash
git pull
```
**Use it:** Before you start work (and also when Git tells you you’re behind).

---

### git command summary

- `git status` tells you what’s changed and what will be committed.
- `git add` stages the change; `git commit -m "…" ` records it locally.
- `git push` shares your commits to a remote; `git pull` brings remote changes to you.
- A consistent habit — **pull → edit → add → commit → push** — keeps collaborators in sync.

### I cannot push my commit!? 

Likely because: 

- Multiple people made changes to the same file. 
- You forgot to pull before starting to work. 
- For this class, though this is not a great practice, save you work somewhere outside of the repo. Re-clone the repo. Continue as before. 

**More advanced git** 

- Create branches for each person to work on, merge the branches with the main branch 
- You can go back to previous commits (a important component of git). 


## Discussion & Reflection: Trisos et al. (2021): Decoloniality and anti‑oppressive practices for a more ethical ecology

**How to use this section:** Read the article below (embedded) and prepare notes for the discussion prompts. Bring your answers to class.

### Article (embedded)
<div style="margin: 1rem 0;">
<embed src="readings/reading-Trisos2021.pdf" type="application/pdf" width="100%" height="800px" />
</div>

### Individual reflection (short written responses)

1. Positionality: Who are you in relation to your study system/communities? Name one way your training, language(s), or passport access could shape your research questions or interpretations. 

2. Language & knowledge systems: Give one concrete step you could take this term to include non-English sources or local knowledge forms (e.g., oral histories, maps, artefacts) in your evidence base. Why that step? 

3. Historical context: Identify one colonial or post-colonial process that influenced the landscape/species you study. How might that history affect your hypotheses or sampling frame? 

4. Avoiding parachute science: Describe one design change that would move a hypothetical field study from extractive to reciprocal (planning, authorship, outputs, or funding flow). 


5. Authorship & credit: Propose an authorship/acknowledgement plan for a collaborative project that fairly credits local experts and knowledge holders. What trade-offs might you face? 

6. Ethical risks: Name a foreseeable harm (social, cultural, or ecological) your project could cause and a mitigation you would build in from day one. 

**In-class discussion (small groups → whole class)**

A. Case study: “Who benefits?”:
Scenario: You have rapid funding to analyze biodiversity data collected in a Global South region and stored in a Global North repository. Internet bandwidth is limited for local collaborators.

Discuss:

- Minimum co-design steps you must take before analysis begins.

- How you will handle data access & sovereignty (permissions, embargoes, community review).

- A fair authorship and outputs plan (local language summary, data dashboards, capacity funding). 


B. Choose two of the reflection questions and synthesize you reflections to report back to the group. 



## Lab: Git and Github 

### Question 1
- Clone (instead of using the zip as we did in the beginning of class) the class book.

### Question 2 

- Create a git repo for the problem sets for the rest of the quarter. Call it ds-environ-[your initials] on your computer. 
- Connect local to remote repository on github. 
- Add the GE as a collaborators to the repos on github.


### Question 3 v1 (partners)
- Create another git repo for your final project (give it a name related to your project -[you and your partner's initials]) on github. Add your partner as a collaborator. 
- Both partners clone the repo to their computers.  
- One partner creates a readme file and commit their changes. push
- The other pulls.
- The partner that pulled creates a Topic + workflow proposal .Rmd file on their computer, and adds some ideas. add - commit - push
- The other partner pulls, and makes some changes add - commit - push
- Add the GE as a collaborator to the repo on github.

### Question 3 v2 (solo project)
- Create another git repo for your final project (give it a name related to your project -[your initials]) on github. 
- Clone the repo the repo to your computer.  
- Creates a readme file and commit your changes. push
- Create a Topic + workflow proposal .Rmd file on your computer, and adds some ideas. add - commit - push
- Make some changes add - commit - push
- Add the GE as a collaborator to the repo on github.


- Congratulations! You are all set up to start version controlling your project :) For the rest of the course, you will turn your your lab problem sets on github (and also upload a pdf to canvas).
