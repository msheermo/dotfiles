# Neovim Maintenance Guide

## Updating Plugins
1. Check for available updates: `:Lazy check`
2. Apply updates and update lockfile: `:Lazy update`
3. Test keymaps and editor configuration.
4. Commit the updated lockfile:
   ```bash
   git add lazy-lock.json
   git commit -m "chore(nvim): update plugin dependencies"

# rollback and restore
git checkout HEAD -- lazy-lock.json

:Lazy restore


