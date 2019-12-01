#!/bin/sh

result="$(brewdo cask outdated | grep -Ec \n)"

echo "<result>$result</result>"

exit 0