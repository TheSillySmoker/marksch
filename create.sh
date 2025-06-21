#! /bin/bash
echo "Please enter the name of the new article:"
read article
echo "Enter blog or home"
read variant 

echo "Making a new folder: $variant/$article"
mkdir $variant/$article

#make blank article in the new directory
echo "Making copy of blog/blank.html and putting it in $variant/$article."
cp blog/blank.html $variant/$article/

#rename the blank article
echo "Renaming your new blank article to $article.html \n\n"
mv $variant/$article/blank.html $variant/$article/$article.html

#Add it into the home page as a button if you give it a valid topic
echo "Please enter the topic (finance, sd, misc):"
read topic

line=0
case $topic in

	"finance")
	line=21
	;;

	"sd")
	line=28
	;;

	"misc")
	line=35
	;;
	
	*)
	echo "Not a valid topic, bro"
	;;
esac

if [ $line != 0 ];then
echo "What do you want the button to say?"
read button_name
echo "Adding <a href="$variant/$article/$article.html"><button class="button"><b>$button_name</b></button></a> to the home.html file on line $line"
vim -es "home.html" <<EOF
$line insert
		<a href="$variant/$article/$article.html"><button class="button"><b>$button_name</b></button></a>
.
wq
EOF
else
	echo "No topic found, no button will be added :)"
fi

echo "Your new article has been created in $variant/$article. \n and a new button has been create in home.html on line $line"
