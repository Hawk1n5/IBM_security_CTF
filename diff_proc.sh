#!/bin/bash

IFS=$'\n'

old_proc=$(ps -eo command)

while true; do
	new_proc=$(ps -eo command)
    diff <(echo "$old_proc") <(echo "$new_proc")
	sleep 1
	old_proc=$new_proc
done
