#!/bin/bash
#SBATCH -p bio-ds
#SBATCH --qos=bio-ds
#SBATCH --time=0-1
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=BED_overlap
#SBATCH -o /gpfs/home/abc12xyz/scratch/BED_overlap/Output_Messages/%x-%j.out   # TODO: set your path
#SBATCH -e /gpfs/home/abc12xyz/scratch/BED_overlap/Error_Messages/%x-%j.err    # TODO: set your path
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=abc12xyz@uea.ac.uk  # TODO: set to your UEA email

# --- Modules ---
module load bedtools

# --- Inputs (TODO: update to your paths from Step 1) ---
file1="/gpfs/home/abc12xyz/scratch/BED_overlap/DPure_indels_mask.bed"
file2="/gpfs/home/abc12xyz/scratch/BED_overlap/LPure_indels_mask.bed"

# --- Outputs (TODO: ensure this exists) ---
output_dir="/gpfs/home/abc12xyz/scratch/BED_overlap/output"
mkdir -p "$output_dir"

# --- 1) Sort inputs (recommended for bedtools) ---
sorted_file1="$output_dir/sorted_D.bed"
sorted_file2="$output_dir/sorted_L.bed"
sort -k1,1 -k2,2n "$file1" > "$sorted_file1"
sort -k1,1 -k2,2n "$file2" > "$sorted_file2"

# --- 2) Your Unix attempt (paste the pipeline you tested in Step 4) ---
# Example (exact coordinate match; replace with your own):
# ...your_unix_pipeline_using_sorted_file1_and_sorted_file2... > "$output_dir/overlap_unix.bed"
# TODO: replace the line below with your Unix overlap command
touch "$output_dir/overlap_unix.bed"

# --- 3) BEDtools intersect (standardised) ---
bt_out="$output_dir/overlap_bedtools.bed"
bedtools intersect -a "$sorted_file1" -b "$sorted_file2" > "$bt_out"

# Optional: try stricter criteria (uncomment if you want)
# bt_strict_out="$output_dir/overlap_bedtools_strict.bed"
# bedtools intersect -a "$sorted_file1" -b "$sorted_file2" -f 0.5 -r > "$bt_strict_out"

# --- 4) Minimal summary (beginner-friendly) ---
summary="$output_dir/comparison_summary.txt"
{
  echo "BED_overlap summary"
  echo "Unix overlap (your method): $( [ -s "$output_dir/overlap_unix.bed" ] && wc -l < "$output_dir/overlap_unix.bed" || echo 0 )"
  echo "BEDtools overlap (default):  $(wc -l < "$bt_out")"
  # Uncomment if you ran strict:
  # echo "BEDtools strict (f=0.5 -r): $(wc -l < "$bt_strict_out")"
} > "$summary"

echo "Done. See outputs in: $output_dir"
echo "Summary: $summary"
