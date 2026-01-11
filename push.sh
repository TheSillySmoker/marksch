#! /bin/bash

cd ~/Documents/marksch

echo "Adding files"
git rm --cached blog/portfolio/TSLA_purchase_history/TSLA_purchases.png
git add -f blog/portfolio/TSLA_purchase_history/TSLA_purchases.png
git add --all
echo "Committing files"
git commit -a -m "c"
echo "Pushing to GitHub"
git push
