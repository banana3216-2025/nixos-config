dir=$(pwd)
cd ~
rm -rf .zsh_history
cd "$dir"
exec $SHELL -l
