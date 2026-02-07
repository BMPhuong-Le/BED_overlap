#!/bin/bash
#SBATCH -p bio-ds
#SBATCH --qos=bio-ds
#SBATCH --time=0-1
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=BED_overlap
#SBATCH -o /gpfs/home/kfq26hru/scratch/BED_overlap/Output_Messages/%x-%j.out  
#SBATCH -e /gpfs/home/kfq26hru/scratch/BED_overlap/Error_Messages/%x-%j.err    
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kfq26hru@uea.ac.uk 

# --- Modules ---
module load bedtools

# --- Inputs (TODO: update to your paths from Step 1) ---
file1="/gpfs/home/kfq26hru/scratch/BED_overlap/DPure_indels_mask.bed"
file2="/gpfs/home/kfq26hru/scratch/BED_overlap/LPure_indels_mask.bed"

# --- Outputs (TODO: ensure this exists) ---
output_dir="/gpfs/home/kfq26hru/scratch/BED_overlap/output"
mkdir -p "$output_dir"

# --- 1) Sort inputs (recommended for bedtools) ---
sorted_file1="$output_dir/sorted_D.bed"
sorted_file2="$output_dir/sorted_L.bed"
sort -k1,1 -k2,2n "$file1" > "$sorted_file1"
sort -k1,1 -k2,2n "$file2" > "$sorted_file2"


# --- 2) Unix exact‑match overlap (chrom, start, end identical) ---
cat "$sorted_file1" "$sorted_file2" \
    | awk '{print $1, $2, $3}' \
    | sort \
    | uniq -d \
    > "$output_dir/overlap_unix.bed"


# --- 3) BEDtools intersect (standardised) ---
bt_out="$output_dir/overlap_bedtools.bed"
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" > "$bt_out"

# --- 3a) BEDtools stricter criteria (50% reciprocal overlap) ---
bt_strict_out="$output_dir/overlap_bedtools_strict.bed"
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" -f 0.5 -r > "$bt_strict_out"

# --- 3b) BEDtools exact‑match (identical coordinates only) ---
bt_exact_out="$output_dir/overlap_bedtools_exact.bed"
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" -f 1.0 -r > "$bt_exact_out"


# --- 4) Minimal summary (beginner-friendly) ---
summary="$output_dir/comparison_summary.txt"
{
  echo "BED_overlap summary"
  echo "Unix overlap (your method): $( [ -s "$output_dir/overlap_unix.bed" ] && wc -l < "$output_dir/overlap_unix.bed" || echo 0 )"
  echo "BEDtools overlap (default):  $(wc -l < "$bt_out")"
  echo "BEDtools strict (f=0.5 -r): $(wc -l < "$bt_strict_out")"
  echo "BEDtools exact match (f=1.0 -r): $(wc -l < "$bt_exact_out")"
} > "$summary"

echo "Done. See outputs in: $output_dir"
echo "Summary: $summary"