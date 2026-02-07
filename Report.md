# Report

## 1. Methods

### Step 1 — Fork, clone repo and copy BED files from the shared HPC directory
- Fork BED_overlap repo to my own GitHub account and clone my forked copy to my local machine using SSH link.

```bash
cd ~/OneDrive - University of East Anglia/UEA/Modules/Bioinformatics
git clone git@github.com:BMPhuong-Le/BED_overlap.git
cd BED_overlap
```

- Copy BED files from the shared HPC directory
```bash
# Log into HALi
ssh kfq26hru@hali.uea.ac.uk
# Start an interactive session
interactive-bio-ds
# Make a new folder for the project inside scratch
cd ~/scratch
mkdir BED_overlap
# Copy all BED files from the shared teaching directory into your project folder
cp /gpfs/data/BIO-DSB/Session2/*.bed ~/scratch/BED_overlap/
```

### Step 2: Download the BED files to my local machine: 
- Run this on your laptop, not on HALi:
```bash
cd ~/OneDrive - University of East Anglia/UEA/Modules/Bioinformatics/BED_overlap
# Secure copy from HALi to current local file
scp kfq26hru@hali.uea.ac.uk:~/scratch/BED_overlap/*.bed .
#You’ll be prompted for your HPC password
```
*The files will appear in your local BED_overlap/ directory.*

### Step 3: Sort the BED files (recommended before using bedtools):
```bash
# --- Input ---
file1="/gpfs/home/kfq26hru/scratch/BED_overlap/DPure_indels_mask.bed"
file2="/gpfs/home/kfq26hru/scratch/BED_overlap/LPure_indels_mask.bed"

# --- Outputs ---
output_dir="/gpfs/home/kfq26hru/scratch/BED_overlap/output"
mkdir -p "$output_dir"

# --- Sort inputs (recommended for bedtools) ---
## Define output paths for the sorted BED files
sorted_file1="$output_dir/sorted_D.bed"
sorted_file2="$output_dir/sorted_L.bed"
## Sort files by chromosome (column 1) and then by start coordinate (column 2, numeric)
sort -k1,1n -k2,2n "$file1" > "$sorted_file1"
sort -k1,1n -k2,2n "$file2" > "$sorted_file2"
```

### Step 4: Find overlaps using Unix commands
This method only detects exact matches — intervals which must have the same chromosome, start, and end positions.

```bash
# Find match-intervals between 2 files
cat "$sorted_file1" "$sorted_file2" \
    # Extract only the coordinate columns (chrom, start, end)
    | awk '{print $1, $2, $3}' \
    # Sort all intervals so identical lines are adjacent
    | sort \
    # Print only lines that appear more than once (i.e., present in both files)
    | uniq -d \
    # Save the exact‑match intervals to the output directory
    > "$output_dir/overlap_unix.bed"
```

### Step 5: Find overlaps using bedtools 
*Run this on on HALi*
#### a. Standardised approach
Counts any interval that overlaps by at least 1 bp. This captures biologically meaningful overlaps even when coordinates differ slightly.

```bash
# Load bedtools on HALi
module load bedtools
# Define output file for bedtools default overlap
bt_out="$output_dir/overlap_bedtools.bed"
# Default bedtools overlap: counts any interval overlapping by ≥1 bp
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" > "$bt_out"
```

#### b. Strict criteria approach
- (`-f 0.5 -r`): Requires each interval to overlap the other by at least 50% of its length.
This filters out weak or partial overlaps
```bash
strict_out="$output_dir/overlap_bedtools_strict.bed"
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" -f 0.5 -r > "$bt_strict_out"
```

- (`-f 1.0 -r`): Requires 100% reciprocal overlap. This behaves identically to the Unix method.
```bash
bt_exact_out="$output_dir/overlap_bedtools_exact.bed"
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" -f 1.0 -r > "$bt_exact_out"
```

---

## 2. Results
- Unix method: *71,605 overlapping indels*	
```bash
     wc -l overlaps_unix.bed
```
- bedtools method:	
    - Standardised approach: *165,573 overlapping indels*
    ```bash
     wc -l overlap_bedtools.bed
    ```

    - Strict criteria approach
        - f=0.5 -r: *102,320 overlapping indels*
         ```bash
        wc -l overlap_bedtools_strict.bed
        ```
        - f=1 -r: *71,605 overlapping indels*
         ```bash
        wc -l overlap_bedtools_exact.bed
        ```

---

## 3. Comparison
- The **Unix** method detects smaller overlapping indels as it only detects the same set of intervals with perfectly matching coordinates.

- The **BEDtools standardised** result is much higher because it counts any overlapping intervals, even if the coordinates differ slightly.

=> Bedtools method is not the same as Unix result.

---

## 4. Reflection
- **The Unix method**: simple and transparent, but only detects exact coordinate matches and is easy to break if file formatting changes.

- The **BEDtools method**: standardised, widely used in genomics, well‑documented, reproducible across systems, flexible (supports many overlap definitions).

For **Reproducible** research, Bedtools is the more appropriate tool, because it provides consistent behaviour, handles edge cases correctly, and allows explicit control over overlap criteria.

---

# 5. Conclusion
- The Bedtools overlap captures the broadest biological signal, while the Unix method identify only perfectly aligned intervals.
- Using multiple overlap definitions provides a clearer understanding of how similar the two indel datasets truly are.