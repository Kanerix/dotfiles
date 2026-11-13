# Dotfiles. `just --list` to see everything.

scripts_dir := justfile_directory() / "scripts"
config_dir := justfile_directory() / "config"
target_dir := env('HOME') / ".config"
skills_dir := justfile_directory() / "skills"
skills_target_dir := env('HOME') / ".agents/skills"

# Show available recipes
default:
    @just --list

# Symlink config files and skill directories globally, backing up real entries
link:
    @bash "{{ scripts_dir }}/link.sh" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Report what is linked, what is not, and what is missing
status:
    @bash "{{ scripts_dir }}/status.sh" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Check links, shell environment and optional Rust setup without changing anything
doctor: status
    @bash "{{ scripts_dir }}/doctor.sh"

# Remove only exact owned symlinks in both roots. Backups are left alone.
unlink:
    @bash "{{ scripts_dir }}/unlink.sh" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Restore the most recent backup of config files and skill directories
restore:
    @bash "{{ scripts_dir }}/restore.sh" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Check the repo for committed credentials
scan:
    gitleaks dir . --no-banner --redact

# Regenerate Fish completions after upgrading tools (never at shell startup)
fish-completions:
    @bash "{{ scripts_dir }}/fish-completions.sh" "{{ config_dir }}"
