#! /bin/bash
echo "Please enter the name of the new article:"

read article

echo "Enter blog or home"
read variant 
mkdir $variant/$article

cp blog/blank.html $variant/$article/

mv $variant/$article/blank.html $variant/$article/$article.html

