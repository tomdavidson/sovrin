#!/usr/bin/env bash
# https://www.terraform.io/docs/commands/validate.html
base=${PWD##*/}   
name=${npm_package_name:-$base}

validate () {
  if [[ $(terraform validate $1) ]]
  then
    [[ $1 -eq 'src' || $1 -eq '.' ]] && echo "¬ $name" || echo "¬ $1"
    exit 1;
  else
    [[ $1 -eq 'src' || $1 -eq '.' ]] && echo "√ $name" || echo "√ $1";
  fi
}

modules=$(find -mindepth 2 -name '*.tf' -printf '%P\n' | xargs -I % dirname %)

echo 'terraform validate:';
for m in $modules; do validate "$m" & done
wait;
echo '';
