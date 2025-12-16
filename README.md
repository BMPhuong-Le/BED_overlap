# BED_overlap - Data Science and Bioinformatics (BIO-7051B) Session 2

## Learning objectives

- Further proficiencey with Unix and command line
- Gain introductory exposure to integrative genome viewer (IGV)
- Document methods clearly for reproducible research
- Understand the value of standardised bioinformatics software for reproducibility
- Learn how to submit and monitor HPC jobs using SLURM

---

## Overview

In this tutorial, you'll compare indel (insertion/deletion) features between two *Drosophila melanogaster* populations using both Unix command-line tools and BEDtools.

You have two BED files representing indel features from two populations:
- `DPure_indels_mask.bed` – indels from the 'D' population
- `LPure_indels_mask.bed` – indels from the 'L' population

**Your task:** Find the overlapping indels between these two populations, and compare the reproducibility and clarity of using ad-hoc Unix commands versus a standardised tool (BEDtools).

**Hint:** The term "overlap" is ambiguous by design because there are commonly not right or wrong answers, making it valuable to be able to document exactly what you've done. 

---

## Before you start, you should have completed:

**Bioinformatics_Onboarding,** including:
- Command-line basics
- SSH key setup
- Git and GitHub workflows
**Session_1**
- HPC
- Unix commands (e.g. `grep`, `awk`, `sed`)
- `man` and other help options (e.g. -h, --help, etc.)
**Pre-workshop material for Session_2,** namely:
- SLURM scripts

## (Don't panic) Here's a reminder to catch you up:
- **Bash script:** a plain-text file of shell commands that you can run to automate tasks.
- **SLURM:** queues, schedules, and runs jobs submitted to the HPC.
- **sbatch script:** a bash script for running on the HPC with `#SBATCH` directives at the top.

---

## A suggested workflow 

### Step -1: Have your SSH keys set up in your local and HPC home directories (instructions in [Bioinformatics_onboarding](https://github.com/karlgrieshop/Bioinformatics_Onboarding)).

---

### Step 0: Fork this BED_overlap repo to your own GitHub account and Clone your forked copy to somewhere on your local machine (using the SSH link)

```bash
cd <where_you_want_it>
git clone git@github.com:<your-username>/BED_overlap.git
cd BED_overlap
```

*Replace `<your-username>` with your GitHub username.*

---

### Step 1: Copy BED files from the HPC shared directory

Log into the HPC and copy the two indel files to a sensible HPC directory:

```bash
ssh <abc12xyz>@hali.uea.ac.uk
interactive-bio-ds
cp /gpfs/data/BIO-DSB/Session2/*.bed ~/scratch/
```

Then download these files to your local `BED_overlap/` directory using `scp` (secure copy protocol):
```bash
cd /<where_you_want_them/>
# `scp` is secure copy protocol, and allows you to `cp` between HPC and local workspaces:
scp abc12xyz@hali.uea.ac.uk:~/<where_you_have_them/*.bed <local_directory_name>
# And enter your UEA HPC password when prompted,
# Wait for download to complete before closing shell.
```

---

### Step 2: Explore the BED file format

Here's a quick guide to [Common File Formats in Bioinformatics](https://docs.genebe.net/docs/handbook/file-formats/).

View the first few lines of each BED file:

```bash
head DPure_indels_mask.bed
head LPure_indels_mask.bed
```

**Try copy/pasting that `head` output into Copilot and telling it what you know and asking it what you don't know.** 

**Format explanation:**
Each line contains:
- **Column 1:** Chromosome or contig (e.g., `2L`)
- **Column 2:** Start position (0-based, inclusive)
- **Column 3:** End position (0-based, exclusive)
- **Column 4:** Feature ID (e.g., `2L:9611`)

Example:
```
2L      9600    9623    2L:9611
2L      16903   17128   2L:17004
2L      18035   18058   2L:18046
```

---

### Step 3: Visualise the BED files in IGV (Integrated Genome Viewer)

In case you missed it, here's a [video tutorial for IGV](https://www.youtube.com/watch?v=YpNg0hNUuo8&list=PLSplvWwdPpSoyXjQ0xPs46CcA9Nzano9F).

Use IGV locally to load both BED files as separate tracks and inspect overlaps visually.
- Launch IGV.
- Set the genome to *Drosophila melanogaster* (dm6/BDGP6; match the build used for these BED files).
- Load tracks:
  - File → Load from File… → select `DPure_indels_mask.bed`
  - File → Load from File… → select `LPure_indels_mask.bed`
- Zoom to regions and note apparent overlaps, differences, and any systematic patterns.
- If IGV warns about mismatched coordinates, verify you selected the correct genome build.

Tip: What is an "overlap" between LPure and DPure indels now that you've seen that data? Try to image a rule or set of rules that you could apply to to identify and count up the overlapping indel regions.

---

### Step 4: Find overlaps using Unix commands (ad-hoc approach)

**Can do locally or on HPC - you decide**

Use the common and powerful Unix commands you've learned (e.g. `awk`, `sort`, `grep`, `uniq`) to identify overlapping indels by matching on chromosome and position ranges.

**Suggested approach:** Try commands one at a time to understand the output before piping tasks together into an overall output.
1. Extract chromosome and position info from both files.
2. Combine and sort the data.
3. Identify duplicates or overlaps.
4. Count the results.
5. Some likely useful commands:
 - `awk` to extract and compare columns
 - `sort` and `uniq` to identify duplicates
 - `grep` to filter results
 - Pipes (`|`) to chain commands
 - `>` to output findings to a file (maybe a .txt file)

 **Tips:**
- Consider what "overlap" means in the context of genomic features (do coordinates have to match exactly, or just fall within similar ranges?).
- Document each step: what does each command do? **How do you know it worked?**
- Save your command pipeline to a file for reproducibility.
- Check the Bioinformatics_Onboarding/Unix_help/Unix_CheatSheet.md for some powerful one-liner ideas.
- **Don't forget you have Copilot to help you.**

---

### Step 5: Find overlaps using BEDtools (standardised approach)

BEDtools is a standardised suite of tools for genome arithmetic. It provides reproducible, well-documented methods for genomic feature overlap.

**Check if BEDtools is on the HPC:**
```bash
ssh <abc12xyz>@hali.uea.ac.uk
interactive-bio-ds
module avail
module keyword bed
```

**Yes, it is, explore BEDtools (must load it first)**
```bash
module load bedtools
bedtools --help
# Hey, check out that first BEDtools command listed.
# "intersect     Find overlapping ..."
# Sounds relvant, no? Explore that further.
bedtools intersect --help
# At the top it says:
# "Summary: Report overlaps between two feature files."
# "Usage:   bedtools intersect [OPTIONS] -a <bed/gff/vcf/bam> -b <bed/gff/vcf/bam>"
```

**Run BEDtools to find overlaps:**
```bash
# Recall you put the *.bed flies in ~/scratch/where_you_put_it/
# You'll either need to be in that directory, or include it in your file_names:
bedtools intersect -a DPure_indels_mask.bed -b LPure_indels_mask.bed > overlapping_indels.bed
```

Notes:
- `-a`: Query file (first population)
- `-b`: Subject file (second population)
- `>`: Output file that you name, in this case, it's the features from `-a` that overlap with `-b` 

---

### Step 6: Compare your results

1. **Unix method:** How many overlapping indels did you find? Can you explain exactly what your command pipeline did?
   - If your Unix pipeline writes to a file:
     ```bash
     wc -l overlaps_unix.bed
     # Don't know what `wc` is? Try `man wc`
     ```
   - Or count directly via a pipe (add this at the end of your pipeline):
     ```bash
     # ...your_unix_pipeline... | wc -l
     ```

2. **BEDtools method:** How many overlaps did BEDtools report? Is it the same as your Unix result?
   - If you saved the output in Step 5:
     ```bash
     wc -l overlapping_indels.bed
     ```
   - Or count without saving:
     ```bash
     bedtools intersect -a DPure_indels_mask.bed -b LPure_indels_mask.bed | wc -l
     ```
   - Count “unique A features with ≥1 overlap” (deduplicated by A):
     ```bash
     bedtools intersect -a DPure_indels_mask.bed -b LPure_indels_mask.bed -u | wc -l
     ```
   - Count “A features with no overlap with B”:
     ```bash
     bedtools intersect -a DPure_indels_mask.bed -b LPure_indels_mask.bed -v | wc -l
     ```
   - Compare strict criteria (example from Step 5):
     ```bash
     bedtools intersect -a DPure_indels_mask.bed -b LPure_indels_mask.bed -f 0.5 -r | wc -l
     ```

3. **Reproducibility:** Which approach would be easier to document in a methods section of a paper? Which is easier for a colleague to understand and reproduce?

---

### Step 7: Put your commands into an sbatch script

**A functional script ramps up the reprodcibility to another level because it's an exact record of the actual code that was run (not just some notes on the side).**

Take the Unix and BEDtools commands you ran interactively (Steps 4–6) and place them into the SLURM scaffold:
`SLURM_scripting/BED_overlap.sh`

- Open the script **locally** in VS Code and fill the TODO lines (paths, email, your commands, etc., **hint:** `ctl + f` "TODO").
- Keep it simple: sort inputs, run your Unix overlap attempt, run `bedtools intersect`, and write outputs to the `output/` folder.
- **Save** your changes to the BED_overlap.sh script!
- Then, **move** your modified BED_overlap.sh script to the HPC somehow
 - Two options: 
 1. Use GitHub: `add` `commit` and `push` changes to your repo, then `clone` or `pull` those changes to your HPC account - highly reproducible, uses GitHub to mirror your work and keeps a record of changes.
 2. Use scp: `scp` the BED_overlap script from local to HPC workspace, the same way you did with the *.bed files earlier - quicker, but less reproducible because local and HPC workspaces may not match exactly, changes not recorded in your `git log`, and no opportunity to `git checkout` previous versions in future.
- Then, **submit** and monitor on the HPC:
```bash
cd scratch/where_you_put/SLURM_scripting/
sbatch BED_overlap.sh
squeue -u <abc12xyz>          # watch your job
tail -n 20 output/comparison_summary.txt  # quick check
  ```

- **Trouble?** Make sure input and output paths are logical. Think about where you are (`pwd`), where your input files are, and where your output/ folder is.

---

### Step 8: Document your findings

Make some brief notes (Markdown or text file) that includes:
1. **Methods:** Describe your Unix approach and your BEDtools approach in clear language.
2. **Results:** Number of overlapping indels found by each method.
3. **Comparison:** Were results identical? Why or why not?
4. **Reflection:** Which approach is more suitable for reproducible research? Why does standardised software matter?

Commit this report to your local BED_overlap repo and push it to GitHub:
```bash
# From within the repo
git add report.md       # or git add --all
git commit -m "BED_overlap complete: Analysis and comparison of Unix vs BEDtools"
git push origin main
```

---

## Key Takeaway

**Standardised bioinformatics software (like BEDtools) provides:**
- **Reproducibility:** Version control and documentation.
- **Scalability:** Efficient algorithms designed for large genomic datasets.
- **Credibility:** Methods reviewers can trust and validate.

Ad-hoc Unix pipelines are powerful and flexible, and you may need them for some tasks, but then you're on your own to validate the output and document the approach in reproducible way.

---

## Group Project ideas

Take this further in some way or ways (remember: chief marking criteria for group project is the reproducibility):
- **Unique indels:** Do the oposite of "overlap." Find the uniqe indels between populations.
- **Characterse:** the unique or overlapping indels further (beyond counts, maybe size, or chromosomal locations).
- **Statistical:** Are some chromosomes (X, 2, 3) enriched for proportionally more indels, unique indels and/or overlapping indels, than expected by chance? 

---

## Contact & Questions

For questions about this tutorial, contact:
Karl Grieshop  
School of Biological Sciences  
University of East Anglia  
k.grieshop@uea.ac.uk
