#!/usr/bin/env bash
# https://www.terraform.io/docs/commands/fmt.html

if [[ $(terraform fmt --write=false) ]]
then
    echo "¬ terraform style-guide";
    terraform fmt --diff=true;
    exit 1;
else
    echo "√ terraform style-guide"
fi
