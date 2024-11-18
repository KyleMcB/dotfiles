
function cd
    if test (count $argv) -eq 0
        builtin cd ~
    else
        builtin cd $argv
    end
    ls
end
