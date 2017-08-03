#!/bin/bash

check=$(checkupdates | wc -l)

if [[ "$check" != "0" ]]
then
    echo "$check %{F#5b5b5b}%{F-}"
fi
