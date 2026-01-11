#! /bin/bash

cd ~/Documents/marksch

echo "Adding files"
git add --all
echo "Committing files"
git commit -a -m "c"
echo "Pushing to GitHub"
git push
