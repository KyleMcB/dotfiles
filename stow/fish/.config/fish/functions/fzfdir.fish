function fzfdir --wraps='fd --type d | fzf' --description 'alias fzfdir fd --type d | fzf'
  fd --type d | fzf $argv
        
end
