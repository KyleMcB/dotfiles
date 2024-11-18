function git_conflicts
    git diff --name-only --diff-filter=U
end
