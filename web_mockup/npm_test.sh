current_dir="$(pwd | sed 's/ /\\ /g' )"

eval "npm --prefix ${current_dir} start"
