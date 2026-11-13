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
    @fish --no-config "{{ scripts_dir }}/link.fish" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Report what is linked, what is not, and what is missing
status:
    @fish --no-config "{{ scripts_dir }}/status.fish" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Check links, shell environment and optional Rust setup without changing anything
doctor: status
    @fish --no-config "{{ scripts_dir }}/doctor.fish"

# Remove only exact owned symlinks in both roots. Backups are left alone.
unlink:
    @fish --no-config "{{ scripts_dir }}/unlink.fish" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Restore the most recent backup of config files and skill directories
restore:
    @fish --no-config "{{ scripts_dir }}/restore.fish" "{{ config_dir }}" "{{ target_dir }}" "{{ skills_dir }}" "{{ skills_target_dir }}"

# Check the repo for committed credentials
scan:
    gitleaks dir . --no-banner --redact

# Regenerate Fish completions after upgrading tools (never at shell startup)
fish-completions:
    @fish --no-config "{{ scripts_dir }}/fish-completions.fish" "{{ config_dir }}"
