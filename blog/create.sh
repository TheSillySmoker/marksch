#! /bin/bash
echo "Please enter the name of the new article:"

read article

mkdir $article

cp blank.html $PWD/$article/

mv $PWD/$article/blank.html $PWD/$article/$article.html

